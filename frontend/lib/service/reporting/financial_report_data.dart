/// Structured payload for the monthly Mudabbir PDF report.
class FinancialReportData {
  final String userName;
  final DateTime period;
  final DateTime generatedAt;
  final double income;
  final double expense;
  final double balance;
  final int healthScore;
  final double savingsRate;
  final double totalAccountBalance;
  final List<String> alerts;
  final Map<String, double> categoryBreakdown;
  final List<ReportGoal> goals;
  final double? monthlyBudget;
  final double budgetUsedPercent;
  final List<ReportTransaction> transactions;
  final List<ReportSubscription> subscriptions;

  const FinancialReportData({
    required this.userName,
    required this.period,
    required this.generatedAt,
    required this.income,
    required this.expense,
    required this.balance,
    required this.healthScore,
    required this.savingsRate,
    required this.totalAccountBalance,
    required this.alerts,
    required this.categoryBreakdown,
    required this.goals,
    this.monthlyBudget,
    required this.budgetUsedPercent,
    required this.transactions,
    required this.subscriptions,
  });
}

class ReportGoal {
  final String name;
  final double target;
  final double current;
  final double progressPercent;
  final String? endDate;

  const ReportGoal({
    required this.name,
    required this.target,
    required this.current,
    required this.progressPercent,
    this.endDate,
  });
}

class ReportTransaction {
  final String date;
  final String category;
  final String type;
  final double amount;
  final String? notes;

  const ReportTransaction({
    required this.date,
    required this.category,
    required this.type,
    required this.amount,
    this.notes,
  });
}

class ReportSubscription {
  final String label;
  final int count;
  final double avgAmount;

  const ReportSubscription({
    required this.label,
    required this.count,
    required this.avgAmount,
  });
}
