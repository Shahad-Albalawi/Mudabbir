import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/constants/api_constants.dart';
import 'package:mudabbir/presentation/resources/chatbot_llm_prompt.dart';
import 'package:mudabbir/presentation/resources/chatbot_ui_strings.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/utils/dev_log.dart';
import 'package:mudabbir/service/reporting/financial_report_service.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;
import 'chatbot_view.dart';

enum ChatQuickAction { createGoal, adjustBudget, reduceCategory, exportReport }
enum PendingCommandType { createGoal, createBudget }

class ExecutedCommand {
  final String table;
  final int rowId;
  final String summary;

  ExecutedCommand({
    required this.table,
    required this.rowId,
    required this.summary,
  });
}

class ChatbotViewModel extends BaseViewModel {
  final DbHelper _dbHelper = getIt<DbHelper>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<ChatMessage> messages = [];
  bool isLoadingResponse = false;
  final FinancialReportService _reportService = getIt<FinancialReportService>();
  PendingCommandType? _pendingCommandType;
  Map<String, dynamic>? _pendingCommandPayload;
  ExecutedCommand? _lastExecutedCommand;

  static const Duration _apiTimeout = Duration(seconds: 45);

  List<String> get _apiUrls => [
    '${ApiConstants.baseUrl}/api/generate-content',
    '${ApiConstants.baseUrl}/api/chatbot/generate-content',
    '${ApiConstants.baseUrl}/api/chat',
  ];

  Future<void> initialize() async {
    setBusy(true);
    // Add a welcome message
    messages.add(
      ChatMessage(
        text: AppStrings.chatWelcomeMessage,
        isUser: false,
      ),
    );
    setBusy(false);
    notifyListeners();
  }

  Future<void> handleQuickAction(
    ChatQuickAction action,
    BuildContext context,
  ) async {
    switch (action) {
      case ChatQuickAction.createGoal:
        await _openCreateGoalDialog(context);
        return;
      case ChatQuickAction.adjustBudget:
        await _openAdjustBudgetDialog(context);
        return;
      case ChatQuickAction.reduceCategory:
        messages.add(
          ChatMessage(
            text: ChatbotUi.reduceCategoryHint,
            isUser: false,
          ),
        );
        notifyListeners();
        _scrollToBottom();
        return;
      case ChatQuickAction.exportReport:
        await _exportPdfReport();
        return;
    }
  }

  bool get canUndoLastAction => _lastExecutedCommand != null;

  Future<void> undoLastAction() async {
    final last = _lastExecutedCommand;
    if (last == null) {
      messages.add(
        ChatMessage(text: ChatbotUi.undoNone, isUser: false),
      );
      notifyListeners();
      _scrollToBottom();
      return;
    }

    try {
      final affected = await _dbHelper.delete(last.table, 'id=?', [last.rowId]);
      if (affected > 0) {
        await _auditLog(
          action: 'undo',
          status: 'undone',
          payload: {'table': last.table, 'row_id': last.rowId, 'summary': last.summary},
        );
        messages.add(
          ChatMessage(text: ChatbotUi.undoDone(last.summary), isUser: false),
        );
        _lastExecutedCommand = null;
      } else {
        messages.add(
          ChatMessage(
            text: ChatbotUi.undoMissing,
            isUser: false,
          ),
        );
      }
    } catch (_) {
      messages.add(
        ChatMessage(text: ChatbotUi.undoError, isUser: false),
      );
    }
    notifyListeners();
    _scrollToBottom();
  }

  Future<void> sendMessage() async {
    final userMessage = messageController.text.trim();
    if (userMessage.isEmpty) return;

    // Add user message
    messages.add(ChatMessage(text: userMessage, isUser: true));
    messageController.clear();
    notifyListeners();

    // Scroll to bottom
    _scrollToBottom();

    // Confirm / cancel pending smart command before anything else.
    final pendingReply = await _handlePendingCommandReply(userMessage);
    if (pendingReply != null) {
      messages.add(ChatMessage(text: pendingReply, isUser: false));
      notifyListeners();
      _scrollToBottom();
      return;
    }

    // Smart parser: execute direct commands from user text.
    final smartActionReply = await _tryExecuteSmartTextCommand(userMessage);
    if (smartActionReply != null) {
      messages.add(ChatMessage(text: smartActionReply, isUser: false));
      notifyListeners();
      _scrollToBottom();
      return;
    }

    // Check for simple general questions first (offline)
    final simpleAnswer = _handleSimpleQuestions(userMessage);
    if (simpleAnswer != null) {
      messages.add(ChatMessage(text: simpleAnswer, isUser: false));
      notifyListeners();
      _scrollToBottom();
      return;
    }

    // What-if calculator (phase 2): e.g. "لو اوفر 300 كل شهر متى اوصل هدفي؟"
    if (_isWhatIfQuestion(userMessage)) {
      isLoadingResponse = true;
      notifyListeners();
      try {
        final contextData = await _getAllDatabaseContext();
        final whatIfReply = _buildWhatIfReply(userMessage, contextData);
        messages.add(ChatMessage(text: whatIfReply, isUser: false));
      } catch (_) {
        messages.add(
          ChatMessage(
            text: ChatbotUi.whatIfError,
            isUser: false,
          ),
        );
      } finally {
        isLoadingResponse = false;
        notifyListeners();
        _scrollToBottom();
      }
      return;
    }

    if (_isGoalOptimizerQuestion(userMessage)) {
      isLoadingResponse = true;
      notifyListeners();
      try {
        final contextData = await _getAllDatabaseContext();
        final reply = _buildGoalOptimizerReply(contextData);
        messages.add(ChatMessage(text: reply, isUser: false));
      } finally {
        isLoadingResponse = false;
        notifyListeners();
        _scrollToBottom();
      }
      return;
    }

    if (_isReportQuestion(userMessage)) {
      await _exportPdfReport();
      return;
    }

    // Subscription detection (phase 2): repeated monthly-like expenses.
    if (_isSubscriptionQuestion(userMessage)) {
      isLoadingResponse = true;
      notifyListeners();
      try {
        final contextData = await _getAllDatabaseContext();
        final subscriptionReply = _buildSubscriptionsReply(contextData);
        messages.add(ChatMessage(text: subscriptionReply, isUser: false));
      } catch (_) {
        messages.add(
          ChatMessage(
            text: ChatbotUi.subsError,
            isUser: false,
          ),
        );
      } finally {
        isLoadingResponse = false;
        notifyListeners();
        _scrollToBottom();
      }
      return;
    }

    // Phase 1: answer financial health / abnormal spending questions locally.
    if (_isInsightQuestion(userMessage)) {
      isLoadingResponse = true;
      notifyListeners();
      try {
        final contextData = await _getAllDatabaseContext();
        final insightReply = _buildInsightReply(contextData);
        messages.add(ChatMessage(text: insightReply, isUser: false));
      } catch (_) {
        messages.add(
          ChatMessage(
            text: ChatbotUi.insightError,
            isUser: false,
          ),
        );
      } finally {
        isLoadingResponse = false;
        notifyListeners();
        _scrollToBottom();
      }
      return;
    }

    // Set loading state
    isLoadingResponse = true;
    notifyListeners();

    try {
      // Get all data from database
      final contextData = await _getAllDatabaseContext();
      contextData['financial_insights'] = _buildFinancialInsights(contextData);
      contextData['subscription_insights'] = _buildSubscriptionInsights(contextData);

      // Build the complete prompt with system instructions and user message
      final completePrompt = _buildCompletePrompt(contextData, userMessage);

      // Send to Laravel backend
      final response = await _sendToBackend(completePrompt);

      // Add AI response
      messages.add(ChatMessage(text: response, isUser: false));
    } catch (e) {
      messages.add(
        ChatMessage(
          text: ChatbotUi.genericProcessError,
          isUser: false,
        ),
      );
    } finally {
      isLoadingResponse = false;
      notifyListeners();
      _scrollToBottom();
    }
  }

  Future<String?> _handlePendingCommandReply(String message) async {
    if (_pendingCommandType == null || _pendingCommandPayload == null) {
      return null;
    }

    final q = message.trim().toLowerCase();
    final isConfirm = q == 'تأكيد' ||
        q == 'confirm' ||
        q == 'yes' ||
        q == 'ok' ||
        q == 'نفذ' ||
        q == 'نفّذ';
    final isCancel = q == 'إلغاء' ||
        q == 'الغاء' ||
        q == 'cancel' ||
        q == 'no' ||
        q == 'stop';

    if (!isConfirm && !isCancel) {
      return ChatbotUi.pendingHint;
    }

    if (isCancel) {
      await _auditLog(
        action: 'pending_command',
        status: 'cancelled',
        payload: {'type': _pendingCommandType.toString(), 'payload': _pendingCommandPayload},
      );
      _pendingCommandType = null;
      _pendingCommandPayload = null;
      return ChatbotUi.pendingCancelled;
    }

    final type = _pendingCommandType!;
    final payload = _pendingCommandPayload!;
    _pendingCommandType = null;
    _pendingCommandPayload = null;

    switch (type) {
      case PendingCommandType.createGoal:
        final rowId = await _dbHelper.insert('goals', {
          'name': payload['name'],
          'target': payload['target'],
          'current_amount': 0.0,
          'type': 'Saving',
          'start_date': payload['start_date'],
          'end_date': payload['end_date'],
        });
        _lastExecutedCommand = ExecutedCommand(
          table: 'goals',
          rowId: rowId,
          summary: ChatbotUi.goalCreatedSummary(payload['name'].toString()),
        );
        await _auditLog(
          action: 'create_goal',
          status: 'executed',
          payload: {'id': rowId, ...payload},
        );
        return ChatbotUi.goalCreatedOk(payload['name'].toString());
      case PendingCommandType.createBudget:
        final rowId = await _dbHelper.insert('budgets', {
          'amount': payload['amount'],
          'start_date': payload['start_date'],
          'end_date': payload['end_date'],
          'account_id': payload['account_id'],
        });
        _lastExecutedCommand = ExecutedCommand(
          table: 'budgets',
          rowId: rowId,
          summary: ChatbotUi.budgetCreatedSummary(
            payload['amount'].toStringAsFixed(0),
          ),
        );
        await _auditLog(
          action: 'create_budget',
          status: 'executed',
          payload: {'id': rowId, ...payload},
        );
        return ChatbotUi.budgetCreatedOk(
          payload['amount'].toStringAsFixed(0),
        );
    }
  }

  Future<String?> _tryExecuteSmartTextCommand(String message) async {
    final q = message.trim();
    final lower = q.toLowerCase();

    // Example supported phrases:
    // "أنشئ هدف سيارة 25000 خلال 12 شهر"
    // "create goal car 25000 in 12 months"
    if (lower.contains('أنشئ هدف') ||
        lower.contains('انشئ هدف') ||
        lower.contains('create goal')) {
      final amount = _extractFirstNumber(q);
      if (amount == null || amount <= 0) {
        return ChatbotUi.needGoalAmount;
      }

      final months = _extractMonths(q) ?? 12;
      final goalName = _extractGoalName(q);
      final now = DateTime.now();
      final end = DateTime(now.year, now.month + months, now.day);
      _pendingCommandType = PendingCommandType.createGoal;
      _pendingCommandPayload = {
        'name': goalName,
        'target': amount,
        'start_date': now.toIso8601String().split('T')[0],
        'end_date': end.toIso8601String().split('T')[0],
      };
      await _auditLog(
        action: 'create_goal',
        status: 'preview',
        payload: _pendingCommandPayload,
      );

      return ChatbotUi.previewGoal(
        goalName,
        amount.toStringAsFixed(0),
        months,
      );
    }

    // Example:
    // "أنشئ ميزانية 3000 الشهر القادم"
    // "set budget 3000"
    if (lower.contains('أنشئ ميزانية') ||
        lower.contains('انشئ ميزانية') ||
        lower.contains('set budget') ||
        lower.contains('create budget')) {
      final amount = _extractFirstNumber(q);
      if (amount == null || amount <= 0) {
        return ChatbotUi.needBudgetAmount;
      }

      final accountsResult = await _dbHelper.queryAllRows('accounts');
      final accountId = accountsResult.fold<int?>(
        (_) => null,
        (data) => data.isNotEmpty ? data.first['id'] as int? : null,
      );
      if (accountId == null) {
        return ChatbotUi.noAccountForBudget;
      }

      final now = DateTime.now();
      final start = DateTime(now.year, now.month + 1, 1);
      final end = DateTime(now.year, now.month + 2, 0);
      _pendingCommandType = PendingCommandType.createBudget;
      _pendingCommandPayload = {
        'amount': amount,
        'start_date': start.toIso8601String().split('T')[0],
        'end_date': end.toIso8601String().split('T')[0],
        'account_id': accountId,
      };
      await _auditLog(
        action: 'create_budget',
        status: 'preview',
        payload: _pendingCommandPayload,
      );
      return ChatbotUi.previewBudget(
        amount.toStringAsFixed(0),
        start.toIso8601String().split('T')[0],
        end.toIso8601String().split('T')[0],
      );
    }

    return null;
  }

  int? _extractMonths(String text) {
    final monthRegex = RegExp(
      r'(\d+)\s*(شهر|شهور|months?|month)',
      caseSensitive: false,
    );
    final match = monthRegex.firstMatch(text);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  String _extractGoalName(String text) {
    final cleaned = text
        .replaceAll(RegExp(r'create goal', caseSensitive: false), '')
        .replaceAll('أنشئ هدف', '')
        .replaceAll('انشئ هدف', '')
        .trim();
    // Remove first number and trailing duration phrase.
    var name = cleaned.replaceFirst(RegExp(r'\d+(\.\d+)?'), '').trim();
    name = name.replaceAll(
      RegExp(
        r'(خلال|in)\s*\d+\s*(شهر|شهور|months?|month)',
        caseSensitive: false,
      ),
      '',
    );
    name = name.trim();
    if (name.isEmpty) return ChatbotUi.defaultNewGoalName;
    return name;
  }

  bool _isInsightQuestion(String message) {
    final q = message.toLowerCase();
    return q.contains('الصحة المالية') ||
        q.contains('score') ||
        q.contains('سكور') ||
        q.contains('تقييمي') ||
        q.contains('الانفاق مرتفع') ||
        q.contains('غير طبيعي') ||
        q.contains('تنبيه');
  }

  bool _isWhatIfQuestion(String message) {
    final q = message.toLowerCase();
    return q.contains('ماذا لو') ||
        q.contains('لو ') ||
        q.contains('what if') ||
        q.contains('اوفر') ||
        q.contains('أوفر') ||
        q.contains('ادخر') ||
        q.contains('أدخر');
  }

  bool _isSubscriptionQuestion(String message) {
    final q = message.toLowerCase();
    return q.contains('اشتراك') ||
        q.contains('الاشتراكات') ||
        q.contains('متكرر') ||
        q.contains('شهري') ||
        q.contains('subscription');
  }

  bool _isGoalOptimizerQuestion(String message) {
    final q = message.toLowerCase();
    return q.contains('goal optimizer') ||
        q.contains('optimize') ||
        q.contains('حسن اهدافي') ||
        q.contains('وزع الادخار') ||
        q.contains('خطة الأهداف');
  }

  bool _isReportQuestion(String message) {
    final q = message.toLowerCase();
    return q.contains('pdf') ||
        q.contains('report') ||
        q.contains('تقرير') ||
        q.contains('تصدير');
  }

  String _buildInsightReply(Map<String, dynamic> contextData) {
    final insights = _buildFinancialInsights(contextData);
    final int score = insights['score'] as int;
    final List<String> alerts = (insights['alerts'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    final status = ChatbotUi.insightStatus(score);
    final alertText = alerts.isEmpty
        ? ChatbotUi.noSpendingAlerts
        : alerts.map((a) => '- $a').join('\n');
    return ChatbotUi.insightBody(score, status, alertText);
  }

  String _buildWhatIfReply(String userMessage, Map<String, dynamic> contextData) {
    final amount = _extractFirstNumber(userMessage);
    if (amount == null || amount <= 0) {
      return ChatbotUi.whatIfNeedAmount;
    }

    final goalsRaw = contextData['goals'];
    final goals = goalsRaw is List ? goalsRaw.cast<dynamic>() : const <dynamic>[];
    if (goals.isEmpty) {
      return ChatbotUi.whatIfNoGoals;
    }

    Map<String, dynamic>? nearestGoal;
    double nearestRemaining = double.infinity;

    for (final g in goals) {
      if (g is! Map) continue;
      final target = double.tryParse((g['target'] ?? '0').toString()) ?? 0;
      final current = double.tryParse((g['current_amount'] ?? '0').toString()) ?? 0;
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
    final target = double.tryParse((nearestGoal['target'] ?? '0').toString()) ?? 0;
    final current = double.tryParse((nearestGoal['current_amount'] ?? '0').toString()) ?? 0;
    final remaining = (target - current).clamp(0, double.infinity);
    final months = remaining / amount;
    final roundedMonths = months.ceil();
    final eta = DateTime.now().add(Duration(days: roundedMonths * 30));
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

  String _buildGoalOptimizerReply(Map<String, dynamic> contextData) {
    final goalsRaw = contextData['goals'];
    final goals = goalsRaw is List ? goalsRaw.cast<dynamic>() : const <dynamic>[];
    if (goals.isEmpty) {
      return ChatbotUi.optimizerNoGoals;
    }

    final insights = _buildFinancialInsights(contextData);
    final monthlyBalance = (insights['monthly_balance'] as num?)?.toDouble() ?? 0;
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
      final current = double.tryParse((g['current_amount'] ?? '0').toString()) ?? 0;
      final remaining = target - current;
      if (remaining <= 0) continue;
      final endDate = DateTime.tryParse((g['end_date'] ?? '').toString());
      final daysLeft = endDate == null ? 365 : endDate.difference(DateTime.now()).inDays;
      parsed.add({
        'name': name,
        'remaining': remaining,
        'daysLeft': daysLeft <= 0 ? 1 : daysLeft,
      });
    }

    if (parsed.isEmpty) {
      return ChatbotUi.optimizerGoalsDone;
    }

    parsed.sort((a, b) => (a['daysLeft'] as int).compareTo(b['daysLeft'] as int));
    final weights = parsed.map((g) => 1 / (g['daysLeft'] as int)).toList();
    final totalWeight = weights.reduce((a, b) => a + b);

    final lines = <String>[];
    for (int i = 0; i < parsed.length; i++) {
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

  double? _extractFirstNumber(String text) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }

  Map<String, dynamic> _buildFinancialInsights(Map<String, dynamic> contextData) {
    final txRaw = contextData['transactions'];
    final tx = txRaw is List ? txRaw.cast<dynamic>() : const <dynamic>[];
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final previousMonth = DateTime(now.year, now.month - 1);

    double monthlyIncome = 0;
    double monthlyExpense = 0;
    double previousExpense = 0;

    for (final item in tx) {
      if (item is! Map) continue;
      final date = DateTime.tryParse((item['date'] ?? '').toString());
      if (date == null) continue;
      final amount = double.tryParse((item['amount'] ?? '0').toString()) ?? 0;
      final type = (item['type'] ?? '').toString().toLowerCase();
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
    score = score.clamp(0, 100);

    final alerts = <String>[];
    if (monthlyIncome > 0 && monthlyExpense > monthlyIncome) {
      alerts.add(ChatbotUi.alertExpenseOverIncome);
    }
    if (previousExpense > 0) {
      final growth = (monthlyExpense - previousExpense) / previousExpense;
      if (growth >= 0.25) {
        alerts.add(
          ChatbotUi.alertSpendingGrowth((growth * 100).toStringAsFixed(0)),
        );
      }
    }

    return {
      'monthly_income': monthlyIncome,
      'monthly_expense': monthlyExpense,
      'monthly_balance': monthlyBalance,
      'score': score,
      'alerts': alerts,
    };
  }

  String _buildSubscriptionsReply(Map<String, dynamic> contextData) {
    final insights = _buildSubscriptionInsights(contextData);
    final items = (insights['subscriptions'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    if (items.isEmpty) {
      return ChatbotUi.subsNone;
    }

    final total = items.fold<double>(
      0,
      (sum, item) => sum + ((item['avg_amount'] as num?)?.toDouble() ?? 0),
    );
    final lines = items.take(5).map((item) {
      final name = item['label'].toString();
      final amount = ((item['avg_amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(0);
      final count = item['count'] is int
          ? item['count'] as int
          : int.tryParse(item['count'].toString()) ?? 0;
      return ChatbotUi.subsLine(name, amount, count);
    }).join('\n');

    return ChatbotUi.subsSummary(lines, total.toStringAsFixed(0));
  }

  Map<String, dynamic> _buildSubscriptionInsights(Map<String, dynamic> contextData) {
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
      final label =
          rawNotes.isEmpty ? ChatbotUi.unnamedRecurring : rawNotes.toLowerCase();
      bucket.putIfAbsent(label, () => <double>[]).add(amount);
    }

    final subscriptions = <Map<String, dynamic>>[];
    bucket.forEach((label, amounts) {
      if (amounts.length < 2) return;
      final avg = amounts.reduce((a, b) => a + b) / amounts.length;
      final varianceOk = amounts.every((a) => (a - avg).abs() <= (avg * 0.15 + 2));
      if (!varianceOk) return;
      subscriptions.add({
        'label': label,
        'count': amounts.length,
        'avg_amount': avg,
      });
    });

    subscriptions.sort((a, b) => ((b['avg_amount'] as num).toDouble())
        .compareTo((a['avg_amount'] as num).toDouble()));

    return {'subscriptions': subscriptions};
  }

  Future<void> _exportPdfReport() async {
    isLoadingResponse = true;
    notifyListeners();
    try {
      final contextData = await _getAllDatabaseContext();
      final insights = _buildFinancialInsights(contextData);
      final categoryBreakdown = _buildCategoryExpenseBreakdown(contextData);
      await _reportService.shareMonthlyReport(
        income: (insights['monthly_income'] as num?)?.toDouble() ?? 0,
        expense: (insights['monthly_expense'] as num?)?.toDouble() ?? 0,
        balance: (insights['monthly_balance'] as num?)?.toDouble() ?? 0,
        healthScore: (insights['score'] as int?) ?? 0,
        alerts: (insights['alerts'] as List<dynamic>).map((e) => e.toString()).toList(),
        categoryBreakdown: categoryBreakdown,
      );
      messages.add(
        ChatMessage(
          text: ChatbotUi.pdfOk,
          isUser: false,
        ),
      );
    } catch (_) {
      messages.add(
        ChatMessage(
          text: ChatbotUi.pdfFail,
          isUser: false,
        ),
      );
    } finally {
      isLoadingResponse = false;
      notifyListeners();
      _scrollToBottom();
    }
  }

  Future<void> _auditLog({
    required String action,
    required String status,
    Map<String, dynamic>? payload,
  }) async {
    try {
      await _dbHelper.insert('action_audit_logs', {
        'action': action,
        'status': status,
        'payload': payload == null ? null : jsonEncode(payload),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Keep feature non-blocking if audit log insert fails.
    }
  }

  Map<String, double> _buildCategoryExpenseBreakdown(
    Map<String, dynamic> contextData,
  ) {
    final txRaw = contextData['transactions'];
    final tx = txRaw is List ? txRaw.cast<dynamic>() : const <dynamic>[];
    final categoriesRaw = contextData['categories'];
    final categories =
        categoriesRaw is List ? categoriesRaw.cast<dynamic>() : const <dynamic>[];

    final catMap = <int, String>{};
    for (final c in categories) {
      if (c is! Map) continue;
      final id = int.tryParse((c['id'] ?? '').toString());
      final name = (c['name'] ?? '').toString();
      if (id != null && name.isNotEmpty) {
        catMap[id] = name;
      }
    }

    final now = DateTime.now();
    final bucket = <String, double>{};
    for (final t in tx) {
      if (t is! Map) continue;
      final type = (t['type'] ?? '').toString().toLowerCase();
      if (type != 'expense') continue;
      final date = DateTime.tryParse((t['date'] ?? '').toString());
      if (date == null || date.year != now.year || date.month != now.month) {
        continue;
      }
      final amount = double.tryParse((t['amount'] ?? '0').toString()) ?? 0;
      final catId = int.tryParse((t['category_id'] ?? '').toString());
      final name = catId != null ? (catMap[catId] ?? 'Other') : 'Other';
      bucket[name] = (bucket[name] ?? 0) + amount;
    }
    return bucket;
  }

  Future<void> _openCreateGoalDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(ChatbotUi.dlgCreateGoalTitle),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: ChatbotUi.dlgGoalNameLabel),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? ChatbotUi.requiredField : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: ChatbotUi.dlgGoalTargetLabel),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return ChatbotUi.invalidNumber;
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ChatbotUi.dlgCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final now = DateTime.now();
                final end = DateTime(now.year + 1, now.month, now.day);
                await _dbHelper.insert('goals', {
                  'name': nameCtrl.text.trim(),
                  'target': double.parse(amountCtrl.text),
                  'current_amount': 0.0,
                  'type': 'Saving',
                  'start_date': now.toIso8601String().split('T')[0],
                  'end_date': end.toIso8601String().split('T')[0],
                });
                if (ctx.mounted) Navigator.pop(ctx);
                messages.add(
                  ChatMessage(
                    text: ChatbotUi.goalCreatedDialog(nameCtrl.text),
                    isUser: false,
                  ),
                );
                notifyListeners();
                _scrollToBottom();
              },
              child: Text(ChatbotUi.dlgCreate),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openAdjustBudgetDialog(BuildContext context) async {
    final amountCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(ChatbotUi.dlgAdjustBudgetTitle),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: ChatbotUi.dlgMonthlyBudgetLabel),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n <= 0) return ChatbotUi.invalidNumber;
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ChatbotUi.dlgCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final accountsResult = await _dbHelper.queryAllRows('accounts');
                final accountId = accountsResult.fold<int?>(
                  (_) => null,
                  (data) => data.isNotEmpty ? data.first['id'] as int? : null,
                );
                if (accountId == null) {
                  messages.add(
                    ChatMessage(
                      text: ChatbotUi.noAccountForBudget,
                      isUser: false,
                    ),
                  );
                  notifyListeners();
                  _scrollToBottom();
                  if (ctx.mounted) Navigator.pop(ctx);
                  return;
                }

                final now = DateTime.now();
                final start = DateTime(now.year, now.month + 1, 1);
                final end = DateTime(now.year, now.month + 2, 0);
                await _dbHelper.insert('budgets', {
                  'amount': double.parse(amountCtrl.text),
                  'start_date': start.toIso8601String().split('T')[0],
                  'end_date': end.toIso8601String().split('T')[0],
                  'account_id': accountId,
                });
                if (ctx.mounted) Navigator.pop(ctx);
                messages.add(
                  ChatMessage(
                    text: ChatbotUi.budgetCreatedDialog(
                      double.parse(amountCtrl.text).toStringAsFixed(0),
                    ),
                    isUser: false,
                  ),
                );
                notifyListeners();
                _scrollToBottom();
              },
              child: Text(ChatbotUi.dlgSave),
            ),
          ],
        );
      },
    );
  }

  String? _handleSimpleQuestions(String question) {
    final q = question.toLowerCase().trim();
    final now = DateTime.now();

    // Handle name questions
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

    // Handle greeting
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

    // Handle time questions
    if ((q.contains('كم الساعة') ||
            q.contains('الوقت') ||
            q.contains('what time') ||
            q.contains('current time')) &&
        !q.contains('معاملة') &&
        !q.contains('تحويل')) {
      final hour = now.hour;
      final minute = now.minute.toString().padLeft(2, '0');
      final isPm = hour >= 12;
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return ChatbotUi.timeNow(displayHour, minute, isPm);
    }

    // Handle date questions
    if (q.contains('التاريخ') ||
        q.contains('تاريخ اليوم') ||
        q.contains('اليوم') && !q.contains('نفقات') && !q.contains('مصروفات') ||
        q.contains('what date') ||
        q.contains('today\'s date') ||
        q == 'date' ||
        q == 'date?') {
      final dayName = ChatbotUi.weekdays[now.weekday % 7];
      final monthName = ChatbotUi.months[now.month - 1];
      return ChatbotUi.dateToday(dayName, now.day, monthName, now.year);
    }

    // Handle thank you
    if (q.contains('شكرا') || q.contains('شكراً') || q.contains('thank')) {
      return ChatbotUi.thanksReply;
    }

    // Handle how are you
    if (q.contains('كيف حالك') ||
        q.contains('كيفك') ||
        q == 'how are you' ||
        q == 'how are you?') {
      return ChatbotUi.howAreYouReply;
    }

    return null; // Let AI handle it
  }

  Future<Map<String, dynamic>> _getAllDatabaseContext() async {
    final context = <String, dynamic>{};

    try {
      // Get accounts
      final accountsResult = await _dbHelper.queryAllRows('accounts');
      accountsResult.fold(
        (empty) => context['accounts'] = [],
        (data) => context['accounts'] = data,
      );

      // Get categories
      final categoriesResult = await _dbHelper.queryAllRows('categories');
      categoriesResult.fold(
        (empty) => context['categories'] = [],
        (data) => context['categories'] = data,
      );

      // Get transactions
      final transactionsResult = await _dbHelper.queryAllRows('transactions');
      transactionsResult.fold(
        (empty) => context['transactions'] = [],
        (data) => context['transactions'] = data,
      );

      // Get budgets
      final budgetsResult = await _dbHelper.queryAllRows('budgets');
      budgetsResult.fold(
        (empty) => context['budgets'] = [],
        (data) => context['budgets'] = data,
      );

      // Get goals
      final goalsResult = await _dbHelper.queryAllRows('goals');
      goalsResult.fold(
        (empty) => context['goals'] = [],
        (data) => context['goals'] = data,
      );

      // Get challenges
      final challengesResult = await _dbHelper.queryAllRows('challenges');
      challengesResult.fold(
        (empty) => context['challenges'] = [],
        (data) => context['challenges'] = data,
      );
    } catch (e) {
      devLog('Error fetching database context: $e');
    }

    return context;
  }

  String _buildCompletePrompt(
    Map<String, dynamic> contextData,
    String userMessage,
  ) {
    return ChatbotLlmPrompt.build(
      contextData: contextData,
      userMessage: userMessage,
      formatJson: _formatJsonData,
    );
  }

  String _formatJsonData(dynamic data) {
    if (data == null || (data is List && data.isEmpty)) {
      return ChatbotUi.jsonNoData;
    }
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  Future<String> _sendToBackend(String content) async {
    Object? lastError;

    for (final url in _apiUrls) {
      devLog(
        '[Chatbot API] Trying $url (timeout: ${_apiTimeout.inSeconds}s)',
      );

      for (final body in _candidatePayloads(content)) {
        try {
          final stopwatch = Stopwatch()..start();
          final response = await http
              .post(
                Uri.parse(url),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: jsonEncode(body),
              )
              .timeout(
                _apiTimeout,
                onTimeout: () => throw TimeoutException('طلب الموارد'),
              );

          stopwatch.stop();
          devLog(
            '[Chatbot API] ${response.statusCode} ${stopwatch.elapsedMilliseconds}ms body=$body',
          );

          if (response.statusCode == 200) {
            final result = _parseApiResponse(response.bodyBytes);
            if (result.isNotEmpty) {
              return result;
            }
          }

          if (response.statusCode == 429) {
            return ChatbotUi.rateLimited;
          }

          // If backend returns internal error with specific code like 53, map to friendly text.
          if (response.statusCode >= 500) {
            final serverMessage = _extractServerErrorMessage(
              response.bodyBytes,
            );
            if (serverMessage.contains('53')) {
              return ChatbotUi.server53;
            }
            lastError = 'HTTP ${response.statusCode}: $serverMessage';
            continue;
          }

          // 404/405 may indicate wrong endpoint/body shape, so continue trying fallbacks.
          if (response.statusCode == 404 ||
              response.statusCode == 405 ||
              response.statusCode == 422) {
            lastError = 'HTTP ${response.statusCode}';
            continue;
          }

          // For other status codes, stop and return a clear code.
          return ChatbotUi.httpError(response.statusCode);
        } on TimeoutException {
          // Timeout is likely global connectivity/latency issue; no need to keep retrying many shapes.
          return ChatbotUi.requestTimeout;
        } on http.ClientException catch (e) {
          lastError = e;
          continue;
        } on SocketException catch (e) {
          lastError = e;
          continue;
        } catch (e) {
          lastError = e;
          continue;
        }
      }
    }

    devLog('[Chatbot API] All retries failed: $lastError');
    if (lastError is SocketException || lastError is http.ClientException) {
      return ChatbotUi.noInternet;
    }
    return ChatbotUi.assistantUnreachable;
  }

  /// Parse API response - supports multiple backend formats.
  String _parseApiResponse(List<int> bodyBytes) {
    try {
      final body = utf8.decode(bodyBytes, allowMalformed: true);
      final json = jsonDecode(body) as Map<String, dynamic>;
      // Try common response formats
      final message =
          json['message'] ??
          json['data']?['message'] ??
          json['text'] ??
          json['response'] ??
          json['content'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString().trim();
      }
      if (json['data'] != null) {
        final data = json['data'];
        if (data is Map) {
          final msg = data['message'] ?? data['text'] ?? data['content'];
          if (msg != null) return msg.toString().trim();
        }
        if (data is String && data.trim().isNotEmpty) return data.trim();
      }
      return ChatbotUi.parseResponseFail;
    } catch (_) {
      return ChatbotUi.parseError;
    }
  }

  List<Map<String, dynamic>> _candidatePayloads(String content) {
    return [
      {'content': content},
      {'prompt': content},
      {'message': content},
      {'input': content},
    ];
  }

  String _extractServerErrorMessage(List<int> bodyBytes) {
    try {
      final body = utf8.decode(bodyBytes, allowMalformed: true);
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final msg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (msg != null) return msg.toString();
      }
      return body;
    } catch (_) {
      return 'Server error';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearMessages() {
    messages.clear();
    messages.add(
      ChatMessage(
        text: ChatbotUi.chatCleared,
        isUser: false,
      ),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
