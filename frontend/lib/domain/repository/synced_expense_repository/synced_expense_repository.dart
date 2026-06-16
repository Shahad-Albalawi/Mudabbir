import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/local/expense_hive_cache.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/data/remote/expense_api_service.dart';
import 'package:mudabbir/domain/models/expense_sync_result.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/domain/repository/expense_repository/expense_repository.dart';
import 'package:mudabbir/presentation/resources/expense_strings.dart';
import 'package:mudabbir/presentation/server_challenges/services/api_exception.dart';
import 'package:mudabbir/service/getit_init.dart';

/// Offline-first sync between Laravel expenses API, Hive cache, and SQLite.
class SyncedExpenseRepository {
  final ExpenseRepository _local;
  final ExpenseApiService _remote;
  final ExpenseHiveCache _cache;

  SyncedExpenseRepository({
    ExpenseRepository? local,
    ExpenseApiService? remote,
    ExpenseHiveCache? cache,
  })  : _local = local ?? getIt<ExpenseRepository>(),
        _remote = remote ?? getIt<ExpenseApiService>(),
        _cache = cache ?? getIt<ExpenseHiveCache>();

  Future<Either<Failure, List<Map<String, dynamic>>>> getExpenseCategories() =>
      _local.getExpenseCategories();

  Future<Either<Failure, List<Map<String, dynamic>>>> getAccounts() =>
      _local.getAccounts();

  Future<ExpenseListSyncResult> getTransactions({
    String type = 'expense',
    String? monthKey,
    int? categoryId,
    bool recurringOnly = false,
  }) async {
    final cached = _cache.getExpensesList();

    try {
      final remote = await _remote.getExpenses();
      await _cache.saveExpensesList(remote.map((e) => e.toJson()).toList());
      await _local.mergeServerExpenses(remote);
      await flushPendingOps();

      final local = await _local.getTransactions(
        type: type,
        monthKey: monthKey,
        categoryId: categoryId,
        recurringOnly: recurringOnly,
      );
      return ExpenseListSyncResult(
        expenses: local.getOrElse(() => []),
      );
    } on ApiException catch (e) {
      if (e.isNetworkError) {
        if (cached != null) {
          return ExpenseListSyncResult(
            expenses: _filterCached(
              cached,
              type: type,
              monthKey: monthKey,
              categoryId: categoryId,
              recurringOnly: recurringOnly,
            ),
            fromCache: true,
            isOffline: true,
          );
        }

        final local = await _local.getTransactions(
          type: type,
          monthKey: monthKey,
          categoryId: categoryId,
          recurringOnly: recurringOnly,
        );
        return local.fold(
          (_) => const ExpenseListSyncResult(expenses: [], isOffline: true),
          (data) => ExpenseListSyncResult(
            expenses: data,
            fromCache: true,
            isOffline: true,
          ),
        );
      }
      rethrow;
    }
  }

  Future<Either<Failure, ExpenseWriteSyncResult>> addTransaction(
    ExpenseTransaction transaction, {
    bool allowOverBudget = false,
  }) async {
    if (transaction.type == 'expense') {
      final validation = await _validateExpense(
        transaction,
        allowOverBudget: allowOverBudget,
      );
      if (validation != null) return Left(validation);
    }

    try {
      final remote = await _remote.createExpense(transaction.toJson()..remove('id'));
      await _cache.upsertExpense(remote.toJson());
      await _local.mergeServerExpenses([remote]);

      final budget = await _local.getBudgetSnapshot(
        accountId: remote.accountId,
        date: remote.date,
      );

      return Right(
        ExpenseWriteSyncResult(
          result: ExpenseWriteResult(
            transactionId: remote.id,
            budgetSnapshot: budget,
            budgetMessage: budget == null
                ? null
                : ExpenseStrings.budgetLinked(
                    budget.spentAmount,
                    budget.budgetAmount,
                    budget.remaining,
                  ),
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;

      final localResult = await _local.addTransaction(
        transaction,
        allowOverBudget: allowOverBudget,
      );

      return localResult.fold(Left.new, (write) async {
        final localTx = transaction.copyWithId(write.transactionId);
        await _cache.upsertExpense(localTx.toJson());
        await _cache.queueOp({
          'op': 'create',
          'local_id': write.transactionId,
          'payload': localTx.toJson(),
          'queued_at': DateTime.now().toIso8601String(),
        });
        return Right(
          ExpenseWriteSyncResult(
            result: write,
            syncedToServer: false,
            queuedOffline: true,
          ),
        );
      });
    }
  }

  Future<Either<Failure, ExpenseWriteSyncResult>> updateTransaction(
    ExpenseTransaction transaction, {
    bool allowOverBudget = false,
  }) async {
    if (transaction.type == 'expense') {
      final validation = await _validateExpense(
        transaction,
        allowOverBudget: allowOverBudget,
        excludeTransactionId: transaction.id,
      );
      if (validation != null) return Left(validation);
    }

    try {
      final remote = await _remote.updateExpense(
        transaction.id,
        transaction.toJson(),
      );
      await _cache.upsertExpense(remote.toJson());
      await _local.mergeServerExpenses([remote]);

      final budget = await _local.getBudgetSnapshot(
        accountId: remote.accountId,
        date: remote.date,
      );

      return Right(
        ExpenseWriteSyncResult(
          result: ExpenseWriteResult(
            transactionId: remote.id,
            budgetSnapshot: budget,
            budgetMessage: budget == null
                ? null
                : ExpenseStrings.budgetLinked(
                    budget.spentAmount,
                    budget.budgetAmount,
                    budget.remaining,
                  ),
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;

      final localResult = await _local.updateTransaction(
        transaction,
        allowOverBudget: allowOverBudget,
      );

      return localResult.fold(Left.new, (write) async {
        await _cache.upsertExpense(transaction.toJson());
        await _cache.queueOp({
          'op': 'update',
          'server_id': transaction.id,
          'payload': transaction.toJson(),
          'queued_at': DateTime.now().toIso8601String(),
        });
        return Right(
          ExpenseWriteSyncResult(
            result: write,
            syncedToServer: false,
            queuedOffline: true,
          ),
        );
      });
    }
  }

  Future<Either<Failure, ExpenseDeleteSyncResult>> deleteTransaction(int id) async {
    try {
      await _remote.deleteExpense(id);
      await _cache.removeExpense(id);
      final local = await _local.deleteTransaction(id);
      return local.fold(
        Left.new,
        (ok) => Right(ExpenseDeleteSyncResult(deleted: ok)),
      );
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;

      final local = await _local.deleteTransaction(id);
      return local.fold(Left.new, (ok) async {
        if (ok) {
          await _cache.removeExpense(id);
          await _cache.queueOp({
            'op': 'delete',
            'server_id': id,
            'queued_at': DateTime.now().toIso8601String(),
          });
        }
        return Right(
          ExpenseDeleteSyncResult(deleted: ok, queuedOffline: ok),
        );
      });
    }
  }

  Future<Failure?> _validateExpense(
    ExpenseTransaction transaction, {
    bool allowOverBudget = false,
    int? excludeTransactionId,
  }) async {
    final balance = await _local.getAccountBalance();
    var requiredBalance = transaction.amount;
    if (excludeTransactionId != null) {
      final oldRows = await _local.getTransactions(type: 'expense');
      final oldAmount = oldRows.fold(
        (_) => 0.0,
        (rows) {
          for (final row in rows) {
            if (row.id == excludeTransactionId) return row.amount;
          }
          return 0.0;
        },
      );
      requiredBalance = (transaction.amount - oldAmount).clamp(0, double.infinity);
    }
    if (requiredBalance > balance) {
      return ValidationFailure(ExpenseStrings.insufficientBalance);
    }

    final budget = await _local.getBudgetSnapshot(
      accountId: transaction.accountId,
      date: transaction.date,
      excludeTransactionId: excludeTransactionId,
    );
    if (budget != null &&
        !allowOverBudget &&
        transaction.amount > budget.remaining) {
      return BudgetExceededFailure(
        ExpenseStrings.budgetExceeded(budget.remaining),
        budgetRemaining: budget.remaining,
      );
    }
    return null;
  }

  Future<void> flushPendingOps() async {
    final ops = _cache.getPendingOps();
    if (ops.isEmpty) return;

    final remaining = <Map<String, dynamic>>[];
    for (final op in ops) {
      try {
        final type = op['op'] as String?;
        if (type == 'create') {
          final payload = Map<String, dynamic>.from(op['payload'] as Map);
          payload.remove('id');
          final remote = await _remote.createExpense(payload);
          await _cache.upsertExpense(remote.toJson());
          final localId = op['local_id'] as int?;
          if (localId != null) {
            await _local.replaceLocalId(localId, remote);
          } else {
            await _local.mergeServerExpenses([remote]);
          }
        } else if (type == 'update') {
          final serverId = op['server_id'] as int;
          final payload = Map<String, dynamic>.from(op['payload'] as Map);
          payload.remove('id');
          final remote = await _remote.updateExpense(serverId, payload);
          await _cache.upsertExpense(remote.toJson());
          await _local.mergeServerExpenses([remote]);
        } else if (type == 'delete') {
          final serverId = op['server_id'] as int;
          await _remote.deleteExpense(serverId);
          await _cache.removeExpense(serverId);
          await _local.deleteTransaction(serverId);
        }
      } on ApiException catch (e) {
        if (e.isNetworkError) {
          remaining.add(op);
        }
      }
    }
    await _cache.setPendingOps(remaining);
  }

  List<ExpenseTransaction> _filterCached(
    List<Map<String, dynamic>> cached, {
    required String type,
    String? monthKey,
    int? categoryId,
    bool recurringOnly = false,
  }) {
    return cached
        .map(ExpenseTransaction.fromMap)
        .where((tx) {
          if (tx.type != type) return false;
          if (monthKey != null &&
              monthKey.isNotEmpty &&
              !tx.date.startsWith(monthKey)) {
            return false;
          }
          if (categoryId != null && tx.categoryId != categoryId) return false;
          if (recurringOnly && !tx.isRecurring) return false;
          return true;
        })
        .toList();
  }
}

extension _ExpenseTransactionCopy on ExpenseTransaction {
  ExpenseTransaction copyWithId(int newId) {
    return ExpenseTransaction(
      id: newId,
      amount: amount,
      date: date,
      type: type,
      notes: notes,
      accountId: accountId,
      categoryId: categoryId,
      accountName: accountName,
      categoryName: categoryName,
      isRecurring: isRecurring,
      recurrenceInterval: recurrenceInterval,
    );
  }
}
