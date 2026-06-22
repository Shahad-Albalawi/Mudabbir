import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/presentation/chatbot/chatbot_viewmodel.dart';
import 'package:mudabbir/presentation/chatbot/widgets/chatbot_empty_state.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/chatbot_ui_strings.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/resources/values_manager.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/widgets/ios_dialog_style.dart';
TextDirection get _chatTextDirection =>
    AppStrings.isEnglishLocale ? TextDirection.ltr : TextDirection.rtl;

class ChatbotView extends ConsumerWidget {
  const ChatbotView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatbotProvider);
    final notifier = ref.read(chatbotProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    final hasUserMessages = state.messages.any((m) => m.isUser);

    return AppGroupedScaffold(
      onBackPressed: () => context.pop(),
      largeTitle: true,
      title: Text(AppStrings.chatbotTitle),
      centerTitle: true,
      actions: [
        if (state.messages.isNotEmpty)
          IconButton(
            icon: const Icon(CupertinoIcons.refresh),
            onPressed: () => _showClearDialog(context, notifier),
            tooltip: AppStrings.clearChat,
          ),
        const SizedBox(width: 8),
      ],
      body: Column(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(color: scheme.pageBackground),
              child: state.isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: scheme.chromeIcon),
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
                : ListView.builder(
                    controller: notifier.scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p16,
                      vertical: AppPadding.p20,
                    ),
                    itemCount: state.messages.length +
                        (hasUserMessages ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (!hasUserMessages && index == state.messages.length) {
                        return ChatbotEmptyState(
                          onSuggestionTap: notifier.sendSuggestedMessage,
                        );
                      }
                      return _buildMessageBubble(
                        context,
                        state.messages[index],
                      );
                    },
                  ),
            ),
          ),
          if (state.isLoadingResponse)
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
                            color: scheme.chromeIcon,
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
                  icon: AppIcons.goals,
                  onTap: () => notifier.handleQuickAction(
                    ChatQuickAction.createGoal,
                    context,
                  ),
                ),
                _actionChip(
                  context,
                  title: ChatbotUi.quickAdjustBudget,
                  icon: AppIcons.wallet,
                  onTap: () => notifier.handleQuickAction(
                    ChatQuickAction.adjustBudget,
                    context,
                  ),
                ),
                _actionChip(
                  context,
                  title: ChatbotUi.quickReduceCategory,
                  icon: CupertinoIcons.arrow_down_right,
                  onTap: () => notifier.handleQuickAction(
                    ChatQuickAction.reduceCategory,
                    context,
                  ),
                ),
                _actionChip(
                  context,
                  title: ChatbotUi.quickPdf,
                  icon: CupertinoIcons.doc_text,
                  onTap: () => notifier.handleQuickAction(
                    ChatQuickAction.exportReport,
                    context,
                  ),
                ),
                if (notifier.canUndoLastAction)
                  _actionChip(
                    context,
                    title: ChatbotUi.quickUndo,
                    icon: CupertinoIcons.arrow_uturn_left,
                    onTap: () => notifier.undoLastAction(),
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
                        controller: notifier.messageController,
                        maxLines: null,
                        textDirection: _chatTextDirection,
                        style: TextStyle(
                          fontSize: 15,
                          color: scheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: AppStrings.chatHint,
                          hintTextDirection: _chatTextDirection,
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
                            notifier.sendMessage();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Semantics(
                    label: AppStrings.sendMessage,
                    button: true,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: state.isLoadingResponse
                            ? null
                            : () => notifier.sendMessage(),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.paperplane_fill,
                            color: scheme.onPrimary,
                            size: 20,
                          ),
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
        avatar: Icon(icon, size: 16, color: scheme.chromeIcon),
        label: Text(title),
        onPressed: onTap,
        backgroundColor: scheme.groupedFill,
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Semantics(
        container: true,
        label: isUser
            ? '${AppStrings.chatUserMessage}: ${message.text}'
            : '${AppStrings.chatAssistantMessage}: ${message.text}',
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
                color: scheme.chromeIconFill,
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.sparkles,
                color: scheme.chromeIcon,
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
                CupertinoIcons.person_fill,
                color: scheme.textMuted,
                size: 20,
              ),
            ),
          ],
        ],
        ),
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

  void _showClearDialog(BuildContext context, ChatbotNotifier notifier) {
    IOSDialogStyle.showConfirm(
      context: context,
      title: ChatbotUi.clearDialogTitle,
      message: ChatbotUi.clearDialogBody,
      confirmLabel: ChatbotUi.clearDialogConfirm,
      cancelLabel: ChatbotUi.dlgCancel,
      isDestructive: true,
      onConfirm: notifier.clearMessages,
    );
  }
}
