import 'package:flutter/material.dart';
import 'package:mudabbir/features/auth/register_screen.dart';
import 'package:mudabbir/presentation/analysis/analysis_view.dart';
import 'package:mudabbir/presentation/budget/budget_view.dart';
import 'package:mudabbir/presentation/expenses/expenses_view.dart';
import 'package:mudabbir/presentation/goals/goals_view.dart';
import 'package:mudabbir/presentation/screens/statistics_screen.dart';
import 'package:mudabbir/presentation/server_challenges/screens/challenges_list_screen.dart';
import 'package:mudabbir/presentation/settings/settings_view.dart';

/// Route screen aliases — design-system names.
typedef SignUpScreen = RegisterScreen;
typedef AnalysisScreen = StatisticsScreen;
typedef GoalsScreen = GoalView;
typedef SettingsScreen = SettingsView;
typedef ExpensesScreen = ExpensesView;
typedef BudgetScreen = BudgetView;

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChallengesListScreen(embedded: true);
  }
}

/// صفحة الصحة المالية — تحليل تفصيلي منفصل عن تبويب الإحصائيات.
class FinancialHealthScreen extends StatelessWidget {
  const FinancialHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnalysisView(financialHealthFocus: true);
  }
}

/// Parses `:id` path segments; returns null when invalid.
int? routePathId(String? raw) => int.tryParse(raw ?? '');
