import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/domain/services/financial_date_utils.dart';
import 'package:mudabbir/service/getit_init.dart';

/// Shared transaction aggregations for home, statistics, and reports.
class FinancialAggregator {
  FinancialAggregator({DbHelper? db}) : _db = db ?? getIt<DbHelper>();

  final DbHelper _db;

  static const _balanceExpr =
      "SUM(CASE WHEN type = 'income' THEN amount WHEN type = 'expense' THEN -amount ELSE 0 END)";

  Future<double> sumByType(
    String type, {
    String? startDate,
    String? endDate,
    int? accountId,
  }) async {
    final clauses = <String>['type = ?'];
    final args = <dynamic>[type];

    if (startDate != null && endDate != null) {
      clauses.add('date(date) BETWEEN date(?) AND date(?)');
      args.addAll([startDate, endDate]);
    }
    if (accountId != null) {
      clauses.add('account_id = ?');
      args.add(accountId);
    }

    final result = await _db.complexQuery(
      table: 'transactions',
      columns: ['SUM(amount) as total'],
      where: clauses.join(' AND '),
      whereArgs: args,
    );

    return result.fold(
      (_) => 0.0,
      (rows) => (rows.first['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Future<double> ledgerBalance({int? accountId}) async {
    final clauses = <String>[];
    final args = <dynamic>[];
    if (accountId != null) {
      clauses.add('account_id = ?');
      args.add(accountId);
    } else {
      clauses.add('1 = ?');
      args.add(1);
    }

    final result = await _db.complexQuery(
      table: 'transactions',
      columns: ['$_balanceExpr as balance'],
      where: clauses.join(' AND '),
      whereArgs: args,
    );

    return result.fold(
      (_) => 0.0,
      (rows) => (rows.first['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Future<Map<String, double>> balancesPerAccount() async {
    final result = await _db.complexQuery(
      table: 'accounts a',
      columns: [
        'a.name as name',
        'COALESCE($_balanceExpr, 0) as balance',
      ],
      joinClause: 'LEFT JOIN transactions t ON t.account_id = a.id',
      groupBy: 'a.id, a.name',
    );

    return result.fold(
      (_) => <String, double>{},
      (rows) => {
        for (final r in rows)
          r['name'] as String: (r['balance'] as num?)?.toDouble() ?? 0.0,
      },
    );
  }

  Future<double> expensesInRange({
    required int accountId,
    required String startDate,
    required String endDate,
  }) =>
      sumByType(
        'expense',
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
      );

  Future<void> syncAccountBalanceColumn() async {
    final accounts = await _db.queryAllRows('accounts');
    await accounts.fold((_) async {}, (rows) async {
      for (final row in rows) {
        final id = row['id'] as int;
        final balance = await ledgerBalance(accountId: id);
        await _db.update('accounts', {'balance': balance}, 'id = ?', [id]);
      }
    });
  }

  ({String start, String end}) currentMonthRange() =>
      FinancialDateUtils.monthRange(DateTime.now());
}
