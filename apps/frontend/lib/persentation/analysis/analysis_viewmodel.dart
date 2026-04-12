import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/persentation/resources/analysis_copy.dart';
import 'package:mudabbir/persentation/resources/entity_localizations.dart';
import 'package:mudabbir/persentation/statistics/statistics_viewmodel.dart';

class AnalysisState {
  final String financialHealthRating;
  final double healthScore;
  final String savingsAnalysis;
  final String spendingAnalysis;
  final List<String> recommendations;
  final Map<String, String> categoryInsights;
  final String balanceStatus;
  final double savingsRate;
  final bool isLoading;

  AnalysisState({
    this.financialHealthRating = '',
    this.healthScore = 0,
    this.savingsAnalysis = '',
    this.spendingAnalysis = '',
    this.recommendations = const [],
    this.categoryInsights = const {},
    this.balanceStatus = '',
    this.savingsRate = 0,
    this.isLoading = false,
  });

  AnalysisState copyWith({
    String? financialHealthRating,
    double? healthScore,
    String? savingsAnalysis,
    String? spendingAnalysis,
    List<String>? recommendations,
    Map<String, String>? categoryInsights,
    String? balanceStatus,
    double? savingsRate,
    bool? isLoading,
  }) {
    return AnalysisState(
      financialHealthRating:
          financialHealthRating ?? this.financialHealthRating,
      healthScore: healthScore ?? this.healthScore,
      savingsAnalysis: savingsAnalysis ?? this.savingsAnalysis,
      spendingAnalysis: spendingAnalysis ?? this.spendingAnalysis,
      recommendations: recommendations ?? this.recommendations,
      categoryInsights: categoryInsights ?? this.categoryInsights,
      balanceStatus: balanceStatus ?? this.balanceStatus,
      savingsRate: savingsRate ?? this.savingsRate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final analysisProvider =
    StateNotifierProvider<AnalysisViewModel, AnalysisState>((ref) {
      final stats = ref.watch(statisticsProvider);
      return AnalysisViewModel(stats);
    });

class AnalysisViewModel extends StateNotifier<AnalysisState> {
  final StatisticsState statistics;

  AnalysisViewModel(this.statistics) : super(AnalysisState()) {
    analyzeFinancialBehavior();
  }

  void analyzeFinancialBehavior() {
    state = state.copyWith(isLoading: true);

    try {
      final savingsRate = _calculateSavingsRate();
      final balanceStatus = _analyzeBalance();
      final spendingAnalysis = _analyzeSpending();
      final savingsAnalysis = _analyzeSavings(savingsRate);
      final categoryInsights = _analyzeCategorySpending();
      final healthScore = _calculateHealthScore(savingsRate);
      final healthRating = _getHealthRating(healthScore);
      final recommendations = _generateRecommendations(
        savingsRate,
        healthScore,
      );

      state = state.copyWith(
        financialHealthRating: healthRating,
        healthScore: healthScore,
        savingsAnalysis: savingsAnalysis,
        spendingAnalysis: spendingAnalysis,
        recommendations: recommendations,
        categoryInsights: categoryInsights,
        balanceStatus: balanceStatus,
        savingsRate: savingsRate,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  double _calculateSavingsRate() {
    if (statistics.totalIncome == 0) return 0;
    final saved = statistics.totalIncome - statistics.totalExpense;
    return (saved / statistics.totalIncome) * 100;
  }

  String _analyzeBalance() {
    return AnalysisCopy.balanceAnalysis(
      statistics.currentBalance,
      statistics.totalIncome,
    );
  }

  String _analyzeSpending() {
    final expenseRatio = statistics.totalIncome == 0
        ? 100.0
        : (statistics.totalExpense / statistics.totalIncome) * 100;
    return AnalysisCopy.spendingAnalysis(expenseRatio);
  }

  String _analyzeSavings(double savingsRate) {
    return AnalysisCopy.savingsAnalysis(savingsRate);
  }

  Map<String, String> _analyzeCategorySpending() {
    final insights = <String, String>{};
    if (statistics.totalExpense == 0) return insights;

    statistics.expenseByCategory.forEach((category, amount) {
      final percentage = (amount / statistics.totalExpense) * 100;
      insights[category] = AnalysisCopy.categoryInsight(percentage);
    });

    return insights;
  }

  double _calculateHealthScore(double savingsRate) {
    double score = 0;

    if (savingsRate >= 30) {
      score += 40;
    } else if (savingsRate >= 20) {
      score += 35;
    } else if (savingsRate >= 10) {
      score += 25;
    } else if (savingsRate >= 5) {
      score += 15;
    } else if (savingsRate >= 0) {
      score += 5;
    }

    if (statistics.currentBalance >= statistics.totalIncome * 0.5) {
      score += 30;
    } else if (statistics.currentBalance >= statistics.totalIncome * 0.3) {
      score += 25;
    } else if (statistics.currentBalance >= statistics.totalIncome * 0.1) {
      score += 15;
    } else if (statistics.currentBalance > 0) {
      score += 10;
    }

    final categoryCount = statistics.expenseByCategory.length;
    if (categoryCount >= 5) {
      score += 20;
    } else if (categoryCount >= 3) {
      score += 15;
    } else if (categoryCount >= 2) {
      score += 10;
    } else if (categoryCount >= 1) {
      score += 5;
    }

    if (statistics.goalsProgress.isNotEmpty) {
      final avgProgress =
          statistics.goalsProgress.values.fold(0.0, (a, b) => a + b) /
          statistics.goalsProgress.length;
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

    return score.clamp(0, 100);
  }

  String _getHealthRating(double score) {
    return AnalysisCopy.healthRating(score);
  }

  List<String> _generateRecommendations(
    double savingsRate,
    double healthScore,
  ) {
    final highSpendingCategoryLabels = statistics.expenseByCategory.entries
        .where((e) {
          if (statistics.totalExpense == 0) return false;
          final pct = (e.value / statistics.totalExpense) * 100;
          return pct >= 30;
        })
        .map((e) => EntityLocalizations.categoryName(e.key))
        .toList();

    final lowProgressGoalLabels = statistics.goalsProgress.entries
        .where((e) => e.value < 50)
        .map((e) => e.key)
        .toList();

    return AnalysisCopy.recommendations(
      savingsRate: savingsRate,
      healthScore: healthScore,
      highSpendingCategoryLabels: highSpendingCategoryLabels,
      singleIncomeSource: statistics.incomeByCategory.length == 1,
      noGoals: statistics.goalsProgress.isEmpty,
      lowProgressGoalLabels: lowProgressGoalLabels,
      noBudgets: statistics.budgetsProgress.isEmpty,
      negativeBalance: statistics.currentBalance < 0,
      lowBalanceVsIncome:
          statistics.currentBalance >= 0 &&
          statistics.currentBalance < statistics.totalIncome * 0.3,
    );
  }
}
