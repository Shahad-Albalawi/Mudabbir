import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/domain/services/health_score_calculator.dart';
import 'package:mudabbir/domain/services/insight_thresholds.dart';

void main() {
  test('health score uses unified calculator for monthly summary', () {
    final score = HealthScoreCalculator.fromMonthly(
      monthlyIncome: 10000,
      monthlyExpense: 7000,
    );
    expect(score, greaterThan(0));
    expect(score, lessThanOrEqualTo(100));
  });

  test('insight thresholds expose documented savings rate', () {
    expect(InsightThresholds.savingsRateGood, 0.10);
    expect(InsightThresholds.monthOverMonthSpendingAlert, 0.25);
  });
}
