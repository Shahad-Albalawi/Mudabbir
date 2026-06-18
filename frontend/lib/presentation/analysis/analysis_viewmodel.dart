import 'package:mudabbir/domain/models/behavioral_snapshot.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/domain/services/health_score_calculator.dart';
import 'package:mudabbir/domain/services/insight_thresholds.dart';
import 'package:mudabbir/domain/repository/behavioral_analysis_repository/behavioral_analysis_repository.dart';
import 'package:mudabbir/presentation/resources/analysis_copy.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/statistics/statistics_viewmodel.dart';
import 'package:mudabbir/service/getit_init.dart';

class AnalysisState {
  final String financialHealthRating;
  final double healthScore;
  final String savingsAnalysis;
  final String spendingAnalysis;
  final List<String> recommendations;
  final Map<String, String> categoryInsights;
  final String balanceStatus;
  final double savingsRate;

  final int behavioralScore;
  final String behavioralRating;
  final List<MonthlySpendingPoint> monthlyTrend;
  final List<SpendingAnomaly> anomalies;
  final String monthComparisonSummary;
  final String weekdayInsight;
  final List<String> personalizedRecommendations;

  final bool isLoading;

  const AnalysisState({
    this.financialHealthRating = '',
    this.healthScore = 0,
    this.savingsAnalysis = '',
    this.spendingAnalysis = '',
    this.recommendations = const [],
    this.categoryInsights = const {},
    this.balanceStatus = '',
    this.savingsRate = 0,
    this.behavioralScore = 0,
    this.behavioralRating = '',
    this.monthlyTrend = const [],
    this.anomalies = const [],
    this.monthComparisonSummary = '',
    this.weekdayInsight = '',
    this.personalizedRecommendations = const [],
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
    int? behavioralScore,
    String? behavioralRating,
    List<MonthlySpendingPoint>? monthlyTrend,
    List<SpendingAnomaly>? anomalies,
    String? monthComparisonSummary,
    String? weekdayInsight,
    List<String>? personalizedRecommendations,
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
      behavioralScore: behavioralScore ?? this.behavioralScore,
      behavioralRating: behavioralRating ?? this.behavioralRating,
      monthlyTrend: monthlyTrend ?? this.monthlyTrend,
      anomalies: anomalies ?? this.anomalies,
      monthComparisonSummary:
          monthComparisonSummary ?? this.monthComparisonSummary,
      weekdayInsight: weekdayInsight ?? this.weekdayInsight,
      personalizedRecommendations:
          personalizedRecommendations ?? this.personalizedRecommendations,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final analysisProvider =
    StateNotifierProvider<AnalysisNotifier, AnalysisState>(
  (ref) => AnalysisNotifier(ref),
);

class AnalysisNotifier extends StateNotifier<AnalysisState> {
  AnalysisNotifier(this._ref) : super(const AnalysisState(isLoading: true)) {
    _ref.listen<StatisticsState>(statisticsProvider, (_, stats) {
      _rebuild(stats);
    });
    _rebuild(_ref.read(statisticsProvider));
  }

  final Ref _ref;
  final BehavioralAnalysisRepository _behavioralRepo =
      getIt<BehavioralAnalysisRepository>();

  Future<void> _rebuild(StatisticsState statistics) async {
    if (statistics.isLoading) {
      state = const AnalysisState(isLoading: true);
      return;
    }

    state = const AnalysisState(isLoading: true);

    final behavioralEither = await _behavioralRepo.buildSnapshot(statistics);
    final behavioral = behavioralEither.fold(
      (_) => const BehavioralSnapshot(),
      (snapshot) => snapshot,
    );

    final base = AnalysisLogic.fromStatistics(statistics);
    state = base.copyWith(
      behavioralScore: behavioral.behavioralScore,
      behavioralRating: behavioral.behavioralRating,
      monthlyTrend: behavioral.monthlyTrend,
      anomalies: behavioral.anomalies,
      monthComparisonSummary: behavioral.monthComparisonSummary,
      weekdayInsight: behavioral.weekdayInsight,
      personalizedRecommendations: _mergeRecommendations(
        base.recommendations,
        behavioral.personalizedRecommendations,
      ),
      isLoading: false,
    );
  }

  List<String> _mergeRecommendations(
    List<String> general,
    List<String> personalized,
  ) {
    final merged = <String>[];
    final seen = <String>{};
    for (final item in [...personalized, ...general]) {
      if (seen.add(item)) merged.add(item);
    }
    return merged.take(8).toList();
  }
}

/// Pure analysis from SQLite aggregates (see [StatisticsViewModel]).
class AnalysisLogic {
  AnalysisLogic._();

  static AnalysisState fromStatistics(StatisticsState statistics) {
    try {
      final savingsRate = _calculateSavingsRate(statistics);
      final balanceStatus = _analyzeBalance(statistics);
      final spendingAnalysis = _analyzeSpending(statistics);
      final savingsAnalysis = _analyzeSavings(savingsRate);
      final categoryInsights = _analyzeCategorySpending(statistics);
      final healthScore = HealthScoreCalculator.fromStatistics(
        statistics,
        savingsRate,
      );
      final healthRating = _getHealthRating(healthScore);
      final recommendations = _generateRecommendations(
        statistics,
        savingsRate,
        healthScore,
      );

      return AnalysisState(
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
    } catch (_) {
      return const AnalysisState(isLoading: false);
    }
  }

  static double _calculateSavingsRate(StatisticsState statistics) {
    if (statistics.totalIncome == 0) return 0;
    final saved = statistics.totalIncome - statistics.totalExpense;
    return (saved / statistics.totalIncome) * 100;
  }

  static String _analyzeBalance(StatisticsState statistics) {
    return AnalysisCopy.balanceAnalysis(
      statistics.currentBalance,
      statistics.totalIncome,
    );
  }

  static String _analyzeSpending(StatisticsState statistics) {
    final expenseRatio = statistics.totalIncome == 0
        ? 100.0
        : (statistics.totalExpense / statistics.totalIncome) * 100;
    return AnalysisCopy.spendingAnalysis(expenseRatio);
  }

  static String _analyzeSavings(double savingsRate) {
    return AnalysisCopy.savingsAnalysis(savingsRate);
  }

  static Map<String, String> _analyzeCategorySpending(
    StatisticsState statistics,
  ) {
    final insights = <String, String>{};
    if (statistics.totalExpense == 0) return insights;

    statistics.expenseByCategory.forEach((category, amount) {
      final percentage = (amount / statistics.totalExpense) * 100;
      insights[category] = AnalysisCopy.categoryInsight(percentage);
    });

    return insights;
  }

  static String _getHealthRating(double score) {
    return AnalysisCopy.healthRating(score);
  }

  static List<String> _generateRecommendations(
    StatisticsState statistics,
    double savingsRate,
    double healthScore,
  ) {
    final highSpendingCategoryLabels = statistics.expenseByCategory.entries
        .where((e) {
          if (statistics.totalExpense == 0) return false;
          final pct = (e.value / statistics.totalExpense) * 100;
          return pct >= InsightThresholds.highCategorySpendShare * 100;
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
