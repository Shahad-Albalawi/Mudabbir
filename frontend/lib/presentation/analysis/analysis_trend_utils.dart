import 'package:mudabbir/domain/models/behavioral_snapshot.dart';
import 'package:mudabbir/presentation/statistics/statistics_screen_provider.dart';

/// Month-over-month KPI deltas derived from the 6-month trend series.
class AnalysisDashboardTrends {
  const AnalysisDashboardTrends({
    required this.income,
    required this.expense,
    required this.netSavings,
    required this.savingsRate,
  });

  final StatisticsKpiTrend income;
  final StatisticsKpiTrend expense;
  final StatisticsKpiTrend netSavings;
  final StatisticsKpiTrend savingsRate;

  static const zero = AnalysisDashboardTrends(
    income: StatisticsKpiTrend(percentChange: 0, isPositiveGood: true),
    expense: StatisticsKpiTrend(percentChange: 0, isPositiveGood: true),
    netSavings: StatisticsKpiTrend(percentChange: 0, isPositiveGood: true),
    savingsRate: StatisticsKpiTrend(percentChange: 0, isPositiveGood: true),
  );

  factory AnalysisDashboardTrends.fromMonthlyTrend(
    List<MonthlySpendingPoint> points,
    double currentSavingsRate,
  ) {
    if (points.length < 2) return zero;

    final current = points.last;
    final previous = points[points.length - 2];

    final prevNet = previous.income - previous.expense;
    final curNet = current.income - current.expense;

    final prevRate = previous.income <= 0
        ? 0.0
        : (prevNet / previous.income) * 100;

    return AnalysisDashboardTrends(
      income: _trend(current.income, previous.income, lowerIsBetter: false),
      expense: _trend(current.expense, previous.expense, lowerIsBetter: true),
      netSavings: _trend(curNet, prevNet, lowerIsBetter: false),
      savingsRate: _trend(
        currentSavingsRate,
        prevRate,
        lowerIsBetter: false,
      ),
    );
  }

  static StatisticsKpiTrend _trend(
    double current,
    double previous, {
    required bool lowerIsBetter,
  }) {
    final delta = previous == 0
        ? (current == 0 ? 0.0 : 100.0)
        : ((current - previous) / previous.abs()) * 100;
    final improved = lowerIsBetter ? delta < 0 : delta > 0;
    return StatisticsKpiTrend(
      percentChange: delta,
      isPositiveGood: improved || delta == 0,
    );
  }
}
