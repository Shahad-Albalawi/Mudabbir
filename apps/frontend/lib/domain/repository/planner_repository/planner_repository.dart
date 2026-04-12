import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/service/getit_init.dart';

/// Local planner: category budgets, notes, tasks, spent aggregates.
class PlannerRepository {
  final DbHelper _db = getIt<DbHelper>();

  Future<List<Map<String, dynamic>>> getExpenseCategories() async {
    final db = await _db.database;
    return db.query(
      'categories',
      where: 'type = ?',
      whereArgs: ['expense'],
      orderBy: 'name ASC',
    );
  }

  Future<double> getSpentForCategoryInMonth({
    required int categoryId,
    required int year,
    required int month,
  }) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total FROM transactions
      WHERE type = 'expense' AND category_id = ? AND date >= ? AND date <= ?
      ''',
      [categoryId, start.toIso8601String(), end.toIso8601String()],
    );
    final v = rows.first['total'];
    return (v as num?)?.toDouble() ?? 0;
  }

  Future<double?> getCategoryBudgetLimit({
    required int categoryId,
    required int year,
    required int month,
  }) async {
    final db = await _db.database;
    final rows = await db.query(
      'category_budgets',
      columns: ['amount_limit'],
      where: 'category_id = ? AND year = ? AND month = ?',
      whereArgs: [categoryId, year, month],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final v = rows.first['amount_limit'];
    return (v as num?)?.toDouble();
  }

  Future<void> upsertCategoryBudget({
    required int categoryId,
    required double amountLimit,
    required int year,
    required int month,
  }) async {
    final db = await _db.database;
    final existing = await db.query(
      'category_budgets',
      columns: ['id'],
      where: 'category_id = ? AND year = ? AND month = ?',
      whereArgs: [categoryId, year, month],
      limit: 1,
    );
    if (existing.isEmpty) {
      await db.insert('category_budgets', {
        'category_id': categoryId,
        'amount_limit': amountLimit,
        'year': year,
        'month': month,
      });
    } else {
      await db.update(
        'category_budgets',
        {'amount_limit': amountLimit},
        where: 'category_id = ? AND year = ? AND month = ?',
        whereArgs: [categoryId, year, month],
      );
    }
  }

  /// Average monthly expense per category over the last [months] complete months (excludes current).
  Future<Map<int, double>> averageExpenseByCategoryLastMonths(
    DateTime now,
    int months,
  ) async {
    final Map<int, double> sum = {};
    final Map<int, int> count = {};
    for (int i = 1; i <= months; i++) {
      final d = DateTime(now.year, now.month - i, 1);
      final cats = await getExpenseCategories();
      for (final c in cats) {
        final id = c['id'] as int;
        final spent = await getSpentForCategoryInMonth(
          categoryId: id,
          year: d.year,
          month: d.month,
        );
        if (spent > 0) {
          sum[id] = (sum[id] ?? 0) + spent;
          count[id] = (count[id] ?? 0) + 1;
        }
      }
    }
    final out = <int, double>{};
    for (final e in sum.entries) {
      final n = count[e.key] ?? 1;
      out[e.key] = e.value / n;
    }
    return out;
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await _db.database;
    return db.query('app_notes', orderBy: 'updated_at DESC');
  }

  Future<int> insertNote({
    required String title,
    required String body,
    required bool isFinancial,
  }) async {
    final now = DateTime.now().toIso8601String();
    return _db.insert('app_notes', {
      'title': title,
      'body': body,
      'is_financial': isFinancial ? 1 : 0,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> deleteNote(int id) async {
    await _db.delete('app_notes', 'id = ?', [id]);
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await _db.database;
    return db.query('app_tasks', orderBy: "status ASC, updated_at DESC");
  }

  Future<int> insertTask({
    required String title,
    required String body,
    int? categoryId,
  }) async {
    final now = DateTime.now().toIso8601String();
    return _db.insert('app_tasks', {
      'title': title,
      'body': body,
      'status': 'pending',
      'category_id': categoryId,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> updateTaskStatus(int id, String status) async {
    await _db.update(
      'app_tasks',
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      'id = ?',
      [id],
    );
  }

  Future<void> deleteTask(int id) async {
    await _db.delete('app_tasks', 'id = ?', [id]);
  }

  /// Categories at or above [thresholdPct] of monthly limit (only if limit > 0).
  Future<List<String>> categoryBudgetAlertLines(
    DateTime now,
    double thresholdPct,
  ) async {
    final y = now.year;
    final m = now.month;
    final cats = await getExpenseCategories();
    final lines = <String>[];
    for (final c in cats) {
      final id = c['id'] as int;
      final name = c['name']?.toString() ?? '';
      final limit = await getCategoryBudgetLimit(
        categoryId: id,
        year: y,
        month: m,
      );
      if (limit == null || limit <= 0) continue;
      final spent = await getSpentForCategoryInMonth(
        categoryId: id,
        year: y,
        month: m,
      );
      final pct = spent / limit * 100;
      if (pct >= thresholdPct) {
        lines.add('$name: ${pct.clamp(0, 999).toStringAsFixed(0)}%');
      }
    }
    return lines;
  }
}
