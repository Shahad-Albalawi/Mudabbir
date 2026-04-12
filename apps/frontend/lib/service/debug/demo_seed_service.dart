import 'package:mudabbir/data/local/local_database.dart';
import 'package:sqflite/sqflite.dart';

/// Fills local DB with realistic demo data when the user DB has no activity yet.
class DemoSeedService {
  /// True when there is nothing to lose by seeding demo rows.
  static bool shouldSeedCounts({
    required int transactionCount,
    required int goalCount,
    required int budgetCount,
  }) {
    return transactionCount == 0 && goalCount == 0 && budgetCount == 0;
  }

  /// After [LocalDatabase.initForUser], seeds once per empty database file.
  static Future<void> seedIfDatabaseEmpty() async {
    final db = await LocalDatabase.instance.database;

    Future<int> count(String table) async {
      final r = await db.rawQuery('SELECT COUNT(*) AS c FROM $table');
      return (r.first['c'] as int?) ?? 0;
    }

    final tx = await count('transactions');
    final goals = await count('goals');
    final budgets = await count('budgets');

    if (!shouldSeedCounts(
      transactionCount: tx,
      goalCount: goals,
      budgetCount: budgets,
    )) {
      return;
    }

    await _seed(db);
  }

  static Future<void> _seed(Database db) async {
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('budgets');
      await txn.delete('goals');
      await txn.delete('challenges');

      final accounts = await txn.query('accounts');
      final accountId = (accounts.isNotEmpty ? accounts.first['id'] : 1) as int;

      final categories = await txn.query('categories');
      int categoryId(String name, String type) {
        final row = categories.firstWhere(
          (c) => c['name'] == name && c['type'] == type,
          orElse: () => {'id': 1},
        );
        return (row['id'] as int?) ?? 1;
      }

      final now = DateTime.now();

      for (int m = 0; m < 4; m++) {
        final monthDate = DateTime(now.year, now.month - m, 2);
        await txn.insert('transactions', {
          'amount': 12000.0,
          'date': monthDate.toIso8601String(),
          'type': 'income',
          'notes': 'راتب شهري',
          'account_id': accountId,
          'category_id': categoryId('راتب', 'income'),
        });
      }

      for (int i = 0; i < 45; i++) {
        final d = now.subtract(Duration(days: i * 2));
        final isFood = i % 4 == 0;
        final isTransport = i % 4 == 1;
        final isBills = i % 4 == 2;
        final amount = isFood
            ? 55.0 + (i % 6) * 12
            : isTransport
            ? 18.0 + (i % 5) * 6
            : isBills
            ? 120.0 + (i % 3) * 40
            : 70.0 + (i % 7) * 20;
        final categoryName = isFood
            ? 'طعام'
            : isTransport
            ? 'نقل'
            : isBills
            ? 'فواتير'
            : 'تسوق';

        await txn.insert('transactions', {
          'amount': amount,
          'date': d.toIso8601String(),
          'type': 'expense',
          'notes': 'عملية تجريبية $i',
          'account_id': accountId,
          'category_id': categoryId(categoryName, 'expense'),
        });
      }

      await txn.insert('budgets', {
        'amount': 6500.0,
        'start_date': DateTime(now.year, now.month, 1).toIso8601String(),
        'end_date': DateTime(now.year, now.month + 1, 0).toIso8601String(),
        'account_id': accountId,
      });
      await txn.insert('budgets', {
        'amount': 6200.0,
        'start_date': DateTime(now.year, now.month - 1, 1).toIso8601String(),
        'end_date': DateTime(now.year, now.month, 0).toIso8601String(),
        'account_id': accountId,
      });

      await txn.insert('goals', {
        'name': 'صندوق الطوارئ',
        'target': 30000.0,
        'current_amount': 12000.0,
        'type': 'قصير المدى',
        'start_date': DateTime(now.year, now.month - 1, 1).toIso8601String(),
        'end_date': DateTime(now.year + 1, now.month, 1).toIso8601String(),
      });
      await txn.insert('goals', {
        'name': 'سيارة',
        'target': 90000.0,
        'current_amount': 24000.0,
        'type': 'متوسط المدى',
        'start_date': DateTime(now.year, now.month - 2, 1).toIso8601String(),
        'end_date': DateTime(now.year + 2, now.month, 1).toIso8601String(),
      });
      await txn.insert('goals', {
        'name': 'استثمار',
        'target': 150000.0,
        'current_amount': 35000.0,
        'type': 'طويل المدى',
        'start_date': DateTime(now.year, now.month - 3, 1).toIso8601String(),
        'end_date': DateTime(now.year + 3, now.month, 1).toIso8601String(),
      });

      await txn.insert('challenges', {
        'name': 'تحدي ادخار 5000',
        'start_date': DateTime(now.year, now.month, 1).toIso8601String(),
        'end_date': DateTime(now.year, now.month + 1, 0).toIso8601String(),
        'status': 'نشط',
      });
      await txn.insert('challenges', {
        'name': 'تقليل المطاعم 30%',
        'start_date': DateTime(now.year, now.month - 1, 1).toIso8601String(),
        'end_date': DateTime(now.year, now.month, 0).toIso8601String(),
        'status': 'مكتمل',
      });
      await txn.insert('challenges', {
        'name': 'No-spend weekend',
        'start_date': DateTime(now.year, now.month, 5).toIso8601String(),
        'end_date': DateTime(now.year, now.month, 25).toIso8601String(),
        'status': 'نشط',
      });
    });
  }
}
