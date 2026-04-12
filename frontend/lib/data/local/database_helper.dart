import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/local/empty.dart';
import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class DbHelper {
  final LocalDatabase _localDatabase;

  DbHelper(this._localDatabase);

  /// CREATE
  /// Inserts a row into the specified table.
  /// Returns the id of the last inserted row.
  Future<int> insert(String table, Map<String, dynamic> data) async {
    Database db = await _localDatabase.database;
    return await db.insert(table, data);
  }

  Future<Database> get database => _localDatabase.database;

  /// READ (All Rows) - MODIFIED
  /// Returns Right(List<Map>) on success, or Left(Empty) if no rows are found.
  Future<Either<Empty, List<Map<String, dynamic>>>> queryAllRows(
    String table,
  ) async {
    Database db = await _localDatabase.database;
    final result = await db.query(table);

    if (result.isEmpty) {
      return Left(Empty()); // Return Left on empty result
    } else {
      return Right(result); // Return Right on success
    }
  }

  /// UPDATE
  /// Updates a row in the table.
  /// The `where` argument specifies which row to update.
  /// Returns the number of rows affected.
  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List<dynamic> whereArgs,
  ) async {
    Database db = await _localDatabase.database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  /// DELETE
  /// Deletes a row from the table.
  /// The `where` argument specifies which row to delete.
  /// Returns the number of rows deleted.
  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    Database db = await _localDatabase.database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// READ (Single Row)
  /// Retrieves a specific row based on the where condition.
  Future<Either<Empty, List<Map<String, dynamic>>>> queryRow(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    Database db = await _localDatabase.database;
    final result = await db.query(table, where: where, whereArgs: whereArgs);

    if (result.isEmpty) {
      return Left(Empty());
    } else {
      return Right(result);
    }
  }
  // Add this method inside your PostsDbHelper class

  /// GENERAL-PURPOSE COMPLEX QUERY
  /// Builds and executes a raw SQL query with optional clauses.
  /// Ideal for queries involving JOINs, specific column selections, and ordering.
  Future<Either<Empty, List<Map<String, dynamic>>>> complexQuery({
    required String table,
    List<String>? columns,
    String? joinClause,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? orderBy,
    int? limit,
  }) async {
    final selectedColumns = columns?.join(', ') ?? '*';
    var sql = 'SELECT $selectedColumns FROM $table';
    if (joinClause != null && joinClause.isNotEmpty) sql += ' $joinClause';
    if (where != null && where.isNotEmpty) sql += ' WHERE $where';
    if (groupBy != null && groupBy.isNotEmpty) sql += ' GROUP BY $groupBy';
    if (orderBy != null && orderBy.isNotEmpty) sql += ' ORDER BY $orderBy';
    if (limit != null) sql += ' LIMIT $limit';

    Database db = await _localDatabase.database;
    final result = await db.rawQuery(sql, whereArgs);

    if (result.isEmpty) {
      return Left(Empty());
    } else {
      return Right(result);
    }
  }

  Future<Either<String, List<Map<String, dynamic>>>> getBudgetsForAccount(
    int accountId,
    String date,
  ) async {
    try {
      final Database db = await _localDatabase.database;

      final String sql =
          'SELECT id, amount, start_date, end_date FROM budgets WHERE account_id = ? AND ? BETWEEN start_date AND end_date';

      final result = await db.rawQuery(sql, [accountId, date]);

      if (result.isEmpty) {
        return Left('No budgets found');
      } else {
        return Right(result);
      }
    } catch (e) {
      return Left('Database query failed: $e');
    }
  }
}
