import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/domain/services/financial_aggregator.dart';
import 'package:mudabbir/domain/services/financial_date_utils.dart';
import 'package:mudabbir/domain/services/health_score_calculator.dart';
import 'package:mudabbir/features/ai_assistant/data/ai_system_prompt.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/chatbot/chatbot_context_loader.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/utils/user_display_name.dart';

/// Builds the AI system prompt with live financial data for `/api/ai/chat`.
class ChatContextSummary {
  ChatContextSummary({
    ChatbotContextLoader? loader,
    FinancialAggregator? aggregator,
  })  : _loader = loader ?? ChatbotContextLoader(),
        _aggregator = aggregator ?? FinancialAggregator();

  final ChatbotContextLoader _loader;
  final FinancialAggregator _aggregator;

  Future<String> build() async {
    final userName = await _userName();
    final context = await _loader.load();
    final now = DateTime.now();
    final month = FinancialDateUtils.monthRange(now);

    final totals = await _aggregator.incomeAndExpenseTotals(
      startDate: month.start,
      endDate: month.end,
    );
    final balance = await _aggregator.ledgerBalance();

    final categoryTotals = <String, double>{};
    final transactions = context['transactions'];
    if (transactions is List) {
      for (final raw in transactions) {
        if (raw is! Map) continue;
        if (raw['type']?.toString() != 'expense') continue;
        final date = raw['date']?.toString() ?? '';
        if (date.compareTo(month.start) < 0 || date.compareTo(month.end) > 0) {
          continue;
        }
        final cat = raw['category_name']?.toString() ?? 'أخرى';
        categoryTotals[cat] =
            (categoryTotals[cat] ?? 0) + ((raw['amount'] as num?)?.toDouble() ?? 0);
      }
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategory = sortedCategories.isEmpty
        ? AppStrings.chatbotJsonNoData
        : sortedCategories.first.key;

    final savingsRate = totals.income <= 0
        ? 0.0
        : ((totals.income - totals.expense) / totals.income) * 100;

    final goalsProgress = <String, double>{};
    final activeGoals = <String>[];
    final goalsRaw = context['goals'];
    if (goalsRaw is List) {
      for (final raw in goalsRaw) {
        if (raw is! Map) continue;
        if ((raw['is_completed'] == 1) || raw['is_completed'] == true) continue;
        final name = raw['name']?.toString() ?? '';
        final target = (raw['target'] as num?)?.toDouble() ?? 0;
        final current = (raw['current_amount'] as num?)?.toDouble() ?? 0;
        final pct = target <= 0 ? 0.0 : ((current / target) * 100).clamp(0, 100);
        goalsProgress[name] = pct.toDouble();
        activeGoals.add(name);
      }
    }

    final healthScore = HealthScoreCalculator.calculate(
      totalIncome: totals.income,
      totalExpense: totals.expense,
      currentBalance: balance,
      expenseByCategory: categoryTotals,
      goalsProgress: goalsProgress,
    ).round();

    final overBudget = _overBudgetCategories(
      context['budgets'],
      categoryTotals,
      month.start,
      month.end,
    );

    final language = AppStrings.isEnglishLocale ? 'en' : 'ar';

    return AISystemPrompt.build(
      name: userName.isEmpty
          ? (language == 'en' ? 'Mudabbir user' : 'مستخدم مدبّر')
          : userName,
      balance: balance,
      income: totals.income,
      expenses: totals.expense,
      savingsRate: savingsRate,
      healthScore: healthScore,
      activeGoals: activeGoals,
      topSpendingCategory: topCategory,
      overBudgetCategories: overBudget,
      language: language,
    );
  }

  List<String> _overBudgetCategories(
    Object? budgetsRaw,
    Map<String, double> spentByCategory,
    String monthStart,
    String monthEnd,
  ) {
    if (budgetsRaw is! List || budgetsRaw.isEmpty) return const [];

    final limits = <String, double>{};
    for (final raw in budgetsRaw) {
      if (raw is! Map) continue;
      final start = raw['start_date']?.toString() ?? '';
      final end = raw['end_date']?.toString() ?? '';
      if (start.isNotEmpty && start.compareTo(monthEnd) > 0) continue;
      if (end.isNotEmpty && end.compareTo(monthStart) < 0) continue;

      final category = raw['category_name']?.toString() ??
          raw['name']?.toString() ??
          '';
      final limit = (raw['limit'] as num?)?.toDouble() ??
          (raw['amount'] as num?)?.toDouble() ??
          0;
      if (category.isEmpty || limit <= 0) continue;
      limits[category] = (limits[category] ?? 0) + limit;
    }

    final over = <String>[];
    for (final entry in limits.entries) {
      final spent = spentByCategory[entry.key] ?? 0;
      if (spent > entry.value) {
        final pct = ((spent / entry.value) * 100).round();
        over.add('${entry.key} ($pct%)');
      }
    }
    return over;
  }

  Future<String> _userName() async {
    try {
      final user = await getIt<HiveService>().getValue(HiveConstants.savedUserInfo);
      return UserDisplayName.fromSavedUserInfo(user);
    } catch (_) {
      return '';
    }
  }
}
