import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/data/local/local_database.dart';
import 'package:mudabbir/domain/repository/home_repository/home_repository.dart';
import 'package:mudabbir/domain/services/financial_date_utils.dart';
import 'package:mudabbir/presentation/home/home_screen.dart';
import 'package:mudabbir/presentation/goals/goals_view.dart';
import 'package:mudabbir/domain/services/health_score_calculator.dart';
import 'package:mudabbir/domain/services/insight_thresholds.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/screens/statistics_screen.dart';
import 'package:mudabbir/presentation/server_challenges/screens/challenges_list_screen.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/utils/local_db_user_id.dart';

class HomeState {
  final double totalIncome;
  final double totalExpense;
  final double currentBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlyBalance;
  final int financialHealthScore;
  final List<String> spendingAlerts;
  final double nextMonthBudgetSuggestion;
  final int currentIndex;
  final bool isLoading;
  final String? error;

  HomeState({
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.currentBalance = 0,
    this.monthlyIncome = 0,
    this.monthlyExpense = 0,
    this.monthlyBalance = 0,
    this.financialHealthScore = 0,
    this.spendingAlerts = const [],
    this.nextMonthBudgetSuggestion = 0,
    this.currentIndex = 0,
    this.isLoading = true,
    this.error,
  });

  HomeState copyWith({
    double? totalIncome,
    double? totalExpense,
    double? currentBalance,
    double? monthlyIncome,
    double? monthlyExpense,
    double? monthlyBalance,
    int? financialHealthScore,
    List<String>? spendingAlerts,
    double? nextMonthBudgetSuggestion,
    int? currentIndex,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HomeState(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      currentBalance: currentBalance ?? this.currentBalance,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      monthlyBalance: monthlyBalance ?? this.monthlyBalance,
      financialHealthScore: financialHealthScore ?? this.financialHealthScore,
      spendingAlerts: spendingAlerts ?? this.spendingAlerts,
      nextMonthBudgetSuggestion:
          nextMonthBudgetSuggestion ?? this.nextMonthBudgetSuggestion,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final homeProvider = StateNotifierProvider<HomeViewModel, HomeState>(
  (_) => HomeViewModel(),
);

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel() : super(HomeState()) {
    loadFinancialSummary();
  }

  List<Widget> pages = const [
    HomeScreen(),
    StatisticsScreen(),
    GoalView(),
    ChallengesListScreen(embedded: true),
  ];

  final HomeRepository homeRepository = getIt<HomeRepository>();

  /// Memoized monthly expense totals within a single summary load.
  final Map<String, double> _monthlyExpenseCache = {};

  Future<void> loadFinancialSummary() async {
    state = state.copyWith(isLoading: true, clearError: true);
    _monthlyExpenseCache.clear();
    try {
      final user = await getIt<HiveService>().getValue(
        HiveConstants.savedUserInfo,
      );
      final userName = resolveLocalDbUserId(user);
      await LocalDatabase.instance.initForUser(userName);

      final income = await homeRepository.getTotalIncome();
      final expense = await homeRepository.getTotalExpense();

      final now = DateTime.now();
      final thisMonth = FinancialDateUtils.monthRange(now);
      final prevAnchor = DateTime(now.year, now.month - 1, 1);
      final previousMonth = FinancialDateUtils.monthRange(prevAnchor);

      final monthlyIncome = await homeRepository.getTotalIncome(
        startDate: thisMonth.start,
        endDate: thisMonth.end,
      );
      final monthlyExpense = await homeRepository.getTotalExpense(
        startDate: thisMonth.start,
        endDate: thisMonth.end,
      );
      final previousMonthExpense = await homeRepository.getTotalExpense(
        startDate: previousMonth.start,
        endDate: previousMonth.end,
      );
      final financialHealthScore = HealthScoreCalculator.fromMonthly(
        monthlyIncome: monthlyIncome,
        monthlyExpense: monthlyExpense,
      );
      final spendingAlerts = _buildSpendingAlerts(
        monthlyIncome: monthlyIncome,
        monthlyExpense: monthlyExpense,
        previousMonthExpense: previousMonthExpense,
      );
      final nextMonthBudgetSuggestion = await _buildNextMonthBudgetSuggestion(
        now,
      );

      state = state.copyWith(
        totalIncome: income,
        totalExpense: expense,
        currentBalance: income - expense,
        monthlyIncome: monthlyIncome,
        monthlyExpense: monthlyExpense,
        monthlyBalance: monthlyIncome - monthlyExpense,
        financialHealthScore: financialHealthScore,
        spendingAlerts: spendingAlerts,
        nextMonthBudgetSuggestion: nextMonthBudgetSuggestion,
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: AppStrings.statsHomeLoadFailed,
      );
    }
  }

  Future<double> _cachedMonthlyExpense(DateTime monthDate) async {
    final key = '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
    if (_monthlyExpenseCache.containsKey(key)) {
      return _monthlyExpenseCache[key]!;
    }
    final range = FinancialDateUtils.monthRange(monthDate);
    final expense = await homeRepository.getTotalExpense(
      startDate: range.start,
      endDate: range.end,
    );
    _monthlyExpenseCache[key] = expense;
    return expense;
  }

  Future<double> _buildNextMonthBudgetSuggestion(DateTime now) async {
    final samples = <double>[];
    for (int i = 1; i <= 3; i++) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final expense = await _cachedMonthlyExpense(monthDate);
      if (expense > 0) {
        samples.add(expense);
      }
    }

    if (samples.isEmpty) {
      return 0;
    }

    final average = samples.reduce((a, b) => a + b) / samples.length;
    // small safety reduction for better spending discipline
    return average * 0.95;
  }

  List<String> _buildSpendingAlerts({
    required double monthlyIncome,
    required double monthlyExpense,
    required double previousMonthExpense,
  }) {
    final alerts = <String>[];

    if (monthlyIncome > 0 && monthlyExpense > monthlyIncome) {
      alerts.add(AppStrings.homeAlertSpendingExceedsIncome);
    }

    if (previousMonthExpense > 0) {
      final growth =
          (monthlyExpense - previousMonthExpense) / previousMonthExpense;
      if (growth >= InsightThresholds.monthOverMonthSpendingAlert) {
        final pct = (growth * 100).toStringAsFixed(0);
        alerts.add(AppStrings.homeAlertSpendingUp(pct));
      }
    }

    return alerts;
  }

  changeNavBar(int index) {
    final i = index.clamp(0, pages.length - 1);
    state = state.copyWith(currentIndex: i);
  }

  Future<void> reload() async {
    await loadFinancialSummary();
  }
}
