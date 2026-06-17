import 'package:mudabbir/presentation/resources/chatbot_ui_strings.dart';
import 'package:mudabbir/service/reporting/financial_report_data.dart';
import 'package:mudabbir/service/reporting/financial_report_strings.dart';

/// Builds [FinancialReportData] from chatbot / SQLite context maps.
class FinancialReportBuilder {
  FinancialReportBuilder._();

  static FinancialReportData fromContext({
    required Map<String, dynamic> contextData,
    required Map<String, dynamic> insights,
    required Map<String, double> categoryBreakdown,
    String userName = '',
  }) {
    final now = DateTime.now();
    final period = DateTime(now.year, now.month);
    final income = (insights['monthly_income'] as num?)?.toDouble() ?? 0;
    final expense = (insights['monthly_expense'] as num?)?.toDouble() ?? 0;
    final balance = (insights['monthly_balance'] as num?)?.toDouble() ?? 0;
    final healthScore = (insights['score'] as int?) ?? 0;
    final savingsRate = income <= 0 ? 0.0 : (balance / income).clamp(-1.0, 1.0);

    final alerts = (insights['alerts'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];

    return FinancialReportData(
      userName: userName.trim(),
      period: period,
      generatedAt: now,
      income: income,
      expense: expense,
      balance: balance,
      healthScore: healthScore,
      savingsRate: savingsRate,
      totalAccountBalance: _totalAccountBalance(contextData),
      alerts: alerts,
      categoryBreakdown: categoryBreakdown,
      goals: _buildGoals(contextData),
      monthlyBudget: _activeBudgetAmount(contextData, now),
      budgetUsedPercent: _budgetUsedPercent(contextData, expense, now),
      transactions: _buildTransactions(contextData, now),
      subscriptions: _buildSubscriptions(contextData),
    );
  }

  static double _totalAccountBalance(Map<String, dynamic> contextData) {
    final accountsRaw = contextData['accounts'];
    final accounts =
        accountsRaw is List ? accountsRaw.cast<dynamic>() : const <dynamic>[];
    var total = 0.0;
    for (final a in accounts) {
      if (a is! Map) continue;
      total += double.tryParse((a['balance'] ?? '0').toString()) ?? 0;
    }
    return total;
  }

  static double? _activeBudgetAmount(
    Map<String, dynamic> contextData,
    DateTime now,
  ) {
    final budgetsRaw = contextData['budgets'];
    final budgets =
        budgetsRaw is List ? budgetsRaw.cast<dynamic>() : const <dynamic>[];
    for (final b in budgets) {
      if (b is! Map) continue;
      final start = DateTime.tryParse((b['start_date'] ?? '').toString());
      final end = DateTime.tryParse((b['end_date'] ?? '').toString());
      if (start == null || end == null) continue;
      final day = DateTime(now.year, now.month, now.day);
      if (!day.isBefore(start) && !day.isAfter(end)) {
        return double.tryParse((b['amount'] ?? '0').toString());
      }
    }
    return null;
  }

  static double _budgetUsedPercent(
    Map<String, dynamic> contextData,
    double expense,
    DateTime now,
  ) {
    final budget = _activeBudgetAmount(contextData, now);
    if (budget == null || budget <= 0) return 0;
    return ((expense / budget) * 100).clamp(0, 999);
  }

  static List<ReportGoal> _buildGoals(Map<String, dynamic> contextData) {
    final goalsRaw = contextData['goals'];
    final goals =
        goalsRaw is List ? goalsRaw.cast<dynamic>() : const <dynamic>[];
    final result = <ReportGoal>[];

    for (final g in goals) {
      if (g is! Map) continue;
      final name = (g['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      final target = double.tryParse((g['target'] ?? '0').toString()) ?? 0;
      final current =
          double.tryParse((g['current_amount'] ?? '0').toString()) ?? 0;
      final progress = target <= 0 ? 0.0 : (current / target * 100).clamp(0, 100);
      final endDate = (g['end_date'] ?? '').toString();
      result.add(
        ReportGoal(
          name: name,
          target: target,
          current: current,
          progressPercent: progress.toDouble(),
          endDate: endDate.isEmpty ? null : endDate,
        ),
      );
    }

    result.sort((a, b) => b.progressPercent.compareTo(a.progressPercent));
    return result;
  }

  static List<ReportTransaction> _buildTransactions(
    Map<String, dynamic> contextData,
    DateTime now,
  ) {
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

    final monthTx = <ReportTransaction>[];
    for (final t in tx) {
      if (t is! Map) continue;
      final date = DateTime.tryParse((t['date'] ?? '').toString());
      if (date == null || date.year != now.year || date.month != now.month) {
        continue;
      }
      final type = (t['type'] ?? '').toString().toLowerCase();
      final amount = double.tryParse((t['amount'] ?? '0').toString()) ?? 0;
      final catId = int.tryParse((t['category_id'] ?? '').toString());
      final category =
          catId != null ? (catMap[catId] ?? FinancialReportStrings.otherCategory) : FinancialReportStrings.otherCategory;
      final notes = (t['notes'] ?? '').toString().trim();

      monthTx.add(
        ReportTransaction(
          date: (t['date'] ?? '').toString(),
          category: category,
          type: type,
          amount: amount,
          notes: notes.isEmpty ? null : notes,
        ),
      );
    }

    monthTx.sort((a, b) {
      final da = DateTime.tryParse(a.date);
      final db = DateTime.tryParse(b.date);
      if (da == null || db == null) return 0;
      return db.compareTo(da);
    });

    return monthTx.take(20).toList();
  }

  static List<ReportSubscription> _buildSubscriptions(
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

    final subscriptions = <ReportSubscription>[];
    bucket.forEach((label, amounts) {
      if (amounts.length < 2) return;
      final avg = amounts.reduce((a, b) => a + b) / amounts.length;
      final varianceOk = amounts.every(
        (a) => (a - avg).abs() <= (avg * 0.15 + 2),
      );
      if (!varianceOk) return;
      subscriptions.add(
        ReportSubscription(
          label: label,
          count: amounts.length,
          avgAmount: avg,
        ),
      );
    });

    subscriptions.sort((a, b) => b.avgAmount.compareTo(a.avgAmount));
    return subscriptions.take(6).toList();
  }
}
