import 'package:mudabbir/domain/models/behavioral_snapshot.dart';
import 'package:mudabbir/presentation/resources/behavioral_strings.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/statistics/statistics_viewmodel.dart';

/// Pure scoring and anomaly detection from local aggregates.
class BehavioralAnalysisEngine {
  BehavioralAnalysisEngine._();

  static const double _spikeThreshold = 1.25;
  static const double _categorySpikeThreshold = 1.5;
  static const double _minCategorySpikeAmount = 100;
  static const double _largeTxnIncomeRatio = 0.15;
  static const double _largeTxnMinAmount = 500;
  static const double _weekendShareThreshold = 0.45;

  static BehavioralSnapshot build({
    required BehavioralRawData raw,
    required StatisticsState statistics,
  }) {
    final monthlySavingsRate = raw.currentMonthIncome <= 0
        ? 0.0
        : ((raw.currentMonthIncome - raw.currentMonthExpense) /
                raw.currentMonthIncome) *
            100;

    final anomalies = _detectAnomalies(raw);
    final behavioralScore = _calculateBehavioralScore(
      raw: raw,
      monthlySavingsRate: monthlySavingsRate,
      anomalyCount: anomalies.length,
      statistics: statistics,
    );

    return BehavioralSnapshot(
      behavioralScore: behavioralScore,
      behavioralRating: BehavioralStrings.ratingForScore(behavioralScore),
      monthlyTrend: raw.monthlyTrend,
      anomalies: anomalies,
      monthComparisonSummary: BehavioralStrings.monthComparisonSummary(
        currentExpense: raw.currentMonthExpense,
        previousExpense: raw.previousMonthExpense,
        trailingAvg: raw.trailingThreeMonthAvgExpense,
      ),
      weekdayInsight: _weekdayInsight(raw.weekdayExpenseTotals),
      personalizedRecommendations: _personalizedRecommendations(
        raw: raw,
        monthlySavingsRate: monthlySavingsRate,
        behavioralScore: behavioralScore,
        anomalies: anomalies,
        statistics: statistics,
      ),
    );
  }

  static int _calculateBehavioralScore({
    required BehavioralRawData raw,
    required double monthlySavingsRate,
    required int anomalyCount,
    required StatisticsState statistics,
  }) {
    var score = 0.0;

    if (monthlySavingsRate >= 30) {
      score += 35;
    } else if (monthlySavingsRate >= 20) {
      score += 30;
    } else if (monthlySavingsRate >= 10) {
      score += 22;
    } else if (monthlySavingsRate >= 5) {
      score += 12;
    } else if (monthlySavingsRate >= 0) {
      score += 5;
    }

    if (raw.trailingThreeMonthAvgExpense > 0) {
      final ratio = raw.currentMonthExpense / raw.trailingThreeMonthAvgExpense;
      if (ratio <= 0.9) {
        score += 25;
      } else if (ratio <= 1.05) {
        score += 20;
      } else if (ratio <= 1.15) {
        score += 12;
      } else if (ratio <= 1.25) {
        score += 6;
      }
    } else if (raw.currentMonthExpense == 0) {
      score += 15;
    }

    if (anomalyCount == 0) {
      score += 20;
    } else if (anomalyCount == 1) {
      score += 12;
    } else if (anomalyCount == 2) {
      score += 6;
    }

    if (raw.currentMonthExpense > 0) {
      final topCategoryShare = raw.currentMonthExpenseByCategory.values.isEmpty
          ? 0.0
          : raw.currentMonthExpenseByCategory.values.reduce(
                  (a, b) => a > b ? a : b,
                ) /
                raw.currentMonthExpense;
      if (topCategoryShare < 0.35) {
        score += 10;
      } else if (topCategoryShare < 0.5) {
        score += 6;
      } else if (topCategoryShare < 0.65) {
        score += 3;
      }
    }

    if (statistics.goalsProgress.isNotEmpty) {
      final avgProgress = statistics.goalsProgress.values.fold(0.0, (a, b) => a + b) /
          statistics.goalsProgress.length;
      if (avgProgress >= 75) {
        score += 10;
      } else if (avgProgress >= 50) {
        score += 7;
      } else if (avgProgress >= 25) {
        score += 4;
      }
    }

    return score.round().clamp(0, 100);
  }

  static List<SpendingAnomaly> _detectAnomalies(BehavioralRawData raw) {
    final anomalies = <SpendingAnomaly>[];

    if (raw.trailingThreeMonthAvgExpense > 0 &&
        raw.currentMonthExpense >
            raw.trailingThreeMonthAvgExpense * _spikeThreshold) {
      final pct = ((raw.currentMonthExpense / raw.trailingThreeMonthAvgExpense) -
              1) *
          100;
      anomalies.add(
        SpendingAnomaly(
          type: AnomalyType.monthlySpike,
          severity: pct >= 40 ? AnomalySeverity.critical : AnomalySeverity.warning,
          titleKey: 'monthlySpikeTitle',
          messageKey: 'monthlySpikeMessage',
          params: {
            'pct': pct.toStringAsFixed(0),
            'amount': raw.currentMonthExpense.toStringAsFixed(0),
          },
        ),
      );
    }

    if (raw.currentMonthIncome > 0 &&
        raw.currentMonthExpense > raw.currentMonthIncome) {
      anomalies.add(
        SpendingAnomaly(
          type: AnomalyType.overspending,
          severity: AnomalySeverity.critical,
          titleKey: 'overspendingTitle',
          messageKey: 'overspendingMessage',
          params: {
            'gap': (raw.currentMonthExpense - raw.currentMonthIncome)
                .toStringAsFixed(0),
          },
        ),
      );
    }

    raw.currentMonthExpenseByCategory.forEach((category, amount) {
      final prev = raw.previousMonthExpenseByCategory[category] ?? 0;
      if (prev >= _minCategorySpikeAmount &&
          amount > prev * _categorySpikeThreshold) {
        final pct = ((amount / prev) - 1) * 100;
        anomalies.add(
          SpendingAnomaly(
            type: AnomalyType.categorySpike,
            severity:
                pct >= 80 ? AnomalySeverity.critical : AnomalySeverity.warning,
            titleKey: 'categorySpikeTitle',
            messageKey: 'categorySpikeMessage',
            params: {
              'category': EntityLocalizations.categoryName(category),
              'pct': pct.toStringAsFixed(0),
            },
          ),
        );
      }
    });

    if (raw.currentMonthExpenseAmounts.isNotEmpty && raw.currentMonthIncome > 0) {
      final sorted = List<double>.from(raw.currentMonthExpenseAmounts)..sort();
      final median = sorted[sorted.length ~/ 2];
      for (final amount in raw.currentMonthExpenseAmounts) {
        final incomeRatio = amount / raw.currentMonthIncome;
        if (amount >= _largeTxnMinAmount &&
            (incomeRatio >= _largeTxnIncomeRatio ||
                (median > 0 && amount >= median * 3))) {
          anomalies.add(
            SpendingAnomaly(
              type: AnomalyType.largeTransaction,
              severity: incomeRatio >= 0.25
                  ? AnomalySeverity.critical
                  : AnomalySeverity.warning,
              titleKey: 'largeTransactionTitle',
              messageKey: 'largeTransactionMessage',
              params: {'amount': amount.toStringAsFixed(0)},
            ),
          );
          break;
        }
      }
    }

    final weekdayTotal = raw.weekdayExpenseTotals.entries
        .where((e) => e.key >= 1 && e.key <= 5)
        .fold(0.0, (sum, e) => sum + e.value);
    final weekendTotal = raw.weekdayExpenseTotals.entries
        .where((e) => e.key == 6 || e.key == 7)
        .fold(0.0, (sum, e) => sum + e.value);
    final weekTotal = weekdayTotal + weekendTotal;
    if (weekTotal > 0 && weekendTotal / weekTotal >= _weekendShareThreshold) {
      final pct = (weekendTotal / weekTotal) * 100;
      anomalies.add(
        SpendingAnomaly(
          type: AnomalyType.weekendSplurge,
          severity: AnomalySeverity.info,
          titleKey: 'weekendSplurgeTitle',
          messageKey: 'weekendSplurgeMessage',
          params: {'pct': pct.toStringAsFixed(0)},
        ),
      );
    }

    if (raw.currentMonthTransactionCount >= 8) {
      final daysElapsed = DateTime.now().day.clamp(1, 31);
      final dailyAvg = raw.currentMonthTransactionCount / daysElapsed;
      if (dailyAvg >= 1.5) {
        anomalies.add(
          SpendingAnomaly(
            type: AnomalyType.spendingBurst,
            severity: AnomalySeverity.info,
            titleKey: 'spendingBurstTitle',
            messageKey: 'spendingBurstMessage',
            params: {'count': raw.currentMonthTransactionCount.toString()},
          ),
        );
      }
    }

    anomalies.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return anomalies.take(5).toList();
  }

  static String _weekdayInsight(Map<int, double> weekdayTotals) {
    if (weekdayTotals.isEmpty) {
      return BehavioralStrings.noWeekdayData;
    }

    var topDay = 1;
    var topAmount = 0.0;
    weekdayTotals.forEach((day, amount) {
      if (amount > topAmount) {
        topAmount = amount;
        topDay = day;
      }
    });

    return BehavioralStrings.weekdayInsight(
      dayName: BehavioralStrings.weekdayName(topDay),
      amount: topAmount,
    );
  }

  static List<String> _personalizedRecommendations({
    required BehavioralRawData raw,
    required double monthlySavingsRate,
    required int behavioralScore,
    required List<SpendingAnomaly> anomalies,
    required StatisticsState statistics,
  }) {
    final recs = <String>[];

    for (final anomaly in anomalies.take(3)) {
      recs.add(BehavioralStrings.anomalyRecommendation(anomaly));
    }

    if (raw.previousMonthExpense > 0 &&
        raw.currentMonthExpense > raw.previousMonthExpense * 1.1) {
      recs.add(BehavioralStrings.recReduceVsLastMonth);
    } else if (raw.trailingThreeMonthAvgExpense > 0 &&
        raw.currentMonthExpense < raw.trailingThreeMonthAvgExpense * 0.9) {
      recs.add(BehavioralStrings.recKeepDiscipline);
    }

    if (monthlySavingsRate < 10 && raw.currentMonthIncome > 0) {
      recs.add(BehavioralStrings.recIncreaseSavings);
    }

    if (statistics.goalsProgress.isEmpty) {
      recs.add(BehavioralStrings.recSetGoals);
    }

    if (statistics.budgetsProgress.isEmpty) {
      recs.add(BehavioralStrings.recCreateBudget);
    }

    if (behavioralScore >= 75) {
      recs.add(BehavioralStrings.recGreatScore);
    }

    if (recs.isEmpty) {
      recs.add(BehavioralStrings.recDefault);
    }

    return recs.take(6).toList();
  }
}
