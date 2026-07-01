import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/local/empty.dart';
import 'package:mudabbir/domain/models/budget_record.dart';
import 'package:mudabbir/domain/services/sync_policies.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:sqflite/sqflite.dart';

class BudgetRepository {
  DbHelper get _db => getIt<DbHelper>();

  Future<Either<Empty, List<Map<String, dynamic>>>> getBudgets() async {
    return _db.queryAllRows('budgets');
  }

  Future<int> removeBudget(int id) async {
    return await _db.delete('budgets', 'id=?', [id]);
  }

  Future<int> addBudget(Map<String, dynamic> data) async {
    return await _db.insert('budgets', data);
  }

  Future<BudgetRecord?> getBudgetById(int id) async {
    final rows = await _db.queryAllRows('budgets');
    return rows.fold<BudgetRecord?>(
      (_) => null,
      (list) {
        for (final row in list) {
          if ((row['id'] as num).toInt() == id) {
            return BudgetRecord.fromMap(row);
          }
        }
        return null;
      },
    );
  }

  Future<void> mergeServerBudgets(List<BudgetRecord> budgets) async {
    for (final budget in budgets) {
      await _db.insertOrReplace('budgets', {
        'id': budget.id,
        ...budget.toInsertMap(),
      });
    }
  }

  Future<void> replaceLocalBudgetId(int localId, BudgetRecord serverBudget) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('budgets', where: 'id = ?', whereArgs: [localId]);
      await txn.insert(
        'budgets',
        {
          'id': serverBudget.id,
          ...serverBudget.toInsertMap(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> pruneExceptServerIds(
    Set<int> serverIds,
    Set<int> protectedIds,
  ) async {
    final rowsResult = await _db.queryAllRows('budgets');
    await rowsResult.fold((_) async {}, (rows) async {
      final localIds = rows.map((r) => (r['id'] as num).toInt());
      final toRemove = idsToPrune(
        localIds: localIds,
        serverIds: serverIds,
        protectedIds: protectedIds,
      );
      for (final id in toRemove) {
        await _db.delete('budgets', 'id = ?', [id]);
      }
    });
  }

  Future<double> getSpentForPeriod({
    required int accountId,
    required String startDate,
    required String endDate,
  }) async {
    final result = await _db.complexQuery(
      table: 'transactions',
      columns: ['SUM(amount) as total'],
      where: 'type = ? AND account_id = ? AND date BETWEEN ? AND ?',
      whereArgs: ['expense', accountId, startDate, endDate],
    );
    return result.fold((_) => 0.0, (rows) {
      if (rows.isEmpty) return 0.0;
      return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
    });
  }

  Future<List<int>> listBudgetIds() async {
    final rowsResult = await _db.queryAllRows('budgets');
    return rowsResult.fold(
      (_) => <int>[],
      (rows) => rows.map((r) => (r['id'] as num).toInt()).toList(),
    );
  }
}
