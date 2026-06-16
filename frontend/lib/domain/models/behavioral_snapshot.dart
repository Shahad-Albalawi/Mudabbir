/// Monthly spending bucket used for trend comparison.
class MonthlySpendingPoint {
  final String monthKey;
  final String label;
  final double income;
  final double expense;

  const MonthlySpendingPoint({
    required this.monthKey,
    required this.label,
    required this.income,
    required this.expense,
  });
}

enum AnomalySeverity { info, warning, critical }

enum AnomalyType {
  monthlySpike,
  categorySpike,
  largeTransaction,
  weekendSplurge,
  overspending,
  spendingBurst,
}

/// Detected abnormal spending pattern with bilingual-ready payload.
class SpendingAnomaly {
  final AnomalyType type;
  final AnomalySeverity severity;
  final String titleKey;
  final String messageKey;
  final Map<String, String> params;

  const SpendingAnomaly({
    required this.type,
    required this.severity,
    required this.titleKey,
    required this.messageKey,
    this.params = const {},
  });
}

/// Raw aggregates fetched from SQLite before scoring.
class BehavioralRawData {
  final double currentMonthIncome;
  final double currentMonthExpense;
  final double previousMonthExpense;
  final double trailingThreeMonthAvgExpense;
  final List<MonthlySpendingPoint> monthlyTrend;
  final Map<String, double> currentMonthExpenseByCategory;
  final Map<String, double> previousMonthExpenseByCategory;
  final Map<int, double> weekdayExpenseTotals;
  final List<double> currentMonthExpenseAmounts;
  final int currentMonthTransactionCount;

  const BehavioralRawData({
    this.currentMonthIncome = 0,
    this.currentMonthExpense = 0,
    this.previousMonthExpense = 0,
    this.trailingThreeMonthAvgExpense = 0,
    this.monthlyTrend = const [],
    this.currentMonthExpenseByCategory = const {},
    this.previousMonthExpenseByCategory = const {},
    this.weekdayExpenseTotals = const {},
    this.currentMonthExpenseAmounts = const [],
    this.currentMonthTransactionCount = 0,
  });
}

/// Full behavioral analysis snapshot for the analysis screen.
class BehavioralSnapshot {
  final int behavioralScore;
  final String behavioralRating;
  final List<MonthlySpendingPoint> monthlyTrend;
  final List<SpendingAnomaly> anomalies;
  final String monthComparisonSummary;
  final String weekdayInsight;
  final List<String> personalizedRecommendations;

  const BehavioralSnapshot({
    this.behavioralScore = 0,
    this.behavioralRating = '',
    this.monthlyTrend = const [],
    this.anomalies = const [],
    this.monthComparisonSummary = '',
    this.weekdayInsight = '',
    this.personalizedRecommendations = const [],
  });
}
