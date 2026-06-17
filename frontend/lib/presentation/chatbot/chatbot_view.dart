import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/chatbot_ui_strings.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/resources/values_manager.dart';
import 'package:mudabbir/presentation/widgets/ios_dialog_style.dart';
import 'package:stacked/stacked.dart';
import 'chatbot_viewmodel.dart';

TextDirection get _chatTextDirection =>
    AppStrings.isEnglishLocale ? TextDirection.ltr : TextDirection.rtl;

class ChatbotView extends StatelessWidget {
  const ChatbotView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ViewModelBuilder<ChatbotViewModel>.reactive(
      viewModelBuilder: () => ChatbotViewModel(),
      onViewModelReady: (model) => model.initialize(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: scheme.surfaceContainerHighest,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: scheme.surfaceContainerHighest,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.psychology_outlined,
                  size: 20,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.chatbotTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            if (model.messages.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => _showClearDialog(context, model),
                tooltip: AppStrings.clearChat,
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: model.isBusy
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: scheme.primary),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.loading,
                            style: TextStyle(
                              color: scheme.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : model.messages.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      controller: model.scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.p16,
                        vertical: AppPadding.p20,
                      ),
                      itemCount: model.messages.length,
                      itemBuilder: (context, index) {
                        final message = model.messages[index];
                        return _buildMessageBubble(context, message);
                      },
                    ),
            ),
            if (model.isLoadingResponse)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: scheme.outline.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppStrings.typing,
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildTypingDots(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _actionChip(
                    context,
                    title: ChatbotUi.quickCreateGoal,
                    icon: Icons.flag_rounded,
                    onTap: () => model.handleQuickAction(
                      ChatQuickAction.createGoal,
                      context,
                    ),
                  ),
                  _actionChip(
                    context,
                    title: ChatbotUi.quickAdjustBudget,
                    icon: Icons.account_balance_wallet_rounded,
                    onTap: () => model.handleQuickAction(
                      ChatQuickAction.adjustBudget,
                      context,
                    ),
                  ),
                  _actionChip(
                    context,
                    title: ChatbotUi.quickReduceCategory,
                    icon: Icons.trending_down_rounded,
                    onTap: () => model.handleQuickAction(
                      ChatQuickAction.reduceCategory,
                      context,
                    ),
                  ),
                  _actionChip(
                    context,
                    title: ChatbotUi.quickPdf,
                    icon: Icons.picture_as_pdf_rounded,
                    onTap: () => model.handleQuickAction(
                      ChatQuickAction.exportReport,
                      context,
                    ),
                  ),
                  if (model.canUndoLastAction)
                    _actionChip(
                      context,
                      title: ChatbotUi.quickUndo,
                      icon: Icons.undo_rounded,
                      onTap: () => model.undoLastAction(),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppLayout.pageGutter),
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(
                  top: BorderSide(
                    color: scheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: scheme.outline.withValues(alpha: 0.25),
                          ),
                        ),
                        child: TextField(
                          controller: model.messageController,
                          maxLines: null,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 15,
                            color: scheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: AppStrings.chatHint,
                            hintTextDirection: TextDirection.rtl,
                            hintStyle: TextStyle(
                              color: scheme.textMuted,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              model.sendMessage();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: model.isLoadingResponse
                            ? null
                            : () => model.sendMessage(),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.send_rounded,
                            color: scheme.onPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: scheme.primary),
        label: Text(title),
        onPressed: onTap,
        backgroundColor: scheme.primary.withValues(alpha: 0.1),
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_rounded,
                size: 80,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.emptyChatTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
              textDirection: _chatTextDirection,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.emptyChatSubtitle,
              style: TextStyle(
                fontSize: 16,
                color: scheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
              textDirection: _chatTextDirection,
            ),
            const SizedBox(height: 32),
            _buildSuggestionCard(
              context: context,
              icon: Icons.account_balance_wallet_rounded,
              title: ChatbotUi.suggestBalanceTitle,
              subtitle: ChatbotUi.suggestBalanceSubtitle,
            ),
            const SizedBox(height: 12),
            _buildSuggestionCard(
              context: context,
              icon: Icons.trending_up_rounded,
              title: ChatbotUi.suggestExpenseTitle,
              subtitle: ChatbotUi.suggestExpenseSubtitle,
            ),
            const SizedBox(height: 12),
            _buildSuggestionCard(
              context: context,
              icon: Icons.flag_rounded,
              title: ChatbotUi.suggestGoalsTitle,
              subtitle: ChatbotUi.suggestGoalsSubtitle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: scheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                  textDirection: _chatTextDirection,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.textMuted,
                  ),
                  textDirection: _chatTextDirection,
                ),
              ],
            ),
          ),
          Icon(
            AppStrings.isEnglishLocale
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_rounded,
            size: 16,
            color: scheme.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_rounded,
                color: scheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? scheme.primary : scheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 8),
                  bottomRight: Radius.circular(isUser ? 8 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: scheme.outline.withValues(alpha: 0.3),
                      ),
              ),
              child: Text(
                message.text,
                textDirection: _chatTextDirection,
                style: TextStyle(
                  color: isUser ? scheme.onPrimary : scheme.onSurface,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: scheme.outline.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                color: scheme.textMuted,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingDots(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: scheme.textMuted.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  void _showClearDialog(BuildContext context, ChatbotViewModel model) {
    IOSDialogStyle.showConfirm(
      context: context,
      title: ChatbotUi.clearDialogTitle,
      message: ChatbotUi.clearDialogBody,
      confirmLabel: ChatbotUi.clearDialogConfirm,
      cancelLabel: ChatbotUi.dlgCancel,
      isDestructive: true,
      onConfirm: model.clearMessages,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}
