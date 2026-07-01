import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/behavioral_snapshot.dart';
import 'package:mudabbir/domain/services/behavioral_analysis_engine.dart';
import 'package:mudabbir/domain/services/repository_guard.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/statistics/statistics_viewmodel.dart';
import 'package:mudabbir/service/getit_init.dart';

/// Loads monthly aggregates from SQLite and builds behavioral insights.
class BehavioralAnalysisRepository {
  final DbHelper _db = getIt<DbHelper>();

  Future<Either<Failure, BehavioralSnapshot>> buildSnapshot(
    StatisticsState statistics,
  ) {
    return guardRepository(() async {
      final raw = await _loadRawData();
      return BehavioralAnalysisEngine.build(
        raw: raw,
        statistics: statistics,
      );
    }, fallbackMessage: AppStrings.statsAnalysisSubtitle);
  }

  Future<BehavioralRawData> _loadRawData() async {
    final now = DateTime.now();
    final currentStart = DateTime(now.year, now.month, 1);
    final currentEnd = DateTime(now.year, now.month + 1, 0);
    final prevStart = DateTime(now.year, now.month - 1, 1);
    final prevEnd = DateTime(now.year, now.month, 0);

    final currentIncome = await _sumInRange(
      type: 'income',
      start: currentStart,
      end: currentEnd,
    );
    final currentExpense = await _sumInRange(
      type: 'expense',
      start: currentStart,
      end: currentEnd,
    );
    final previousExpense = await _sumInRange(
      type: 'expense',
      start: prevStart,
      end: prevEnd,
    );

    final monthlyTrend = <MonthlySpendingPoint>[];
    final trailingExpenses = <double>[];

    for (var i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final start = DateTime(monthDate.year, monthDate.month, 1);
      final end = DateTime(monthDate.year, monthDate.month + 1, 0);
      final income = await _sumInRange(type: 'income', start: start, end: end);
      final expense =
          await _sumInRange(type: 'expense', start: start, end: end);
      monthlyTrend.add(
        MonthlySpendingPoint(
          monthKey:
              '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}',
          label: _monthLabel(monthDate),
          income: income,
          expense: expense,
        ),
      );
      if (i >= 1 && i <= 3) {
        trailingExpenses.add(expense);
      }
    }

    final trailingAvg = trailingExpenses.isEmpty
        ? 0.0
        : trailingExpenses.reduce((a, b) => a + b) / trailingExpenses.length;

    final currentByCategory = await _expenseByCategory(
      start: currentStart,
      end: currentEnd,
    );
    final previousByCategory = await _expenseByCategory(
      start: prevStart,
      end: prevEnd,
    );

    final weekdayTotals = await _weekdayExpenseTotals(
      start: currentStart,
      end: currentEnd,
    );

    final amounts = await _expenseAmounts(
      start: currentStart,
      end: currentEnd,
    );
    final txnCount = await _transactionCount(
      start: currentStart,
      end: currentEnd,
    );

    return BehavioralRawData(
      currentMonthIncome: currentIncome,
      currentMonthExpense: currentExpense,
      previousMonthExpense: previousExpense,
      trailingThreeMonthAvgExpense: trailingAvg,
      monthlyTrend: monthlyTrend,
      currentMonthExpenseByCategory: currentByCategory,
      previousMonthExpenseByCategory: previousByCategory,
      weekdayExpenseTotals: weekdayTotals,
      currentMonthExpenseAmounts: amounts,
      currentMonthTransactionCount: txnCount,
    );
  }

  Future<double> _sumInRange({
    required String type,
    required DateTime start,
    required DateTime end,
  }) async {
    final result = await _db.complexQuery(
      table: 'transactions',
      columns: ['SUM(amount) as total'],
      where: 'type = ? AND date BETWEEN ? AND ?',
      whereArgs: [type, _isoDate(start), _isoDate(end)],
    );
    return result.fold(
      (_) => 0.0,
      (rows) => (rows.first['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Future<Map<String, double>> _expenseByCategory({
    required DateTime start,
    required DateTime end,
  }) async {
    final result = await _db.complexQuery(
      table: 'transactions t',
      columns: ['c.name as category', 'SUM(t.amount) as total'],
      joinClause: 'JOIN categories c ON t.category_id = c.id',
      where: 't.type = ? AND t.date BETWEEN ? AND ?',
      whereArgs: ['expense', _isoDate(start), _isoDate(end)],
      groupBy: 'c.name',
    );
    return result.fold(
      (_) => <String, double>{},
      (rows) => {
        for (final r in rows)
          r['category'] as String: (r['total'] as num).toDouble(),
      },
    );
  }

  Future<Map<int, double>> _weekdayExpenseTotals({
    required DateTime start,
    required DateTime end,
  }) async {
    final result = await _db.complexQuery(
      table: 'transactions',
      columns: ['date', 'amount'],
      where: 'type = ? AND date BETWEEN ? AND ?',
      whereArgs: ['expense', _isoDate(start), _isoDate(end)],
    );
    final totals = <int, double>{};
    result.fold((_) => null, (rows) {
      for (final row in rows) {
        final dateStr = row['date'] as String?;
        if (dateStr == null || dateStr.isEmpty) continue;
        final parsed = DateTime.tryParse(dateStr);
        if (parsed == null) continue;
        final weekday = parsed.weekday;
        totals[weekday] =
            (totals[weekday] ?? 0) + (row['amount'] as num).toDouble();
      }
    });
    return totals;
  }

  Future<List<double>> _expenseAmounts({
    required DateTime start,
    required DateTime end,
  }) async {
    final result = await _db.complexQuery(
      table: 'transactions',
      columns: ['amount'],
      where: 'type = ? AND date BETWEEN ? AND ?',
      whereArgs: ['expense', _isoDate(start), _isoDate(end)],
      orderBy: 'amount DESC',
    );
    return result.fold(
      (_) => <double>[],
      (rows) => rows
          .map((r) => (r['amount'] as num).toDouble())
          .toList(),
    );
  }

  Future<int> _transactionCount({
    required DateTime start,
    required DateTime end,
  }) async {
    final result = await _db.complexQuery(
      table: 'transactions',
      columns: ['COUNT(*) as count'],
      where: 'type = ? AND date BETWEEN ? AND ?',
      whereArgs: ['expense', _isoDate(start), _isoDate(end)],
    );
    return result.fold(
      (_) => 0,
      (rows) => (rows.first['count'] as num?)?.toInt() ?? 0,
    );
  }

  String _isoDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _monthLabel(DateTime date) {
    if (AppStrings.isEnglishLocale) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return months[date.month - 1];
    }
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[date.month - 1];
  }
}
