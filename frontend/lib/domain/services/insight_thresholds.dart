/// Named thresholds for spending alerts and insight scoring.
///
/// Values are chosen for a Saudi personal-finance context: monthly salary
/// cycles and common 10–30% savings guidance from local budgeting advice.
class InsightThresholds {
  InsightThresholds._();

  /// Month-over-month spending increase that triggers a user alert (25%).
  /// Balances sensitivity with avoiding noise from small month-to-month swings.
  static const double monthOverMonthSpendingAlert = 0.25;

  /// Savings rate tiers used by dashboard, chatbot, and health score (fraction).
  static const double savingsRateGood = 0.10;
  static const double savingsRateVeryGood = 0.20;
  static const double savingsRateExcellent = 0.30;

  /// Same as [savingsRateGood] but expressed as a percent for behavioral copy.
  static const double savingsRatePercentGood = 10;

  /// Expense-to-income ratio that marks a large transaction as critical.
  static const double largeExpenseIncomeCritical = 0.25;

  /// Expense-to-income ratio that flags a large transaction (warning tier).
  static const double largeExpenseIncomeRatio = 0.15;

  /// Minimum absolute amount (SAR) before large-transaction heuristics apply.
  static const double largeExpenseMinAmount = 500;

  /// Share of monthly spend in one category considered "high" in analysis copy.
  static const double highCategorySpendShare = 0.30;
}
