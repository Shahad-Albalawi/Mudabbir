import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/api_constants.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/presentation/resources/chatbot_llm_prompt.dart';
import 'package:mudabbir/presentation/resources/chatbot_ui_strings.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/server_challenges/utils/dio_client.dart';
import 'package:mudabbir/service/chatbot/chatbot_api_client.dart';
import 'package:mudabbir/service/chatbot/chatbot_context_loader.dart';
import 'package:mudabbir/service/chatbot/chatbot_insights_engine.dart';
import 'package:mudabbir/service/chatbot/chatbot_local_fallback.dart';
import 'package:mudabbir/service/chatbot/chatbot_models.dart';
import 'package:mudabbir/service/chatbot/chatbot_text_parser.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';
import 'package:mudabbir/presentation/widgets/ios_dialog_style.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/reporting/financial_report_exporter.dart';

export 'package:mudabbir/service/chatbot/chatbot_models.dart';

class ChatbotNotifier extends StateNotifier<ChatbotState> {
  ChatbotNotifier() : super(const ChatbotState());

  final DbHelper _dbHelper = getIt<DbHelper>();
  final ChatbotContextLoader _contextLoader = ChatbotContextLoader();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  PendingCommandType? _pendingCommandType;
  Map<String, dynamic>? _pendingCommandPayload;

  late final ChatbotApiClient _apiClient = ChatbotApiClient(
    dio: getIt<DioClient>().dio,
    apiUrls: [
      '${ApiConstants.baseUrl}/api/generate-content',
      '${ApiConstants.baseUrl}/api/chatbot/generate-content',
      '${ApiConstants.baseUrl}/api/chat',
    ],
  );

  void _appendMessage(ChatMessage message) {
    state = state.copyWith(messages: [...state.messages, message]);
  }

  void _setLoading(bool value) => state = state.copyWith(isLoading: value);

  void _setLoadingResponse(bool value) =>
      state = state.copyWith(isLoadingResponse: value);

  void _setLastExecuted(ExecutedCommand? command) {
    state = state.copyWith(
      lastExecutedCommand: command,
      clearLastExecutedCommand: command == null,
    );
  }

  Future<void> initialize() async {
    _setLoading(true);
    _appendMessage(
      ChatMessage(text: AppStrings.chatWelcomeMessage, isUser: false),
    );
    _setLoading(false);
  }

  Future<void> handleQuickAction(
    ChatQuickAction action,
    BuildContext context,
  ) async {
    switch (action) {
      case ChatQuickAction.createGoal:
        await _openCreateGoalDialog(context);
      case ChatQuickAction.adjustBudget:
        await _openAdjustBudgetDialog(context);
      case ChatQuickAction.reduceCategory:
        _appendMessage(
          ChatMessage(text: ChatbotUi.reduceCategoryHint, isUser: false),
        );
        _scrollToBottom();
      case ChatQuickAction.exportReport:
        await _exportPdfReport();
    }
  }

  bool get canUndoLastAction => state.lastExecutedCommand != null;

  Future<void> undoLastAction() async {
    final last = state.lastExecutedCommand;
    if (last == null) {
      _appendMessage(ChatMessage(text: ChatbotUi.undoNone, isUser: false));
      _scrollToBottom();
      return;
    }

    try {
      final affected = await _dbHelper.delete(last.table, 'id=?', [last.rowId]);
      if (affected > 0) {
        await _auditLog(
          action: 'undo',
          status: 'undone',
          payload: {
            'table': last.table,
            'row_id': last.rowId,
            'summary': last.summary,
          },
        );
        _appendMessage(
          ChatMessage(text: ChatbotUi.undoDone(last.summary), isUser: false),
        );
        _setLastExecuted(null);
      } else {
        _appendMessage(ChatMessage(text: ChatbotUi.undoMissing, isUser: false));
      }
    } catch (_) {
      _appendMessage(ChatMessage(text: ChatbotUi.undoError, isUser: false));
    }
    _scrollToBottom();
  }

  Future<void> sendMessage() async {
    final userMessage = messageController.text.trim();
    if (userMessage.isEmpty) return;
    messageController.clear();
    await _sendUserText(userMessage);
  }

  Future<void> sendSuggestedMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await _sendUserText(trimmed);
  }

  Future<void> _sendUserText(String userMessage) async {
    _appendMessage(ChatMessage(text: userMessage, isUser: true));
    _scrollToBottom();

    final pendingReply = await _handlePendingCommandReply(userMessage);
    if (pendingReply != null) {
      _appendMessage(ChatMessage(text: pendingReply, isUser: false));
      _scrollToBottom();
      return;
    }

    final smartActionReply = await _tryExecuteSmartTextCommand(userMessage);
    if (smartActionReply != null) {
      _appendMessage(ChatMessage(text: smartActionReply, isUser: false));
      _scrollToBottom();
      return;
    }

    final simpleAnswer = ChatbotInsightsEngine.handleSimpleQuestions(userMessage);
    if (simpleAnswer != null) {
      _appendMessage(ChatMessage(text: simpleAnswer, isUser: false));
      _scrollToBottom();
      return;
    }

    if (ChatbotTextParser.isWhatIfQuestion(userMessage)) {
      await _replyWithContext(
        (data) => ChatbotInsightsEngine.buildWhatIfReply(userMessage, data),
        errorMessage: ChatbotUi.whatIfError,
      );
      return;
    }

    if (ChatbotTextParser.isGoalOptimizerQuestion(userMessage)) {
      await _replyWithContext(ChatbotInsightsEngine.buildGoalOptimizerReply);
      return;
    }

    if (ChatbotTextParser.isReportQuestion(userMessage)) {
      await _exportPdfReport();
      return;
    }

    if (ChatbotTextParser.isSubscriptionQuestion(userMessage)) {
      await _replyWithContext(
        ChatbotInsightsEngine.buildSubscriptionsReply,
        errorMessage: ChatbotUi.subsError,
      );
      return;
    }

    if (ChatbotTextParser.isInsightQuestion(userMessage)) {
      await _replyWithContext(
        ChatbotInsightsEngine.buildInsightReply,
        errorMessage: ChatbotUi.insightError,
      );
      return;
    }

    _setLoadingResponse(true);
    try {
      final contextData = await _getAllDatabaseContext();
      contextData['financial_insights'] =
          ChatbotInsightsEngine.buildFinancialInsights(contextData);
      contextData['subscription_insights'] =
          ChatbotInsightsEngine.buildSubscriptionInsights(contextData);

      final completePrompt = ChatbotLlmPrompt.build(
        contextData: contextData,
        userMessage: userMessage,
        formatJson: _formatJsonData,
      );

      final apiResult = await _apiClient.send(completePrompt);

      if (apiResult.isSuccess && apiResult.message != null) {
        _appendMessage(ChatMessage(text: apiResult.message!, isUser: false));
      } else if (apiResult.useLocalFallback) {
        _appendMessage(
          ChatMessage(
            text: _buildLocalFallbackMessage(
              userMessage: userMessage,
              contextData: contextData,
              quotaExceeded: apiResult.quotaExceeded,
            ),
            isUser: false,
          ),
        );
      } else {
        _appendMessage(
          ChatMessage(
            text: apiResult.message ?? ChatbotUi.genericProcessError,
            isUser: false,
          ),
        );
      }
    } catch (_) {
      try {
        final contextData = await _getAllDatabaseContext();
        _appendMessage(
          ChatMessage(
            text: _buildLocalFallbackMessage(
              userMessage: userMessage,
              contextData: contextData,
              quotaExceeded: false,
            ),
            isUser: false,
          ),
        );
      } catch (_) {
        _appendMessage(
          ChatMessage(text: ChatbotUi.genericProcessError, isUser: false),
        );
      }
    } finally {
      _setLoadingResponse(false);
      _scrollToBottom();
    }
  }

  Future<void> _replyWithContext(
    String Function(Map<String, dynamic>) buildReply, {
    String? errorMessage,
  }) async {
    _setLoadingResponse(true);
    try {
      final contextData = await _getAllDatabaseContext();
      _appendMessage(ChatMessage(text: buildReply(contextData), isUser: false));
    } catch (_) {
      if (errorMessage != null) {
        _appendMessage(ChatMessage(text: errorMessage, isUser: false));
      }
    } finally {
      _setLoadingResponse(false);
      _scrollToBottom();
    }
  }

  Future<String?> _handlePendingCommandReply(String message) async {
    if (_pendingCommandType == null || _pendingCommandPayload == null) {
      return null;
    }

    final q = message.trim().toLowerCase();
    final isConfirm =
        q == 'تأكيد' ||
        q == 'confirm' ||
        q == 'yes' ||
        q == 'ok' ||
        q == 'نفذ' ||
        q == 'نفّذ';
    final isCancel =
        q == 'إلغاء' ||
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
        payload: {
          'type': _pendingCommandType.toString(),
          'payload': _pendingCommandPayload,
        },
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
        _setLastExecuted(ExecutedCommand(
          table: 'goals',
          rowId: rowId,
          summary: ChatbotUi.goalCreatedSummary(payload['name'].toString()),
        ));
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
        _setLastExecuted(ExecutedCommand(
          table: 'budgets',
          rowId: rowId,
          summary: ChatbotUi.budgetCreatedSummary(
            payload['amount'].toStringAsFixed(0),
          ),
        ));
        await _auditLog(
          action: 'create_budget',
          status: 'executed',
          payload: {'id': rowId, ...payload},
        );
        return ChatbotUi.budgetCreatedOk(payload['amount'].toStringAsFixed(0));
    }
  }

  Future<String?> _tryExecuteSmartTextCommand(String message) async {
    final q = message.trim();
    final lower = q.toLowerCase();

    if (lower.contains('أنشئ هدف') ||
        lower.contains('انشئ هدف') ||
        lower.contains('create goal')) {
      final amount = ChatbotTextParser.extractFirstNumber(q);
      if (amount == null || amount <= 0) {
        return ChatbotUi.needGoalAmount;
      }

      final months = ChatbotTextParser.extractMonths(q) ?? 12;
      final goalName = ChatbotTextParser.extractGoalName(q);
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

      return ChatbotUi.previewGoal(goalName, amount.toStringAsFixed(0), months);
    }

    if (lower.contains('أنشئ ميزانية') ||
        lower.contains('انشئ ميزانية') ||
        lower.contains('set budget') ||
        lower.contains('create budget')) {
      final amount = ChatbotTextParser.extractFirstNumber(q);
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

  Future<void> _exportPdfReport() async {
    _setLoadingResponse(true);
    try {
      await FinancialReportExporter().shareMonthlyReport();
      _appendMessage(ChatMessage(text: ChatbotUi.pdfOk, isUser: false));
    } catch (_) {
      _appendMessage(ChatMessage(text: ChatbotUi.pdfFail, isUser: false));
    } finally {
      _setLoadingResponse(false);
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
      // Non-blocking audit trail.
    }
  }

  Future<void> _openCreateGoalDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var saving = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return Dialog(
              shape: IOSDialogStyle.dialogShape(),
              child: Container(
                width: MediaQuery.of(ctx).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: IOSDialogStyle.surfaceDecoration(ctx),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IOSDialogStyle.header(
                        ctx,
                        title: ChatbotUi.dlgCreateGoalTitle,
                        icon: Icons.flag_outlined,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameCtrl,
                              decoration: InputDecoration(
                                labelText: ChatbotUi.dlgGoalNameLabel,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? ChatbotUi.requiredField
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: amountCtrl,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: ChatbotUi.dlgGoalTargetLabel,
                              ),
                              validator: (v) {
                                final n = double.tryParse(v ?? '');
                                if (n == null || n <= 0) {
                                  return ChatbotUi.invalidNumber;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: saving
                                    ? null
                                    : () => Navigator.pop(ctx),
                                child: Text(ChatbotUi.dlgCancel),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppLoadingButton(
                                isLoading: saving,
                                label: ChatbotUi.dlgCreate,
                                onPressed: () async {
                                  if (!(formKey.currentState?.validate() ??
                                      false)) {
                                    return;
                                  }
                                  setLocalState(() => saving = true);
                                  final now = DateTime.now();
                                  final end =
                                      DateTime(now.year + 1, now.month, now.day);
                                  await _dbHelper.insert('goals', {
                                    'name': nameCtrl.text.trim(),
                                    'target': double.parse(amountCtrl.text),
                                    'current_amount': 0.0,
                                    'type': 'Saving',
                                    'start_date':
                                        now.toIso8601String().split('T')[0],
                                    'end_date':
                                        end.toIso8601String().split('T')[0],
                                  });
                                  if (!ctx.mounted) return;
                                  setLocalState(() => saving = false);
                                  Navigator.pop(ctx);
                                  _appendMessage(
                                    ChatMessage(
                                      text: ChatbotUi.goalCreatedDialog(
                                        nameCtrl.text,
                                      ),
                                      isUser: false,
                                    ),
                                  );
                                  _scrollToBottom();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openAdjustBudgetDialog(BuildContext context) async {
    final amountCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var saving = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return Dialog(
              shape: IOSDialogStyle.dialogShape(),
              child: Container(
                width: MediaQuery.of(ctx).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: IOSDialogStyle.surfaceDecoration(ctx),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IOSDialogStyle.header(
                        ctx,
                        title: ChatbotUi.dlgAdjustBudgetTitle,
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                        child: TextFormField(
                          controller: amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: ChatbotUi.dlgMonthlyBudgetLabel,
                          ),
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            if (n == null || n <= 0) {
                              return ChatbotUi.invalidNumber;
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: saving
                                    ? null
                                    : () => Navigator.pop(ctx),
                                child: Text(ChatbotUi.dlgCancel),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppLoadingButton(
                                isLoading: saving,
                                label: ChatbotUi.dlgSave,
                                onPressed: () async {
                                  if (!(formKey.currentState?.validate() ??
                                      false)) {
                                    return;
                                  }
                                  setLocalState(() => saving = true);
                                  final accountsResult =
                                      await _dbHelper.queryAllRows('accounts');
                                  final accountId = accountsResult.fold<int?>(
                                    (_) => null,
                                    (data) => data.isNotEmpty
                                        ? data.first['id'] as int?
                                        : null,
                                  );
                                  if (accountId == null) {
                                    setLocalState(() => saving = false);
                                    _appendMessage(
                                      ChatMessage(
                                        text: ChatbotUi.noAccountForBudget,
                                        isUser: false,
                                      ),
                                    );
                                    _scrollToBottom();
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    return;
                                  }

                                  final now = DateTime.now();
                                  final start =
                                      DateTime(now.year, now.month + 1, 1);
                                  final end =
                                      DateTime(now.year, now.month + 2, 0);
                                  await _dbHelper.insert('budgets', {
                                    'amount': double.parse(amountCtrl.text),
                                    'start_date':
                                        start.toIso8601String().split('T')[0],
                                    'end_date':
                                        end.toIso8601String().split('T')[0],
                                    'account_id': accountId,
                                  });
                                  if (!ctx.mounted) return;
                                  setLocalState(() => saving = false);
                                  Navigator.pop(ctx);
                                  _appendMessage(
                                    ChatMessage(
                                      text: ChatbotUi.budgetCreatedDialog(
                                        double.parse(amountCtrl.text)
                                            .toStringAsFixed(0),
                                      ),
                                      isUser: false,
                                    ),
                                  );
                                  _scrollToBottom();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getAllDatabaseContext() async {
    return _contextLoader.load();
  }

  String _formatJsonData(dynamic data) {
    if (data == null || (data is List && data.isEmpty)) {
      return ChatbotUi.jsonNoData;
    }
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  String _buildLocalFallbackMessage({
    required String userMessage,
    required Map<String, dynamic> contextData,
    required bool quotaExceeded,
  }) {
    final insights = ChatbotInsightsEngine.buildFinancialInsights(contextData);
    final notice = quotaExceeded
        ? ChatbotUi.localFallbackQuotaNotice
        : ChatbotUi.localFallbackOfflineNotice;
    final body = ChatbotLocalFallback.buildReply(
      userMessage: userMessage,
      contextData: contextData,
      insights: insights,
    );
    return '$notice\n\n$body';
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
    state = state.copyWith(
      messages: [ChatMessage(text: ChatbotUi.chatCleared, isUser: false)],
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}

final chatbotProvider =
    StateNotifierProvider.autoDispose<ChatbotNotifier, ChatbotState>((ref) {
  return ChatbotNotifier()..initialize();
});
