import 'package:mudabbir/presentation/chatbot/chatbot_copy_helpers.dart';

/// Offline / quota-exceeded replies built from the user's local SQLite data.
class ChatbotLocalFallback {
  ChatbotLocalFallback._();

  /// Builds a concise coaching reply from [contextData] and [insights].
  static String buildReply({
    required String userMessage,
    required Map<String, dynamic> contextData,
    required Map<String, dynamic> insights,
  }) {
    final q = userMessage.toLowerCase();
    final income = _num(insights['monthly_income']);
    final expense = _num(insights['monthly_expense']);
    final balance = _num(insights['ledger_balance']);
    final score = (insights['score'] as int?) ?? 0;
    final alerts = (insights['alerts'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    if (_mentionsGoals(q)) {
      return _goalsSection(contextData, income, balance);
    }
    if (_mentionsBudget(q)) {
      return _budgetSection(contextData, expense);
    }
    if (_mentionsExpenses(q)) {
      return _expenseSection(contextData, expense, alerts);
    }
    if (_mentionsBalance(q)) {
      return ChatbotUi.localFallbackBalance(
        income.toStringAsFixed(0),
        expense.toStringAsFixed(0),
        balance.toStringAsFixed(0),
        score,
        ChatbotUi.insightStatus(score),
      );
    }

    return _defaultSnapshot(
      income: income,
      expense: expense,
      balance: balance,
      score: score,
      alerts: alerts,
      contextData: contextData,
    );
  }

  static bool _mentionsGoals(String q) {
    return q.contains('هدف') ||
        q.contains('اهداف') ||
        q.contains('أهداف') ||
        q.contains('goal');
  }

  static bool _mentionsBudget(String q) {
    return q.contains('ميزان') ||
        q.contains('budget');
  }

  static bool _mentionsExpenses(String q) {
    return q.contains('مصروف') ||
        q.contains('نفق') ||
        q.contains('إنفاق') ||
        q.contains('انفاق') ||
        q.contains('spend') ||
        q.contains('expense');
  }

  static bool _mentionsBalance(String q) {
    return q.contains('رصيد') ||
        q.contains('دخل') ||
        q.contains('فائض') ||
        q.contains('balance') ||
        q.contains('income');
  }

  static String _defaultSnapshot({
    required double income,
    required double expense,
    required double balance,
    required int score,
    required List<String> alerts,
    required Map<String, dynamic> contextData,
  }) {
    final status = ChatbotUi.insightStatus(score);
    final alertBlock = alerts.isEmpty
        ? ChatbotUi.noSpendingAlerts
        : alerts.map((a) => '• $a').join('\n');
    final topCategory = _topCategoryLine(contextData);
    final goalsLine = _activeGoalsLine(contextData);

    return ChatbotUi.localFallbackSnapshot(
      income.toStringAsFixed(0),
      expense.toStringAsFixed(0),
      balance.toStringAsFixed(0),
      score,
      status,
      alertBlock,
      topCategory,
      goalsLine,
    );
  }

  static String _goalsSection(
    Map<String, dynamic> contextData,
    double income,
    double balance,
  ) {
    final goalsRaw = contextData['goals'];
    final goals = goalsRaw is List ? goalsRaw : const <dynamic>[];
    if (goals.isEmpty) {
      return ChatbotUi.localFallbackNoGoals;
    }

    final lines = <String>[];
    for (final g in goals.take(5)) {
      if (g is! Map) continue;
      final name = (g['name'] ?? ChatbotUi.defaultGoalWord).toString();
      final target = _num(g['target']);
      final current = _num(g['current_amount']);
      final pct = target <= 0 ? 0 : ((current / target) * 100).clamp(0, 100);
      lines.add(
        ChatbotUi.localFallbackGoalLine(
          name,
          current.toStringAsFixed(0),
          target.toStringAsFixed(0),
          pct.toStringAsFixed(0),
        ),
      );
    }

    final surplus = balance > 0 ? balance : 0;
    return ChatbotUi.localFallbackGoalsIntro(
      lines.join('\n'),
      surplus.toStringAsFixed(0),
      income.toStringAsFixed(0),
    );
  }

  static String _budgetSection(
    Map<String, dynamic> contextData,
    double expense,
  ) {
    final budgetsRaw = contextData['budgets'];
    final budgets = budgetsRaw is List ? budgetsRaw : const <dynamic>[];
    if (budgets.isEmpty) {
      return ChatbotUi.localFallbackNoBudget(expense.toStringAsFixed(0));
    }

    final now = DateTime.now();
    Map<String, dynamic>? current;
    for (final b in budgets) {
      if (b is! Map) continue;
      final start = DateTime.tryParse((b['start_date'] ?? '').toString());
      final end = DateTime.tryParse((b['end_date'] ?? '').toString());
      if (start == null || end == null) continue;
      if (!now.isBefore(start) && !now.isAfter(end)) {
        current = Map<String, dynamic>.from(b);
        break;
      }
    }

    current ??= budgets.last is Map
        ? Map<String, dynamic>.from(budgets.last as Map)
        : null;

    if (current == null) {
      return ChatbotUi.localFallbackNoBudget(expense.toStringAsFixed(0));
    }

    final amount = _num(current['amount']);
    final accountId = (current['account_id'] as num?)?.toInt();
    final accountExpense = _monthlyExpenseForAccount(
      contextData,
      accountId: accountId,
    );
    final remaining = amount - accountExpense;
    final usedPct =
        amount <= 0 ? 0 : ((accountExpense / amount) * 100).clamp(0, 999);

    return ChatbotUi.localFallbackBudget(
      amount.toStringAsFixed(0),
      accountExpense.toStringAsFixed(0),
      remaining.toStringAsFixed(0),
      usedPct.toStringAsFixed(0),
    );
  }

  static double _monthlyExpenseForAccount(
    Map<String, dynamic> contextData, {
    int? accountId,
  }) {
    final txRaw = contextData['transactions'];
    final tx = txRaw is List ? txRaw : const <dynamic>[];
    final now = DateTime.now();
    var total = 0.0;
    for (final item in tx) {
      if (item is! Map) continue;
      if ((item['type'] ?? '').toString() != 'expense') continue;
      if (accountId != null && (item['account_id'] as num?)?.toInt() != accountId) {
        continue;
      }
      final date = DateTime.tryParse((item['date'] ?? '').toString());
      if (date == null) continue;
      if (date.year == now.year && date.month == now.month) {
        total += _num(item['amount']);
      }
    }
    return total;
  }

  static String _expenseSection(
    Map<String, dynamic> contextData,
    double expense,
    List<String> alerts,
  ) {
    final breakdown = _categoryBreakdown(contextData);
    if (breakdown.isEmpty) {
      return ChatbotUi.localFallbackNoExpenses;
    }

    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final lines = sorted
        .take(5)
        .map((e) {
          final share = expense <= 0
              ? '0'
              : ((e.value / expense) * 100).toStringAsFixed(0);
          return ChatbotUi.localFallbackCategoryLine(
            e.key,
            e.value.toStringAsFixed(0),
            share,
          );
        })
        .join('\n');

    final alertLine = alerts.isEmpty ? '' : '\n\n${alerts.first}';

    return ChatbotUi.localFallbackExpenses(
      expense.toStringAsFixed(0),
      lines,
    ) + alertLine;
  }

  static String _topCategoryLine(Map<String, dynamic> contextData) {
    final breakdown = _categoryBreakdown(contextData);
    if (breakdown.isEmpty) {
      return ChatbotUi.localFallbackNoCategoryData;
    }
    final top = breakdown.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    return ChatbotUi.localFallbackTopCategory(
      top.key,
      top.value.toStringAsFixed(0),
    );
  }

  static String _activeGoalsLine(Map<String, dynamic> contextData) {
    final goalsRaw = contextData['goals'];
    final goals = goalsRaw is List ? goalsRaw : const <dynamic>[];
    var active = 0;
    for (final g in goals) {
      if (g is! Map) continue;
      final target = _num(g['target']);
      final current = _num(g['current_amount']);
      if (target > current) active++;
    }
    if (active == 0) {
      return ChatbotUi.localFallbackGoalsNone;
    }
    return ChatbotUi.localFallbackGoalsCount(active);
  }

  static Map<String, double> _categoryBreakdown(
    Map<String, dynamic> contextData,
  ) {
    final txRaw = contextData['transactions'];
    final tx = txRaw is List ? txRaw : const <dynamic>[];
    final categoriesRaw = contextData['categories'];
    final categories = categoriesRaw is List ? categoriesRaw : const <dynamic>[];

    final catMap = <int, String>{};
    for (final c in categories) {
      if (c is! Map) continue;
      final id = int.tryParse((c['id'] ?? '').toString());
      final name = (c['name'] ?? '').toString();
      if (id != null && name.isNotEmpty) catMap[id] = name;
    }

    final now = DateTime.now();
    final bucket = <String, double>{};
    for (final t in tx) {
      if (t is! Map) continue;
      if ((t['type'] ?? '').toString().toLowerCase() != 'expense') continue;
      final date = DateTime.tryParse((t['date'] ?? '').toString());
      if (date == null || date.year != now.year || date.month != now.month) {
        continue;
      }
      final amount = _num(t['amount']);
      final catId = int.tryParse((t['category_id'] ?? '').toString());
      final name = catId != null
          ? (catMap[catId] ?? ChatbotUi.localFallbackOtherCategory)
          : ChatbotUi.localFallbackOtherCategory;
      bucket[name] = (bucket[name] ?? 0) + amount;
    }
    return bucket;
  }

  static double _num(dynamic value) {
    return double.tryParse((value ?? '0').toString()) ?? 0;
  }
}
