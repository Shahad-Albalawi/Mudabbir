import 'package:mudabbir/domain/models/behavioral_snapshot.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Behavioral analysis copy and formatting helpers.
class BehavioralCopyHelpers {
  BehavioralCopyHelpers._();

  static String get behavioralScoreTitle => AppStrings.behavioralScoreTitle;
  static String get behavioralScoreSubtitle => AppStrings.behavioralScoreSubtitle;
  static String get viewDetailsLabel => AppStrings.behavioralViewDetailsLabel;
  static String get viewDetailsHint => AppStrings.behavioralViewDetailsHint;
  static String get monthComparisonTitle =>
      AppStrings.behavioralMonthComparisonTitle;
  static String get anomaliesTitle => AppStrings.behavioralAnomaliesTitle;
  static String get noAnomalies => AppStrings.behavioralNoAnomalies;
  static String get weekdayPatternTitle =>
      AppStrings.behavioralWeekdayPatternTitle;
  static String get personalizedRecsTitle =>
      AppStrings.behavioralPersonalizedRecsTitle;
  static String get currentMonthLabel => AppStrings.thisMonth;
  static String get previousMonthLabel => AppStrings.behavioralPreviousMonthLabel;
  static String get trailingAvgLabel => AppStrings.behavioralTrailingAvgLabel;
  static String get noWeekdayData => AppStrings.behavioralNoWeekdayData;
  static String get recReduceVsLastMonth =>
      AppStrings.behavioralRecReduceVsLastMonth;
  static String get recKeepDiscipline => AppStrings.behavioralRecKeepDiscipline;
  static String get recIncreaseSavings => AppStrings.behavioralRecIncreaseSavings;
  static String get recSetGoals => AppStrings.behavioralRecSetGoals;
  static String get recCreateBudget => AppStrings.behavioralRecCreateBudget;
  static String get recGreatScore => AppStrings.behavioralRecGreatScore;
  static String get recDefault => AppStrings.behavioralRecDefault;

  static String formatAmount(double value) => AppCurrency.format(value);

  static String ratingForScore(int score) {
    if (score >= 85) return AppStrings.behavioralRatingExcellent;
    if (score >= 70) return AppStrings.behavioralRatingGood;
    if (score >= 55) return AppStrings.behavioralRatingFair;
    if (score >= 40) return AppStrings.behavioralRatingNeedsWork;
    return AppStrings.behavioralRatingAtRisk;
  }

  static String monthComparisonSummary({
    required double currentExpense,
    required double previousExpense,
    required double trailingAvg,
  }) {
    final current = formatAmount(currentExpense);
    final previous = formatAmount(previousExpense);
    final avg = formatAmount(trailingAvg);

    if (previousExpense <= 0 && trailingAvg <= 0) {
      return AppStrings.behavioralMonthCompareNoHistory(current);
    }
    if (previousExpense > 0) {
      final change = ((currentExpense / previousExpense) - 1) * 100;
      if (change > 10) {
        return AppStrings.behavioralMonthCompareUp(
          change.toStringAsFixed(0),
          current,
          previous,
        );
      }
      if (change < -10) {
        return AppStrings.behavioralMonthCompareDown(
          change.abs().toStringAsFixed(0),
        );
      }
      return AppStrings.behavioralMonthCompareStable(current, previous);
    }
    return AppStrings.behavioralMonthCompareTrailing(current, avg);
  }

  static String weekdayInsight({required String dayName, required double amount}) {
    return AppStrings.behavioralWeekdayInsight(
      dayName,
      formatAmount(amount),
    );
  }

  static String weekdayName(int weekday) {
    if (AppStrings.isEnglishLocale) {
      const names = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return names[(weekday - 1).clamp(0, 6)];
    }
    const names = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return names[(weekday - 1).clamp(0, 6)];
  }

  static String anomalyTitle(SpendingAnomaly anomaly) {
    switch (anomaly.titleKey) {
      case 'monthlySpikeTitle':
        return AppStrings.behavioralMonthlySpikeTitle;
      case 'overspendingTitle':
        return AppStrings.behavioralOverspendingTitle;
      case 'categorySpikeTitle':
        return AppStrings.behavioralCategorySpikeTitle;
      case 'largeTransactionTitle':
        return AppStrings.behavioralLargeTransactionTitle;
      case 'weekendSplurgeTitle':
        return AppStrings.behavioralWeekendSplurgeTitle;
      case 'spendingBurstTitle':
        return AppStrings.behavioralSpendingBurstTitle;
      default:
        return AppStrings.behavioralUnusualPatternTitle;
    }
  }

  static String anomalyMessage(SpendingAnomaly anomaly) {
    final p = anomaly.params;
    final amount = formatAmount(
      double.tryParse(p['amount'] ?? '0') ?? 0,
    );
    switch (anomaly.messageKey) {
      case 'monthlySpikeMessage':
        return AppStrings.behavioralMonthlySpikeMessage(
          p['pct'] ?? '',
          amount,
        );
      case 'overspendingMessage':
        return AppStrings.behavioralOverspendingMessage(
          formatAmount(double.tryParse(p['gap'] ?? '0') ?? 0),
        );
      case 'categorySpikeMessage':
        return AppStrings.behavioralCategorySpikeMessage(
          p['category'] ?? '',
          p['pct'] ?? '',
        );
      case 'largeTransactionMessage':
        return AppStrings.behavioralLargeTransactionMessage(amount);
      case 'weekendSplurgeMessage':
        return AppStrings.behavioralWeekendSplurgeMessage(p['pct'] ?? '');
      case 'spendingBurstMessage':
        return AppStrings.behavioralSpendingBurstMessage(p['count'] ?? '');
      default:
        return AppStrings.behavioralReviewPattern;
    }
  }

  static String anomalyRecommendation(SpendingAnomaly anomaly) {
    switch (anomaly.type) {
      case AnomalyType.monthlySpike:
        return AppStrings.behavioralRecMonthlySpike;
      case AnomalyType.overspending:
        return AppStrings.behavioralRecOverspending;
      case AnomalyType.categorySpike:
        return AppStrings.behavioralRecCategorySpike(
          anomaly.params['category'] ?? '',
        );
      case AnomalyType.largeTransaction:
        return AppStrings.behavioralRecLargeTransaction;
      case AnomalyType.weekendSplurge:
        return AppStrings.behavioralRecWeekendSplurge;
      case AnomalyType.spendingBurst:
        return AppStrings.behavioralRecSpendingBurst;
    }
  }
}
