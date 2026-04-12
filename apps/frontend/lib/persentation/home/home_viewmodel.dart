import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/data/local/local_database.dart';
import 'package:mudabbir/domain/repository/home_repository/home_repository.dart';
import 'package:mudabbir/domain/repository/planner_repository/planner_repository.dart';
import 'package:mudabbir/persentation/explore/explore_view.dart';
import 'package:mudabbir/persentation/goals/goals_view.dart';
import 'package:mudabbir/persentation/planner/planner_hub_view.dart';
import 'package:mudabbir/persentation/resources/planner_strings.dart';
import 'package:mudabbir/persentation/resources/strings_manager.dart';
import 'package:mudabbir/persentation/statistics/statistics_view.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/planner/planner_notification_evaluator.dart';

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

  List<Widget> pages = [
    ExploreView(),
    StatisticsView(),
    GoalView(),
    const PlannerHubView(),
  ];

  final HomeRepository homeRepository = getIt<HomeRepository>();

  Future<void> loadFinancialSummary() async {
    final user = await getIt<HiveService>().getValue(
      HiveConstants.savedUserInfo,
    );
    final userName = (user is Map && user['name'] != null)
        ? user['name'].toString()
        : 'guest_user';
    await LocalDatabase.instance.initForUser(userName);

    // All-time
    final income = await homeRepository.getTotalIncome();
    final expense = await homeRepository.getTotalExpense();

    // This month (first and last day)
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    final monthlyIncome = await homeRepository.getTotalIncome(
      startDate: firstDay.toIso8601String(),
      endDate: lastDay.toIso8601String(),
    );
    final monthlyExpense = await homeRepository.getTotalExpense(
      startDate: firstDay.toIso8601String(),
      endDate: lastDay.toIso8601String(),
    );
    final previousFirstDay = DateTime(now.year, now.month - 1, 1);
    final previousLastDay = DateTime(now.year, now.month, 0);
    final previousMonthExpense = await homeRepository.getTotalExpense(
      startDate: previousFirstDay.toIso8601String(),
      endDate: previousLastDay.toIso8601String(),
    );
    final financialHealthScore = _calculateFinancialHealthScore(
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      monthlyBalance: monthlyIncome - monthlyExpense,
    );
    var spendingAlerts = _buildSpendingAlerts(
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      previousMonthExpense: previousMonthExpense,
    );
    try {
      final plannerLines =
          await getIt<PlannerRepository>().categoryBudgetAlertLines(now, 80);
      spendingAlerts = [
        ...spendingAlerts,
        ...plannerLines.map(PlannerStrings.notifBudgetHigh),
      ];
    } catch (_) {}
    await PlannerNotificationEvaluator.run(
      monthlyExpense: monthlyExpense,
      previousMonthExpense: previousMonthExpense,
    );
    final nextMonthBudgetSuggestion = await _buildNextMonthBudgetSuggestion(now);

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
    );
  }

  Future<double> _buildNextMonthBudgetSuggestion(DateTime now) async {
    final samples = <double>[];
    for (int i = 1; i <= 3; i++) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final start = DateTime(monthDate.year, monthDate.month, 1);
      final end = DateTime(monthDate.year, monthDate.month + 1, 0);
      final expense = await homeRepository.getTotalExpense(
        startDate: start.toIso8601String(),
        endDate: end.toIso8601String(),
      );
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

  int _calculateFinancialHealthScore({
    required double monthlyIncome,
    required double monthlyExpense,
    required double monthlyBalance,
  }) {
    if (monthlyIncome <= 0 && monthlyExpense <= 0) {
      return 0;
    }

    int score = 50;
    final savingsRate = monthlyIncome <= 0 ? 0.0 : (monthlyBalance / monthlyIncome);

    if (savingsRate >= 0.30) {
      score += 30;
    } else if (savingsRate >= 0.20) {
      score += 20;
    } else if (savingsRate >= 0.10) {
      score += 10;
    } else if (savingsRate < 0) {
      score -= 25;
    }

    if (monthlyExpense > monthlyIncome && monthlyIncome > 0) {
      score -= 15;
    }

    if (monthlyExpense == 0 && monthlyIncome > 0) {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  List<String> _buildSpendingAlerts({
    required double monthlyIncome,
    required double monthlyExpense,
    required double previousMonthExpense,
  }) {
    final alerts = <String>[];

    if (monthlyIncome > 0 && monthlyExpense > monthlyIncome) {
      alerts.add(
        AppStrings.isEnglishLocale
            ? 'Alert: This month\'s spending exceeded your monthly income.'
            : 'تنبيه: مصروفات هذا الشهر تجاوزت دخلك الشهري.',
      );
    }

    if (previousMonthExpense > 0) {
      final growth = (monthlyExpense - previousMonthExpense) / previousMonthExpense;
      if (growth >= 0.25) {
        final pct = (growth * 100).toStringAsFixed(0);
        alerts.add(
          AppStrings.isEnglishLocale
              ? 'Alert: Spending is up $pct% compared to last month.'
              : 'تنبيه: الإنفاق ارتفع $pct% مقارنة بالشهر الماضي.',
        );
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
