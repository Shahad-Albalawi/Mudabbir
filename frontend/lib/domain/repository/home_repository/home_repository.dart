import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/service/getit_init.dart';

class HomeRepository {
  final DbHelper _dbHelper = getIt<DbHelper>();

  /// Calculates the sum of all 'income' transactions.
  Future<double> getTotalIncome({String? startDate, String? endDate}) async {
    String? where;
    List<dynamic>? whereArgs;

    if (startDate != null && endDate != null) {
      where = 'type = ? AND date BETWEEN ? AND ?';
      whereArgs = ['income', startDate, endDate];
    } else {
      where = 'type = ?';
      whereArgs = ['income'];
    }

    final result = await _dbHelper.complexQuery(
      table: 'transactions',
      columns: ['SUM(amount) as total'],
      where: where,
      whereArgs: whereArgs,
    );

    return result.fold((left) => 0.0, (right) {
      final total = right.first['total'];
      return (total as num?)?.toDouble() ?? 0.0;
    });
  }

  /// Same for expense
  Future<double> getTotalExpense({String? startDate, String? endDate}) async {
    String? where;
    List<dynamic>? whereArgs;

    if (startDate != null && endDate != null) {
      where = 'type = ? AND date BETWEEN ? AND ?';
      whereArgs = ['expense', startDate, endDate];
    } else {
      where = 'type = ?';
      whereArgs = ['expense'];
    }

    final result = await _dbHelper.complexQuery(
      table: 'transactions',
      columns: ['SUM(amount) as total'],
      where: where,
      whereArgs: whereArgs,
    );

    return result.fold((left) => 0.0, (right) {
      final total = right.first['total'];
      return (total as num?)?.toDouble() ?? 0.0;
    });
  }
}
