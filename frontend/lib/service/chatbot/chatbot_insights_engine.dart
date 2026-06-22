import 'package:mudabbir/domain/services/health_score_calculator.dart';
import 'package:mudabbir/domain/services/insight_thresholds.dart';
import 'package:mudabbir/presentation/resources/chatbot_ui_strings.dart';
import 'package:mudabbir/service/chatbot/chatbot_text_parser.dart';

/// Offline financial insight and reply builders for the chatbot.
abstract final class ChatbotInsightsEngine {
  static String? handleSimpleQuestions(String question, {DateTime? now}) {
    final clock = now ?? DateTime.now();
    final q = question.toLowerCase().trim();

    if (q.contains('اسمك') ||
        q.contains('من انت') ||
        q.contains('من أنت') ||
        q == 'اسمك؟' ||
        q == 'ما اسمك' ||
        q == 'ما اسمك؟' ||
        (q.contains('what') && q.contains('name')) ||
        q == 'who are you' ||
        q == 'who are you?') {
      return ChatbotUi.whoAmI;
    }

    if (q == 'مرحبا' ||
        q == 'مرحباً' ||
        q == 'السلام عليكم' ||
        q == 'اهلا' ||
        q == 'أهلا' ||
        q == 'هاي' ||
        q == 'hello' ||
        q == 'hi' ||
        q == 'hey') {
      return ChatbotUi.greetBack;
    }

    if ((q.contains('كم الساعة') ||
            q.contains('الوقت') ||
            q.contains('what time') ||
            q.contains('current time')) &&
        !q.contains('معاملة') &&
        !q.contains('تحويل')) {
      final hour = clock.hour;
      final minute = clock.minute.toString().padLeft(2, '0');
      final isPm = hour >= 12;
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return ChatbotUi.timeNow(displayHour, minute, isPm);
    }

    if (q.contains('التاريخ') ||
        q.contains('تاريخ اليوم') ||
        q.contains('اليوم') && !q.contains('نفقات') && !q.contains('مصروفات') ||
        q.contains('what date') ||
        q.contains('today\'s date') ||
        q == 'date' ||
        q == 'date?') {
      final dayName = ChatbotUi.weekdays[clock.weekday % 7];
      final monthName = ChatbotUi.months[clock.month - 1];
      return ChatbotUi.dateToday(dayName, clock.day, monthName, clock.year);
    }

    if (q.contains('شكرا') || q.contains('شكراً') || q.contains('thank')) {
      return ChatbotUi.thanksReply;
    }

    if (q.contains('كيف حالك') ||
        q.contains('كيفك') ||
        q == 'how are you' ||
        q == 'how are you?') {
      return ChatbotUi.howAreYouReply;
    }

    return null;
  }

  static String buildInsightReply(Map<String, dynamic> contextData) {
    final insights = buildFinancialInsights(contextData);
    final score = insights['score'] as int;
    final alerts = (insights['alerts'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    final status = ChatbotUi.insightStatus(score);
    final alertText = alerts.isEmpty
        ? ChatbotUi.noSpendingAlerts
        : alerts.map((a) => '- $a').join('\n');
    return ChatbotUi.insightBody(score, status, alertText);
  }

  static String buildWhatIfReply(
    String userMessage,
    Map<String, dynamic> contextData, {
    DateTime? now,
  }) {
    final amount = ChatbotTextParser.extractFirstNumber(userMessage);
    if (amount == null || amount <= 0) {
      return ChatbotUi.whatIfNeedAmount;
    }

    final goalsRaw = contextData['goals'];
    final goals = goalsRaw is List
        ? goalsRaw.cast<dynamic>()
        : const <dynamic>[];
    if (goals.isEmpty) {
      return ChatbotUi.whatIfNoGoals;
    }

    Map<String, dynamic>? nearestGoal;
    var nearestRemaining = double.infinity;

    for (final g in goals) {
      if (g is! Map) continue;
      final target = double.tryParse((g['target'] ?? '0').toString()) ?? 0;
      final current =
          double.tryParse((g['current_amount'] ?? '0').toString()) ?? 0;
      final remaining = target - current;
      if (remaining > 0 && remaining < nearestRemaining) {
        nearestRemaining = remaining;
        nearestGoal = Map<String, dynamic>.from(g);
      }
    }

    if (nearestGoal == null) {
      return ChatbotUi.whatIfAllGoalsDone;
    }

    final name = (nearestGoal['name'] ?? ChatbotUi.nextGoalFallback).toString();
    final target =
        double.tryParse((nearestGoal['target'] ?? '0').toString()) ?? 0;
    final current =
        double.tryParse((nearestGoal['current_amount'] ?? '0').toString()) ?? 0;
    final remaining = (target - current).clamp(0, double.infinity);
    final months = remaining / amount;
    final roundedMonths = months.ceil();
    final clock = now ?? DateTime.now();
    final eta = clock.add(Duration(days: roundedMonths * 30));
    final etaText =
        '${eta.year}-${eta.month.toString().padLeft(2, '0')}-${eta.day.toString().padLeft(2, '0')}';

    return ChatbotUi.whatIfScenario(
      amount.toStringAsFixed(0),
      name,
      remaining.toStringAsFixed(0),
      roundedMonths,
      etaText,
    );
  }

  static String buildGoalOptimizerReply(Map<String, dynamic> contextData) {
    final goalsRaw = contextData['goals'];
    final goals = goalsRaw is List
        ? goalsRaw.cast<dynamic>()
        : const <dynamic>[];
    if (goals.isEmpty) {
      return ChatbotUi.optimizerNoGoals;
    }

    final insights = buildFinancialInsights(contextData);
    final monthlyBalance =
        (insights['monthly_balance'] as num?)?.toDouble() ?? 0;
    final monthlySavings = monthlyBalance > 0 ? monthlyBalance : 0;
    if (monthlySavings <= 0) {
      return ChatbotUi.optimizerNoSurplus;
    }

    final parsed = <Map<String, dynamic>>[];
    for (final g in goals) {
      if (g is! Map) continue;
      final rawName = (g['name'] ?? '').toString().trim();
      final name = rawName.isEmpty ? ChatbotUi.defaultGoalWord : rawName;
      final target = double.tryParse((g['target'] ?? '0').toString()) ?? 0;
      final current =
          double.tryParse((g['current_amount'] ?? '0').toString()) ?? 0;
      final remaining = target - current;
      if (remaining <= 0) continue;
      final endDate = DateTime.tryParse((g['end_date'] ?? '').toString());
      final daysLeft = endDate == null
          ? 365
          : endDate.difference(DateTime.now()).inDays;
      parsed.add({
        'name': name,
        'remaining': remaining,
        'daysLeft': daysLeft <= 0 ? 1 : daysLeft,
      });
    }

    if (parsed.isEmpty) {
      return ChatbotUi.optimizerGoalsDone;
    }

    parsed.sort(
      (a, b) => (a['daysLeft'] as int).compareTo(b['daysLeft'] as int),
    );
    final weights = parsed.map((g) => 1 / (g['daysLeft'] as int)).toList();
    final totalWeight = weights.reduce((a, b) => a + b);

    final lines = <String>[];
    for (var i = 0; i < parsed.length; i++) {
      final goal = parsed[i];
      final ratio = weights[i] / totalWeight;
      final allocation = monthlySavings * ratio;
      lines.add(
        ChatbotUi.optimizerLine(
          goal['name'] as String,
          allocation.toStringAsFixed(0),
          ((goal['remaining'] as num).toDouble()).toStringAsFixed(0),
        ),
      );
    }

    return ChatbotUi.optimizerIntro(monthlySavings.toStringAsFixed(0)) +
        lines.join('\n');
  }

  static Map<String, dynamic> buildFinancialInsights(
    Map<String, dynamic> contextData, {
    DateTime? now,
  }) {
    final txRaw = contextData['transactions'];
    final tx = txRaw is List ? txRaw.cast<dynamic>() : const <dynamic>[];
    final clock = now ?? DateTime.now();
    final currentMonth = DateTime(clock.year, clock.month);
    final previousMonth = DateTime(clock.year, clock.month - 1);

    var monthlyIncome = 0.0;
    var monthlyExpense = 0.0;
    var previousExpense = 0.0;
    var ledgerBalance = 0.0;

    for (final item in tx) {
      if (item is! Map) continue;
      final date = DateTime.tryParse((item['date'] ?? '').toString());
      if (date == null) continue;
      final amount = double.tryParse((item['amount'] ?? '0').toString()) ?? 0;
      final type = (item['type'] ?? '').toString().toLowerCase();
      if (type == 'income') {
        ledgerBalance += amount;
      } else if (type == 'expense') {
        ledgerBalance -= amount;
      }
      if (date.year == currentMonth.year && date.month == currentMonth.month) {
        if (type == 'income') monthlyIncome += amount;
        if (type == 'expense') monthlyExpense += amount;
      }
      if (date.year == previousMonth.year &&
          date.month == previousMonth.month &&
          type == 'expense') {
        previousExpense += amount;
      }
    }

    final monthlyBalance = monthlyIncome - monthlyExpense;
    final score = HealthScoreCalculator.fromMonthly(
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
    );

    final alerts = <String>[];
    if (monthlyIncome > 0 && monthlyExpense > monthlyIncome) {
      alerts.add(ChatbotUi.alertExpenseOverIncome);
    }
    if (previousExpense > 0) {
      final growth = (monthlyExpense - previousExpense) / previousExpense;
      if (growth >= InsightThresholds.monthOverMonthSpendingAlert) {
        alerts.add(
          ChatbotUi.alertSpendingGrowth((growth * 100).toStringAsFixed(0)),
        );
      }
    }

    return {
      'monthly_income': monthlyIncome,
      'monthly_expense': monthlyExpense,
      'monthly_balance': monthlyBalance,
      'ledger_balance': ledgerBalance,
      'score': score,
      'alerts': alerts,
    };
  }

  static String buildSubscriptionsReply(Map<String, dynamic> contextData) {
    final insights = buildSubscriptionInsights(contextData);
    final items = (insights['subscriptions'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    if (items.isEmpty) {
      return ChatbotUi.subsNone;
    }

    final total = items.fold<double>(
      0,
      (sum, item) => sum + ((item['avg_amount'] as num?)?.toDouble() ?? 0),
    );
    final lines = items
        .take(5)
        .map((item) {
          final name = item['label'].toString();
          final amount = ((item['avg_amount'] as num?)?.toDouble() ?? 0)
              .toStringAsFixed(0);
          final count = item['count'] is int
              ? item['count'] as int
              : int.tryParse(item['count'].toString()) ?? 0;
          return ChatbotUi.subsLine(name, amount, count);
        })
        .join('\n');

    return ChatbotUi.subsSummary(lines, total.toStringAsFixed(0));
  }

  static Map<String, dynamic> buildSubscriptionInsights(
    Map<String, dynamic> contextData,
  ) {
    final txRaw = contextData['transactions'];
    final tx = txRaw is List ? txRaw.cast<dynamic>() : const <dynamic>[];
    final bucket = <String, List<double>>{};

    for (final item in tx) {
      if (item is! Map) continue;
      final type = (item['type'] ?? '').toString().toLowerCase();
      if (type != 'expense') continue;
      final amount = double.tryParse((item['amount'] ?? '0').toString()) ?? 0;
      if (amount <= 0) continue;

      final rawNotes = (item['notes'] ?? '').toString().trim();
      final label = rawNotes.isEmpty
          ? ChatbotUi.unnamedRecurring
          : rawNotes.toLowerCase();
      bucket.putIfAbsent(label, () => <double>[]).add(amount);
    }

    final subscriptions = <Map<String, dynamic>>[];
    bucket.forEach((label, amounts) {
      if (amounts.length < 2) return;
      final avg = amounts.reduce((a, b) => a + b) / amounts.length;
      final varianceOk = amounts.every(
        (a) => (a - avg).abs() <= (avg * 0.15 + 2),
      );
      if (!varianceOk) return;
      subscriptions.add({
        'label': label,
        'count': amounts.length,
        'avg_amount': avg,
      });
    });

    subscriptions.sort(
      (a, b) => ((b['avg_amount'] as num).toDouble()).compareTo(
        (a['avg_amount'] as num).toDouble(),
      ),
    );

    return {'subscriptions': subscriptions};
  }

  static Map<String, double> buildCategoryExpenseBreakdown(
    Map<String, dynamic> contextData, {
    DateTime? now,
  }) {
    final txRaw = contextData['transactions'];
    final tx = txRaw is List ? txRaw.cast<dynamic>() : const <dynamic>[];
    final categoriesRaw = contextData['categories'];
    final categories = categoriesRaw is List
        ? categoriesRaw.cast<dynamic>()
        : const <dynamic>[];

    final catMap = <int, String>{};
    for (final c in categories) {
      if (c is! Map) continue;
      final id = int.tryParse((c['id'] ?? '').toString());
      final name = (c['name'] ?? '').toString();
      if (id != null && name.isNotEmpty) {
        catMap[id] = name;
      }
    }

    final clock = now ?? DateTime.now();
    final bucket = <String, double>{};
    for (final t in tx) {
      if (t is! Map) continue;
      final type = (t['type'] ?? '').toString().toLowerCase();
      if (type != 'expense') continue;
      final date = DateTime.tryParse((t['date'] ?? '').toString());
      if (date == null || date.year != clock.year || date.month != clock.month) {
        continue;
      }
      final amount = double.tryParse((t['amount'] ?? '0').toString()) ?? 0;
      final catId = int.tryParse((t['category_id'] ?? '').toString());
      final name = catId != null ? (catMap[catId] ?? 'Other') : 'Other';
      bucket[name] = (bucket[name] ?? 0) + amount;
    }
    return bucket;
  }
}
