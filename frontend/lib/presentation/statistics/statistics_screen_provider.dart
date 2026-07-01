import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/domain/services/financial_date_utils.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/getit_init.dart';

enum StatisticsPeriod { week, month, quarter, year }

extension StatisticsPeriodX on StatisticsPeriod {
  String get label => switch (this) {
        StatisticsPeriod.week => AppStrings.statsPeriodWeek,
        StatisticsPeriod.month => AppStrings.statsPeriodMonth,
        StatisticsPeriod.quarter => AppStrings.statsPeriodQuarter,
        StatisticsPeriod.year => AppStrings.statsPeriodYear,
      };

  int get dayCount => switch (this) {
        StatisticsPeriod.week => 7,
        StatisticsPeriod.month => 30,
        StatisticsPeriod.quarter => 90,
        StatisticsPeriod.year => 365,
      };
}

class StatisticsTrendPoint {
  const StatisticsTrendPoint({required this.label, required this.amount});

  final String label;
  final double amount;
}

class StatisticsKpiTrend {
  const StatisticsKpiTrend({
    required this.percentChange,
    required this.isPositiveGood,
  });

  final double percentChange;
  final bool isPositiveGood;

  bool get isUp => percentChange > 0;
  bool get isNeutral => percentChange == 0;
}

class StatisticsScreenData {
  const StatisticsScreenData({
    this.isLoading = true,
    this.errorMessage,
    this.period = StatisticsPeriod.month,
    this.trendPoints = const [],
    this.expenseByCategory = const {},
    this.totalExpense = 0,
    this.dailyAverage = 0,
    this.highestExpense = 0,
    this.transactionCount = 0,
    this.totalExpenseTrend = const StatisticsKpiTrend(
      percentChange: 0,
      isPositiveGood: true,
    ),
    this.dailyAverageTrend = const StatisticsKpiTrend(
      percentChange: 0,
      isPositiveGood: true,
    ),
    this.highestExpenseTrend = const StatisticsKpiTrend(
      percentChange: 0,
      isPositiveGood: true,
    ),
    this.transactionCountTrend = const StatisticsKpiTrend(
      percentChange: 0,
      isPositiveGood: false,
    ),
  });

  final bool isLoading;
  final String? errorMessage;
  final StatisticsPeriod period;
  final List<StatisticsTrendPoint> trendPoints;
  final Map<String, double> expenseByCategory;
  final double totalExpense;
  final double dailyAverage;
  final double highestExpense;
  final int transactionCount;
  final StatisticsKpiTrend totalExpenseTrend;
  final StatisticsKpiTrend dailyAverageTrend;
  final StatisticsKpiTrend highestExpenseTrend;
  final StatisticsKpiTrend transactionCountTrend;

  bool get isEmpty =>
      !isLoading &&
      errorMessage == null &&
      totalExpense == 0 &&
      expenseByCategory.isEmpty &&
      transactionCount == 0;

  StatisticsScreenData copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    StatisticsPeriod? period,
    List<StatisticsTrendPoint>? trendPoints,
    Map<String, double>? expenseByCategory,
    double? totalExpense,
    double? dailyAverage,
    double? highestExpense,
    int? transactionCount,
    StatisticsKpiTrend? totalExpenseTrend,
    StatisticsKpiTrend? dailyAverageTrend,
    StatisticsKpiTrend? highestExpenseTrend,
    StatisticsKpiTrend? transactionCountTrend,
  }) {
    return StatisticsScreenData(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      period: period ?? this.period,
      trendPoints: trendPoints ?? this.trendPoints,
      expenseByCategory: expenseByCategory ?? this.expenseByCategory,
      totalExpense: totalExpense ?? this.totalExpense,
      dailyAverage: dailyAverage ?? this.dailyAverage,
      highestExpense: highestExpense ?? this.highestExpense,
      transactionCount: transactionCount ?? this.transactionCount,
      totalExpenseTrend: totalExpenseTrend ?? this.totalExpenseTrend,
      dailyAverageTrend: dailyAverageTrend ?? this.dailyAverageTrend,
      highestExpenseTrend: highestExpenseTrend ?? this.highestExpenseTrend,
      transactionCountTrend: transactionCountTrend ?? this.transactionCountTrend,
    );
  }
}

final statisticsScreenProvider =
    StateNotifierProvider<StatisticsScreenNotifier, StatisticsScreenData>(
  (ref) => StatisticsScreenNotifier(),
);

class StatisticsScreenNotifier extends StateNotifier<StatisticsScreenData> {
  StatisticsScreenNotifier() : super(const StatisticsScreenData()) {
    load();
  }

  final DbHelper _db = getIt<DbHelper>();

  Future<void> setPeriod(StatisticsPeriod period) async {
    if (period == state.period && !state.isLoading) {
      await load(force: true);
      return;
    }
    state = state.copyWith(period: period, isLoading: true, clearError: true);
    await load(force: true);
  }

  Future<void> load({bool force = false}) async {
    if (!force && !state.isLoading && state.errorMessage == null && !state.isEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final period = state.period;
      final current = _dateRange(period, DateTime.now());
      final previous = _previousRange(current, period.dayCount);

      final currentMetrics = await _loadMetrics(current.start, current.end);
      final previousMetrics = await _loadMetrics(previous.start, previous.end);
      final trendRaw = await _loadDailyTotals(current.start, current.end);
      final categories = await _loadCategoryTotals(current.start, current.end);

      final trendPoints = _bucketTrend(period, current.start, current.end, trendRaw);
      final days = period.dayCount.clamp(1, 366);

      state = StatisticsScreenData(
        isLoading: false,
        period: period,
        trendPoints: trendPoints,
        expenseByCategory: categories,
        totalExpense: currentMetrics.totalExpense,
        dailyAverage: currentMetrics.totalExpense / days,
        highestExpense: currentMetrics.highestExpense,
        transactionCount: currentMetrics.transactionCount,
        totalExpenseTrend: _trend(
          currentMetrics.totalExpense,
          previousMetrics.totalExpense,
          lowerIsBetter: true,
        ),
        dailyAverageTrend: _trend(
          currentMetrics.totalExpense / days,
          previousMetrics.totalExpense / days,
          lowerIsBetter: true,
        ),
        highestExpenseTrend: _trend(
          currentMetrics.highestExpense,
          previousMetrics.highestExpense,
          lowerIsBetter: true,
        ),
        transactionCountTrend: _trend(
          currentMetrics.transactionCount.toDouble(),
          previousMetrics.transactionCount.toDouble(),
          lowerIsBetter: false,
        ),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.statsScreenLoadFailed,
      );
    }
  }

  StatisticsKpiTrend _trend(
    double current,
    double previous, {
    required bool lowerIsBetter,
  }) {
    final delta = previous == 0
        ? (current == 0 ? 0.0 : 100.0)
        : ((current - previous) / previous) * 100;
    final improved = lowerIsBetter ? delta < 0 : delta > 0;
    return StatisticsKpiTrend(
      percentChange: delta,
      isPositiveGood: improved || delta == 0,
    );
  }

  ({String start, String end}) _dateRange(StatisticsPeriod period, DateTime end) {
    final endDate = DateTime(end.year, end.month, end.day);
    final startDate = endDate.subtract(Duration(days: period.dayCount - 1));
    return (
      start: FinancialDateUtils.isoDate(startDate),
      end: FinancialDateUtils.isoDate(endDate),
    );
  }

  ({String start, String end}) _previousRange(
    ({String start, String end}) current,
    int dayCount,
  ) {
    final currentStart = DateTime.parse(current.start);
    final prevEnd = currentStart.subtract(const Duration(days: 1));
    final prevStart = prevEnd.subtract(Duration(days: dayCount - 1));
    return (
      start: FinancialDateUtils.isoDate(prevStart),
      end: FinancialDateUtils.isoDate(prevEnd),
    );
  }

  Future<({
    double totalExpense,
    double highestExpense,
    int transactionCount,
  })> _loadMetrics(String start, String end) async {
    final result = await _db.complexQuery(
      table: 'transactions',
      columns: [
        'SUM(amount) as total',
        'MAX(amount) as highest',
        'COUNT(*) as count',
      ],
      where: "type = 'expense' AND date(date) BETWEEN date(?) AND date(?)",
      whereArgs: [start, end],
    );

    return result.fold(
      (_) => (totalExpense: 0.0, highestExpense: 0.0, transactionCount: 0),
      (rows) {
        final row = rows.first;
        return (
          totalExpense: (row['total'] as num?)?.toDouble() ?? 0.0,
          highestExpense: (row['highest'] as num?)?.toDouble() ?? 0.0,
          transactionCount: (row['count'] as num?)?.toInt() ?? 0,
        );
      },
    );
  }

  Future<Map<String, double>> _loadDailyTotals(String start, String end) async {
    final result = await _db.complexQuery(
      table: 'transactions',
      columns: ['date(date) as day', 'SUM(amount) as total'],
      where: "type = 'expense' AND date(date) BETWEEN date(?) AND date(?)",
      whereArgs: [start, end],
      groupBy: 'day',
      orderBy: 'day ASC',
    );

    return result.fold(
      (_) => <String, double>{},
      (rows) => {
        for (final r in rows)
          r['day'] as String: (r['total'] as num).toDouble(),
      },
    );
  }

  Future<Map<String, double>> _loadCategoryTotals(String start, String end) async {
    final result = await _db.complexQuery(
      table: 'transactions t',
      columns: [
        "COALESCE(c.name, '${EntityLocalizations.categoryOtherDbName}') as category",
        'SUM(t.amount) as total',
      ],
      joinClause: 'LEFT JOIN categories c ON t.category_id = c.id',
      where: "t.type = 'expense' AND date(t.date) BETWEEN date(?) AND date(?)",
      whereArgs: [start, end],
      groupBy: 'category',
      orderBy: 'total DESC',
    );

    return result.fold(
      (_) => <String, double>{},
      (rows) => {
        for (final r in rows)
          r['category'] as String: (r['total'] as num).toDouble(),
      },
    );
  }

  List<StatisticsTrendPoint> _bucketTrend(
    StatisticsPeriod period,
    String startIso,
    String endIso,
    Map<String, double> daily,
  ) {
    final start = DateTime.parse(startIso);
    final end = DateTime.parse(endIso);

    switch (period) {
      case StatisticsPeriod.week:
        final weekday = AppStrings.statsChartWeekdays;
        return List.generate(7, (i) {
          final day = start.add(Duration(days: i));
          final key = FinancialDateUtils.isoDate(day);
          return StatisticsTrendPoint(
            label: weekday[day.weekday % 7],
            amount: daily[key] ?? 0,
          );
        });

      case StatisticsPeriod.month:
        const weekLabels = ['1', '2', '3', '4', '5'];
        return List.generate(5, (i) {
          final bucketStart = start.add(Duration(days: i * 6));
          var total = 0.0;
          for (var d = 0; d < 6; d++) {
            final date = bucketStart.add(Duration(days: d));
            if (date.isAfter(end)) break;
            total += daily[FinancialDateUtils.isoDate(date)] ?? 0;
          }
          return StatisticsTrendPoint(
            label: weekLabels[i],
            amount: total,
          );
        });

      case StatisticsPeriod.quarter:
        final months = AppStrings.statsChartMonthsShort;
        return List.generate(3, (i) {
          final month = DateTime(start.year, start.month + i, 1);
          final monthEnd = DateTime(month.year, month.month + 1, 0);
          var total = 0.0;
          for (var d = 0; d < monthEnd.day; d++) {
            final date = DateTime(month.year, month.month, d + 1);
            if (date.isBefore(start) || date.isAfter(end)) continue;
            total += daily[FinancialDateUtils.isoDate(date)] ?? 0;
          }
          return StatisticsTrendPoint(
            label: months[month.month - 1],
            amount: total,
          );
        });

      case StatisticsPeriod.year:
        final months = AppStrings.statsChartMonthsShort;
        return List.generate(12, (i) {
          final month = DateTime(end.year, end.month - 11 + i, 1);
          if (month.isAfter(end)) {
            return StatisticsTrendPoint(label: '', amount: 0);
          }
          final monthEnd = DateTime(month.year, month.month + 1, 0);
          var total = 0.0;
          for (var d = 0; d < monthEnd.day; d++) {
            final date = DateTime(month.year, month.month, d + 1);
            if (date.isBefore(start) || date.isAfter(end)) continue;
            total += daily[FinancialDateUtils.isoDate(date)] ?? 0;
          }
          return StatisticsTrendPoint(
            label: months[month.month - 1],
            amount: total,
          );
        });
    }
  }
}
