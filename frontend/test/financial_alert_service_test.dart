import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/service/notifications/financial_alert_service.dart';

void main() {
  group('budgetAlertLevel', () {
    test('returns none when snapshot is null', () {
      expect(budgetAlertLevel(null), BudgetAlertLevel.none);
    });

    test('returns exceeded when over budget', () {
      const snapshot = BudgetSnapshot(
        budgetAmount: 1000,
        spentAmount: 1100,
        remaining: -100,
        isOverBudget: true,
      );
      expect(budgetAlertLevel(snapshot), BudgetAlertLevel.exceeded);
    });

    test('returns warning at 80% usage', () {
      const snapshot = BudgetSnapshot(
        budgetAmount: 1000,
        spentAmount: 800,
        remaining: 200,
        isOverBudget: false,
      );
      expect(budgetAlertLevel(snapshot), BudgetAlertLevel.warning);
    });

    test('returns none below 80%', () {
      const snapshot = BudgetSnapshot(
        budgetAmount: 1000,
        spentAmount: 500,
        remaining: 500,
        isOverBudget: false,
      );
      expect(budgetAlertLevel(snapshot), BudgetAlertLevel.none);
    });
  });
}
