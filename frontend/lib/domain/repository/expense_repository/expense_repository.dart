import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/presentation/resources/expense_strings.dart';
import 'package:mudabbir/service/getit_init.dart';

/// CRUD and filters for local transactions with budget linkage.
class ExpenseRepository {
  final DbHelper _db = getIt<DbHelper>();

  /// Lists transactions with optional month/category/type/recurring filters.
  Future<Either<Failure, List<ExpenseTransaction>>> getTransactions({
    String type = 'expense',
    String? monthKey,
    int? categoryId,
    bool recurringOnly = false,
  }) async {
    try {
      final clauses = <String>['t.type = ?'];
      final args = <dynamic>[type];

      if (monthKey != null && monthKey.isNotEmpty) {
        clauses.add("strftime('%Y-%m', t.date) = ?");
        args.add(monthKey);
      }
      if (categoryId != null) {
        clauses.add('t.category_id = ?');
        args.add(categoryId);
      }
      if (recurringOnly) {
        clauses.add('t.is_recurring = 1');
      }

      final result = await _db.complexQuery(
        table: 'transactions t',
        columns: [
          't.id',
          't.amount',
          't.date',
          't.type',
          't.notes',
          't.account_id',
          't.category_id',
          't.is_recurring',
          't.recurrence_interval',
          'a.name AS account_name',
          'c.name AS category_name',
        ],
        joinClause:
            'LEFT JOIN accounts a ON a.id = t.account_id LEFT JOIN categories c ON c.id = t.category_id',
        where: clauses.join(' AND '),
        whereArgs: args,
        orderBy: 't.date DESC, t.id DESC',
      );

      return result.fold(
        (_) => const Right([]),
        (rows) => Right(rows.map(ExpenseTransaction.fromMap).toList()),
      );
    } catch (e) {
      return Left(UnknownFailure(ExpenseStrings.loadFailed));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getExpenseCategories() async {
    final result = await _db.queryRow('categories', 'type = ?', ['expense']);
    return result.fold(
      (_) => const Right([]),
      Right.new,
    );
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getAccounts() async {
    final result = await _db.queryRow('accounts', '1 = ?', [1]);
    return result.fold(
      (_) => const Right([]),
      Right.new,
    );
  }

  Future<double> getAccountBalance() async {
    final result = await _db.queryRow('transactions', '1 = ?', [1]);
    return result.fold((_) => 0.0, (rows) {
      var balance = 0.0;
      for (final row in rows) {
        final amount = (row['amount'] as num?)?.toDouble() ?? 0;
        final txType = row['type']?.toString() ?? '';
        if (txType == 'income') {
          balance += amount;
        } else if (txType == 'expense') {
          balance -= amount;
        }
      }
      return balance;
    });
  }

  Future<BudgetSnapshot?> getBudgetSnapshot({
    required int accountId,
    required String date,
    int? excludeTransactionId,
  }) async {
    final budgets = await _db.getBudgetsForAccount(accountId, date);
    return budgets.fold<Future<BudgetSnapshot?>>((_) async => null, (
      rows,
    ) async {
      if (rows.isEmpty) return null;
      final budget = rows.first;
      final amount = (budget['amount'] as num?)?.toDouble() ?? 0;
      final start = budget['start_date']?.toString() ?? '';
      final end = budget['end_date']?.toString() ?? '';

      final spentResult = await _db.complexQuery(
        table: 'transactions',
        columns: ['SUM(amount) as total'],
        where:
            'type = ? AND account_id = ? AND date BETWEEN ? AND ?' +
            (excludeTransactionId != null ? ' AND id != ?' : ''),
        whereArgs: excludeTransactionId != null
            ? [
                'expense',
                accountId,
                start,
                end,
                excludeTransactionId,
              ]
            : ['expense', accountId, start, end],
      );

      final spent = spentResult.fold(
        (_) => 0.0,
        (r) => (r.first['total'] as num?)?.toDouble() ?? 0.0,
      );
      final remaining = amount - spent;
      return BudgetSnapshot(
        budgetAmount: amount,
        spentAmount: spent,
        remaining: remaining,
        isOverBudget: spent > amount,
      );
    });
  }

  Future<Either<Failure, ExpenseWriteResult>> addTransaction(
    ExpenseTransaction transaction, {
    bool allowOverBudget = false,
  }) async {
    try {
      if (transaction.amount <= 0) {
        return const Left(ValidationFailure('invalid amount'));
      }

      if (transaction.type == 'expense') {
        final balance = await getAccountBalance();
        if (transaction.amount > balance) {
          return Left(
            ValidationFailure(ExpenseStrings.insufficientBalance),
          );
        }

        final budget = await getBudgetSnapshot(
          accountId: transaction.accountId,
          date: transaction.date,
        );
        if (budget != null &&
            !allowOverBudget &&
            transaction.amount > budget.remaining) {
          return Left(
            BudgetExceededFailure(
              ExpenseStrings.budgetExceeded(budget.remaining),
              budgetRemaining: budget.remaining,
            ),
          );
        }
      }

      final id = await _db.insert('transactions', transaction.toInsertMap());

      if (transaction.isRecurring &&
          transaction.recurrenceInterval == 'monthly') {
        await _scheduleNextRecurring(transaction);
      }

      final budgetAfter = transaction.type == 'expense'
          ? await getBudgetSnapshot(
              accountId: transaction.accountId,
              date: transaction.date,
            )
          : null;

      return Right(
        ExpenseWriteResult(
          transactionId: id,
          budgetSnapshot: budgetAfter,
          budgetMessage: _budgetMessage(budgetAfter),
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(ExpenseStrings.saveFailed));
    }
  }

  Future<Either<Failure, ExpenseWriteResult>> updateTransaction(
    ExpenseTransaction transaction, {
    bool allowOverBudget = false,
  }) async {
    try {
      if (transaction.amount <= 0) {
        return const Left(ValidationFailure('invalid amount'));
      }

      if (transaction.type == 'expense') {
        final balance = await getAccountBalance();
        final oldRows = await _db.queryRow('transactions', 'id = ?', [
          transaction.id,
        ]);
        final oldAmount = oldRows.fold(
          (_) => 0.0,
          (rows) => (rows.first['amount'] as num?)?.toDouble() ?? 0.0,
        );
        final delta = transaction.amount - oldAmount;
        if (delta > 0 && delta > balance) {
          return Left(
            ValidationFailure(ExpenseStrings.insufficientBalance),
          );
        }

        final budget = await getBudgetSnapshot(
          accountId: transaction.accountId,
          date: transaction.date,
          excludeTransactionId: transaction.id,
        );
        if (budget != null &&
            !allowOverBudget &&
            transaction.amount > budget.remaining) {
          return Left(
            BudgetExceededFailure(
              ExpenseStrings.budgetExceeded(budget.remaining),
              budgetRemaining: budget.remaining,
            ),
          );
        }
      }

      await _db.update(
        'transactions',
        transaction.toInsertMap(),
        'id = ?',
        [transaction.id],
      );

      final budgetAfter = transaction.type == 'expense'
          ? await getBudgetSnapshot(
              accountId: transaction.accountId,
              date: transaction.date,
            )
          : null;

      return Right(
        ExpenseWriteResult(
          transactionId: transaction.id,
          budgetSnapshot: budgetAfter,
          budgetMessage: _budgetMessage(budgetAfter),
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(ExpenseStrings.updateFailed));
    }
  }

  Future<Either<Failure, bool>> deleteTransaction(int id) async {
    try {
      final affected = await _db.delete('transactions', 'id = ?', [id]);
      return Right(affected > 0);
    } catch (e) {
      return Left(UnknownFailure(ExpenseStrings.deleteFailed));
    }
  }

  Future<void> _scheduleNextRecurring(ExpenseTransaction source) async {
    final current = DateTime.tryParse(source.date);
    if (current == null) return;
    final next = DateTime(current.year, current.month + 1, current.day);
    await _db.insert('transactions', {
      ...source.toInsertMap(),
      'date': next.toIso8601String().split('T').first,
    });
  }

  String? _budgetMessage(BudgetSnapshot? snapshot) {
    if (snapshot == null) return null;
    return ExpenseStrings.budgetLinked(
      snapshot.spentAmount,
      snapshot.budgetAmount,
      snapshot.remaining,
    );
  }

  /// Merges server expenses into local SQLite (keeps statistics/analysis in sync).
  Future<void> mergeServerExpenses(List<ExpenseTransaction> items) async {
    for (final tx in items) {
      if (tx.type != 'expense') continue;
      await _db.insertOrReplace('transactions', {
        ...tx.toInsertMap(),
        'id': tx.id,
      });
    }
  }

  /// Replaces a locally assigned id with the server id after offline create sync.
  Future<void> replaceLocalId(int localId, ExpenseTransaction serverTx) async {
    await _db.delete('transactions', 'id = ?', [localId]);
    await _db.insertOrReplace('transactions', {
      ...serverTx.toInsertMap(),
      'id': serverTx.id,
    });
  }
}
