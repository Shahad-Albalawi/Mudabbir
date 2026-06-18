import 'package:mudabbir/domain/services/insight_thresholds.dart';
import 'package:mudabbir/presentation/statistics/statistics_viewmodel.dart';

/// Single source of truth for the 0–100 financial health score.
///
/// Weighting (max 100):
/// - Savings rate: 40 pts — primary discipline signal.
/// - Balance cushion vs income: 30 pts — runway / liquidity.
/// - Category diversity: 20 pts — concentration risk.
/// - Goals progress: 10 pts — intentional saving behavior.
class HealthScoreCalculator {
  HealthScoreCalculator._();

  static double calculate({
    required double totalIncome,
    required double totalExpense,
    required double currentBalance,
    Map<String, double> expenseByCategory = const {},
    Map<String, double> goalsProgress = const {},
  }) {
    if (totalIncome <= 0 && totalExpense <= 0) {
      return 0;
    }

    final savingsRate = totalIncome <= 0
        ? 0.0
        : ((totalIncome - totalExpense) / totalIncome) * 100;

    var score = 0.0;

    if (savingsRate >= InsightThresholds.savingsRateExcellent * 100) {
      score += 40;
    } else if (savingsRate >= InsightThresholds.savingsRateVeryGood * 100) {
      score += 35;
    } else if (savingsRate >= InsightThresholds.savingsRateGood * 100) {
      score += 25;
    } else if (savingsRate >= 5) {
      score += 15;
    } else if (savingsRate >= 0) {
      score += 5;
    }

    if (totalIncome > 0) {
      if (currentBalance >= totalIncome * 0.5) {
        score += 30;
      } else if (currentBalance >= totalIncome * 0.3) {
        score += 25;
      } else if (currentBalance >= totalIncome * 0.1) {
        score += 15;
      } else if (currentBalance > 0) {
        score += 10;
      }
    }

    final categoryCount = expenseByCategory.length;
    if (categoryCount >= 5) {
      score += 20;
    } else if (categoryCount >= 3) {
      score += 15;
    } else if (categoryCount >= 2) {
      score += 10;
    } else if (categoryCount >= 1) {
      score += 5;
    }

    if (goalsProgress.isNotEmpty) {
      final avgProgress =
          goalsProgress.values.fold(0.0, (a, b) => a + b) / goalsProgress.length;
      if (avgProgress >= 75) {
        score += 10;
      } else if (avgProgress >= 50) {
        score += 7;
      } else if (avgProgress >= 25) {
        score += 5;
      } else {
        score += 2;
      }
    }

    if (totalIncome > 0 && totalExpense > totalIncome) {
      score -= 15;
    }

    return score.clamp(0, 100);
  }

  /// Monthly slice used by home dashboard and chatbot (no category/goals data).
  static int fromMonthly({
    required double monthlyIncome,
    required double monthlyExpense,
  }) {
    return calculate(
      totalIncome: monthlyIncome,
      totalExpense: monthlyExpense,
      currentBalance: monthlyIncome - monthlyExpense,
    ).round();
  }

  static double fromStatistics(
    StatisticsState statistics,
    double savingsRatePercent,
  ) {
    return calculate(
      totalIncome: statistics.totalIncome,
      totalExpense: statistics.totalExpense,
      currentBalance: statistics.currentBalance,
      expenseByCategory: statistics.expenseByCategory,
      goalsProgress: statistics.goalsProgress,
    );
  }
}
