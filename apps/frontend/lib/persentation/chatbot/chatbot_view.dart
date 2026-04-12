import 'package:flutter/material.dart';
import 'package:mudabbir/persentation/resources/color_manager.dart';
import 'package:mudabbir/persentation/resources/chatbot_ui_strings.dart';
import 'package:mudabbir/persentation/resources/strings_manager.dart';
import 'package:mudabbir/persentation/resources/values_manager.dart';
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
          backgroundColor: scheme.surfaceContainerHighest,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorManager.primaryWithOpacity10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.psychology,
                  size: 20,
                  color: ColorManager.primary,
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
            // Messages List
            Expanded(
              child: model.isBusy
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: ColorManager.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.loading,
                            style: TextStyle(
                              color: ColorManager.textSecondary,
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
                        return _buildMessageBubble(context, message, index);
                      },
                    ),
            ),

            // Loading Indicator for AI Response
            if (model.isLoadingResponse)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: ColorManager.shadowMedium,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ColorManager.primary,
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
                          _buildTypingDots(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Smart actions
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _actionChip(
                    title: ChatbotUi.quickCreateGoal,
                    icon: Icons.flag_rounded,
                    onTap: () => model.handleQuickAction(
                      ChatQuickAction.createGoal,
                      context,
                    ),
                  ),
                  _actionChip(
                    title: ChatbotUi.quickAdjustBudget,
                    icon: Icons.account_balance_wallet_rounded,
                    onTap: () => model.handleQuickAction(
                      ChatQuickAction.adjustBudget,
                      context,
                    ),
                  ),
                  _actionChip(
                    title: ChatbotUi.quickReduceCategory,
                    icon: Icons.trending_down_rounded,
                    onTap: () => model.handleQuickAction(
                      ChatQuickAction.reduceCategory,
                      context,
                    ),
                  ),
                  _actionChip(
                    title: ChatbotUi.quickPdf,
                    icon: Icons.picture_as_pdf_rounded,
                    onTap: () => model.handleQuickAction(
                      ChatQuickAction.exportReport,
                      context,
                    ),
                  ),
                  if (model.canUndoLastAction)
                    _actionChip(
                      title: ChatbotUi.quickUndo,
                      icon: Icons.undo_rounded,
                      onTap: () => model.undoLastAction(),
                    ),
                ],
              ),
            ),

            // Input Field
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.shadowMedium,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
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
                        ),
                        child: TextField(
                          controller: model.messageController,
                          maxLines: null,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: AppStrings.chatHint,
                            hintTextDirection: TextDirection.rtl,
                            hintStyle: TextStyle(
                              color: scheme.onSurfaceVariant,
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
                            color: ColorManager.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: ColorManager.white,
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

  Widget _actionChip({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: ColorManager.primary),
        label: Text(title),
        onPressed: onTap,
        backgroundColor: ColorManager.primaryWithOpacity08,
        labelStyle: const TextStyle(
          color: ColorManager.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: ColorManager.primary.withValues(alpha: 0.25)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: ColorManager.primaryWithOpacity08,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_rounded,
                size: 80,
                color: ColorManager.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.emptyChatTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorManager.textPrimary,
              ),
              textDirection: _chatTextDirection,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.emptyChatSubtitle,
              style: TextStyle(
                fontSize: 16,
                color: ColorManager.textSecondary,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorManager.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: ColorManager.primary, size: 24),
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textDirection: _chatTextDirection,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            color: ColorManager.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessage message,
    int index,
  ) {
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
                color: ColorManager.primaryWithOpacity12,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_rounded,
                color: ColorManager.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? ColorManager.primary
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 8),
                    bottomRight: Radius.circular(isUser ? 8 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isUser
                          ? ColorManager.primary.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  textDirection: _chatTextDirection,
                  style: TextStyle(
                    color: isUser
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorManager.lightGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                color: ColorManager.darkGrey,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingDots() {
    return Row(
      children: List.generate(3, (index) {
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (index * 100)),
          builder: (context, double value, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: ColorManager.grey.withValues(alpha: value),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  void _showClearDialog(BuildContext context, ChatbotViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          ChatbotUi.clearDialogTitle,
          textDirection: _chatTextDirection,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          ChatbotUi.clearDialogBody,
          textDirection: _chatTextDirection,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              ChatbotUi.dlgCancel,
              style: TextStyle(color: ColorManager.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              model.clearMessages();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              ChatbotUi.clearDialogConfirm,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
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
