import 'package:dartz/dartz.dart';
import 'package:mudabbir/persentation/resources/strings_manager.dart';
import '../../data/local/database_helper.dart';
import '../../domain/repository/home_repository/home_repository.dart';

class Validators {
  static Future<Either<String, bool>> checkBalance(
    double expense,
    HomeRepository repo,
  ) async {
    try {
      final income = await repo.getTotalIncome();
      final expenseTotal = await repo.getTotalExpense();
      final balance = income - expenseTotal;

      if (balance - expense < 0) {
        return Left('Insufficient balance! Current: $balance');
      }
      return const Right(true);
    } catch (e) {
      return Left('Balance check failed: $e');
    }
  }

  static Future<Either<String, bool>> checkBudget(
    int accountId,
    double expense,
    String date,
    DbHelper db,
  ) async {
    try {
      final budgets = await db.getBudgetsForAccount(accountId, date);
      if (budgets.isLeft()) return const Right(true);

      final list = budgets.getOrElse(() => []);
      if (list.isEmpty) return const Right(true);

      for (final budget in list) {
        final limit = (budget['amount'] as num).toDouble();
        final start = budget['start_date'] as String;
        final end = budget['end_date'] as String;

        final result = await db.complexQuery(
          table: 'transactions',
          columns: ['SUM(amount) as total'],
          where: 'account_id = ? AND type = ? AND date BETWEEN ? AND ?',
          whereArgs: [accountId, 'expense', start, end],
        );

        double spent = 0.0;
        result.fold((_) {}, (data) {
          if (data.isNotEmpty && data.first['total'] != null) {
            spent = (data.first['total'] as num).toDouble();
          }
        });

        if (spent + expense > limit) {
          return Left(AppStrings.budgetExceeded);
        }
      }
      return const Right(true);
    } catch (e) {
      return Left('Budget check failed: $e');
    }
  }
}
