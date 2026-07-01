import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Localized copy for [AnalysisLogic] / analysis screen outputs.
class AnalysisCopy {
  AnalysisCopy._();

  static String balanceAnalysis(double balance, double totalIncome) {
    final amount = balance.abs().toStringAsFixed(2);
    if (balance < 0) return AppStrings.analysisBalanceCritical(amount);
    if (balance == 0) return AppStrings.analysisBalanceZero;
    if (balance < totalIncome * 0.1) {
      return AppStrings.analysisBalanceLow(balance.toStringAsFixed(2));
    }
    if (balance < totalIncome * 0.3) {
      return AppStrings.analysisBalanceFair(balance.toStringAsFixed(2));
    }
    return AppStrings.analysisBalanceGreat(balance.toStringAsFixed(2));
  }

  static String spendingAnalysis(double expenseRatio) {
    final ratio = expenseRatio.toStringAsFixed(1);
    if (expenseRatio >= 100) return AppStrings.analysisSpendingCritical(ratio);
    if (expenseRatio >= 90) return AppStrings.analysisSpendingWarning90(ratio);
    if (expenseRatio >= 80) return AppStrings.analysisSpendingAlert80(ratio);
    if (expenseRatio >= 70) return AppStrings.analysisSpendingFair70(ratio);
    if (expenseRatio >= 50) return AppStrings.analysisSpendingGood50(ratio);
    return AppStrings.analysisSpendingExcellent(ratio);
  }

  static String savingsAnalysis(double savingsRate) {
    final rate = savingsRate.toStringAsFixed(1);
    if (savingsRate < 0) return AppStrings.analysisSavingsCritical(rate);
    if (savingsRate < 5) return AppStrings.analysisSavingsWeak5(rate);
    if (savingsRate < 10) return AppStrings.analysisSavingsFair10(rate);
    if (savingsRate < 20) return AppStrings.analysisSavingsGood20(rate);
    if (savingsRate < 30) return AppStrings.analysisSavingsExcellent30(rate);
    return AppStrings.analysisSavingsOutstanding(rate);
  }

  static String categoryInsight(double percentage) {
    final pct = percentage.toStringAsFixed(1);
    if (percentage >= 40) return AppStrings.analysisCategoryDominant40(pct);
    if (percentage >= 30) return AppStrings.analysisCategoryHigh30(pct);
    if (percentage >= 20) return AppStrings.analysisCategoryMedium20(pct);
    if (percentage >= 10) return AppStrings.analysisCategoryLow10(pct);
    return AppStrings.analysisCategoryVeryLow(pct);
  }

  static String healthRating(double score) {
    if (score >= 90) return AppStrings.analysisHealthExcellent;
    if (score >= 75) return AppStrings.analysisHealthGood;
    if (score >= 60) return AppStrings.analysisHealthFair;
    if (score >= 40) return AppStrings.analysisHealthWeak;
    return AppStrings.analysisHealthCritical;
  }

  static List<String> recommendations({
    required double savingsRate,
    required double healthScore,
    required List<String> highSpendingCategoryLabels,
    required bool singleIncomeSource,
    required bool noGoals,
    required List<String> lowProgressGoalLabels,
    required bool noBudgets,
    required bool negativeBalance,
    required bool lowBalanceVsIncome,
  }) {
    final r = <String>[];
    final listSeparator = AppStrings.isEnglishLocale ? ', ' : '، ';

    if (savingsRate < 0) {
      r.add(AppStrings.analysisRecUrgentNegativeSavings);
      r.add(AppStrings.analysisRecExtraIncome);
    } else if (savingsRate < 10) {
      r.add(AppStrings.analysisRecIncreaseSavings);
      r.add(AppStrings.analysisRecAim1020);
    } else if (savingsRate < 20) {
      r.add(AppStrings.analysisRecPushTo20);
    }
    if (negativeBalance) {
      r.add(AppStrings.analysisRecDebtPayoff);
    } else if (lowBalanceVsIncome) {
      r.add(AppStrings.analysisRecEmergencyFund);
    }
    if (highSpendingCategoryLabels.isNotEmpty) {
      r.add(
        AppStrings.analysisRecReviewCategories(
          highSpendingCategoryLabels.join(listSeparator),
        ),
      );
    }
    if (singleIncomeSource) {
      r.add(AppStrings.analysisRecDiversifyIncome);
    }
    if (noGoals) {
      r.add(AppStrings.analysisRecSetGoals);
    } else if (lowProgressGoalLabels.isNotEmpty) {
      r.add(
        AppStrings.analysisRecIncreaseContributions(
          lowProgressGoalLabels.join(listSeparator),
        ),
      );
    }
    if (noBudgets) {
      r.add(AppStrings.analysisRecCreateBudgets);
    }
    if (healthScore >= 75) {
      r.add(AppStrings.analysisRecGreatJob);
    }
    if (r.isEmpty) {
      r.add(AppStrings.analysisRecKeepTracking);
      r.add(AppStrings.analysisRecReadInvesting);
    }
    return r;
  }
}
