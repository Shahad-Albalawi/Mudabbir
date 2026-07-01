import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/domain/models/behavioral_snapshot.dart';
import 'package:mudabbir/domain/services/behavioral_analysis_engine.dart';
import 'package:mudabbir/presentation/statistics/statistics_viewmodel.dart';

void main() {
  group('BehavioralAnalysisEngine', () {
    test('scores disciplined month highly with no anomalies', () {
      final raw = BehavioralRawData(
        currentMonthIncome: 10000,
        currentMonthExpense: 6000,
        previousMonthExpense: 7000,
        trailingThreeMonthAvgExpense: 6800,
        currentMonthExpenseByCategory: const {'Food': 2000, 'Transport': 1500},
        previousMonthExpenseByCategory: const {'Food': 2200, 'Transport': 1400},
        weekdayExpenseTotals: const {1: 1000, 2: 900, 3: 800, 4: 700, 5: 600},
        currentMonthExpenseAmounts: const [200, 150, 100],
        currentMonthTransactionCount: 5,
      );

      final snapshot = BehavioralAnalysisEngine.build(
        raw: raw,
        statistics: StatisticsState(
          goalsProgress: const {'Emergency': 60},
        ),
      );

      expect(snapshot.behavioralScore, greaterThanOrEqualTo(70));
      expect(snapshot.anomalies, isEmpty);
      expect(snapshot.personalizedRecommendations, isNotEmpty);
    });

    test('detects monthly spike and overspending anomalies', () {
      final raw = BehavioralRawData(
        currentMonthIncome: 5000,
        currentMonthExpense: 9000,
        previousMonthExpense: 4500,
        trailingThreeMonthAvgExpense: 4800,
        currentMonthExpenseByCategory: const {'Shopping': 5000},
        previousMonthExpenseByCategory: const {'Shopping': 1200},
        weekdayExpenseTotals: const {6: 3000, 7: 2500},
        currentMonthExpenseAmounts: const [2500, 1800, 900],
        currentMonthTransactionCount: 20,
      );

      final snapshot = BehavioralAnalysisEngine.build(
        raw: raw,
        statistics: StatisticsState(),
      );

      expect(snapshot.behavioralScore, lessThan(55));
      expect(
        snapshot.anomalies.map((a) => a.type),
        containsAll([
          AnomalyType.overspending,
          AnomalyType.monthlySpike,
          AnomalyType.categorySpike,
        ]),
      );
    });

    test('builds six-month trend from raw data', () {
      final trend = [
        for (var i = 0; i < 6; i++)
          MonthlySpendingPoint(
            monthKey: '2026-0${i + 1}',
            label: 'M$i',
            income: 1000,
            expense: 500 + (i * 100),
          ),
      ];

      final raw = BehavioralRawData(
        currentMonthIncome: 1000,
        currentMonthExpense: 1000,
        monthlyTrend: trend,
      );

      final snapshot = BehavioralAnalysisEngine.build(
        raw: raw,
        statistics: StatisticsState(),
      );

      expect(snapshot.monthlyTrend.length, 6);
      expect(snapshot.monthComparisonSummary, isNotEmpty);
    });
  });
}
