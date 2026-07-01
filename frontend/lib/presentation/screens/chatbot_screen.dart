import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/chatbot/chat_notifier.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/chatbot/chatbot_copy_helpers.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/ios_dialog_style.dart';
import 'package:mudabbir/service/chatbot/chatbot_models.dart';
import 'package:mudabbir/service/haptic_service.dart';

TextDirection get _chatDirection =>
    AppStrings.isEnglishLocale ? TextDirection.ltr : TextDirection.rtl;

const _bubbleRadius = AppRadius.lg;
const _bubbleTail = AppSpacing.xs;

/// Premium AI coach chat — bubbles, 2×2 suggestions, typing indicator.
class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key, this.embedded = false});

  /// When true, omits back navigation (used inside [AiChatSheet]).
  final bool embedded;

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  @override
  Widget build(BuildContext context) {
    ref.listen<ChatScreenState>(chatNotifierProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.messages.lastOrNull?.text !=
              next.messages.lastOrNull?.text ||
          previous?.isStreaming != next.isStreaming) {
        ref.read(chatNotifierProvider.notifier).scrollToBottom();
      }
    });

    final state = ref.watch(chatNotifierProvider);
    final notifier = ref.read(chatNotifierProvider.notifier);
    final colors = context.colors;
    final pageBg = colors.background;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: pageBg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: pageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: widget.embedded
            ? null
            : (context.canPop()
                ? IconButton(
                    icon: Icon(
                      CupertinoIcons.back,
                      color: colors.textPrimary,
                    ),
                    onPressed: () => context.pop(),
                  )
                : null),
        automaticallyImplyLeading: !widget.embedded,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ChatbotUi.screenTitle,
              style: AppTypography.titleMedium(
                colors.textPrimary,
              ).copyWith(fontWeight: AppFontWeights.bold),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Text('✨', style: TextStyle(fontSize: 16)),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: AppStrings.clearChat,
            icon: Icon(
              CupertinoIcons.trash,
              color: colors.textSecondary,
            ),
            onPressed: () => _confirmClear(context, notifier),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? Center(
                    child: CircularProgressIndicator(color: colors.primary),
                  )
                : _MessageList(
                    state: state,
                    scrollController: notifier.scrollController,
                    onSuggestionTap: (text) {
                      HapticService.light();
                      notifier.sendSuggestedMessage(text);
                    },
                  ),
          ),
          _ChatInputBar(
            controller: notifier.messageController,
            enabled: !state.isStreaming,
            isDark: isDark,
            onSend: () {
              HapticService.light();
              notifier.sendMessage();
            },
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, ChatNotifier notifier) {
    IOSDialogStyle.showConfirm(
      context: context,
      title: ChatbotUi.clearChatTitle,
      message: ChatbotUi.clearChatMessage,
      confirmLabel: ChatbotUi.clearChatConfirm,
      cancelLabel: AppStrings.txCancel,
      isDestructive: true,
      onConfirm: notifier.clearMessages,
    );
  }
}

List<({IconData icon, String title, String prompt})> _buildSuggestionCards() {
  return [
    (
      icon: Icons.account_balance_wallet_outlined,
      title: ChatbotUi.suggestBalanceTitle,
      prompt: ChatbotUi.suggestBalancePrompt,
    ),
    (
      icon: Icons.pie_chart_outline_rounded,
      title: ChatbotUi.suggestExpenseTitle,
      prompt: ChatbotUi.suggestExpensePrompt,
    ),
    (
      icon: Icons.flag_outlined,
      title: ChatbotUi.suggestGoalsTitle,
      prompt: ChatbotUi.suggestGoalsPrompt,
    ),
    (
      icon: Icons.savings_outlined,
      title: ChatbotUi.suggestSavingsTitle,
      prompt: ChatbotUi.suggestSavingsPrompt,
    ),
  ];
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.state,
    required this.scrollController,
    required this.onSuggestionTap,
  });

  final ChatScreenState state;
  final ScrollController scrollController;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final showEmptySuggestions =
        state.messages.isEmpty && !state.isStreaming && state.showSuggestions;

    if (state.messages.isEmpty && !state.isStreaming && !showEmptySuggestions) {
      return const SizedBox.shrink();
    }

    final items = <Widget>[];

    if (showEmptySuggestions) {
      items.add(
        _SuggestedQuestionsGrid(
          cards: _buildSuggestionCards(),
          onTap: onSuggestionTap,
        ),
      );
    }

    for (var i = 0; i < state.messages.length; i++) {
      final message = state.messages[i];
      final isLast = i == state.messages.length - 1;
      final showTyping = state.isStreaming &&
          isLast &&
          !message.isUser &&
          message.text.trim().isEmpty;

      if (showTyping) {
        items.add(const _TypingBubble());
      } else if (message.text.trim().isNotEmpty || message.isUser) {
        items.add(_MessageBubble(message: message));
      }
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.pageGutter,
        vertical: AppSpacing.md,
      ),
      children: items,
    );
  }
}

class _SuggestedQuestionsGrid extends StatelessWidget {
  const _SuggestedQuestionsGrid({
    required this.cards,
    required this.onTap,
  });

  final List<({IconData icon, String title, String prompt})> cards;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.navy;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ChatbotUi.assistantHeadline,
            textAlign: TextAlign.center,
            style: AppTypography.headlineSmall(titleColor).copyWith(
              fontWeight: AppFontWeights.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            ChatbotUi.assistantSubtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall(subtitleColor).copyWith(height: 1.4),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            ChatbotUi.suggestedQuestionsTitle,
            style: AppTypography.labelLarge(subtitleColor).copyWith(
              fontWeight: AppFontWeights.medium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm + 2,
            crossAxisSpacing: AppSpacing.sm + 2,
            childAspectRatio: 1.35,
            children: cards
                .map(
                  (card) => _SuggestionCard(
                    icon: card.icon,
                    title: card.title,
                    onTap: () => onTap(card.prompt),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.gray900;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.sm + 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfDark : AppColors.surfLight,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            boxShadow: AppShadows.sm(isDark: isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 20, color: AppColors.navy),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelLarge(textColor).copyWith(
                  fontWeight: AppFontWeights.medium,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeLabel = DateFormat('h:mm a', 'ar').format(message.timestamp);

    final bubbleColor = isUser
        ? AppColors.navy
        : (isDark ? AppColors.surfDark : AppColors.gray100);
    final textColor = isUser
        ? AppColors.onPrimary
        : (isDark ? AppColors.textPrimaryDark : AppColors.gray900);

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(_bubbleRadius),
      topRight: const Radius.circular(_bubbleRadius),
      bottomLeft: Radius.circular(isUser ? _bubbleRadius : _bubbleTail),
      bottomRight: Radius.circular(isUser ? _bubbleTail : _bubbleRadius),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 6),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          child: Column(
            crossAxisAlignment: isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 6,
                  vertical: AppSpacing.sm + 2,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: radius,
                  boxShadow: isUser
                      ? [
                          BoxShadow(
                            color: AppColors.navy.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  message.text,
                  textDirection: _chatDirection,
                  style: AppTypography.bodyMedium(textColor).copyWith(
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                timeLabel,
                style: AppTypography.caption(AppColors.gray400).copyWith(
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 6,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfDark : AppColors.gray100,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(_bubbleRadius),
              topRight: Radius.circular(_bubbleRadius),
              bottomLeft: Radius.circular(_bubbleTail),
              bottomRight: Radius.circular(_bubbleRadius),
            ),
          ),
          child: const _TypingDots(),
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });
    _animations = _controllers
        .map(
          (controller) => Tween<double>(begin: 0.35, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();

    for (var i = 0; i < _controllers.length; i++) {
      Future<void>.delayed(Duration(milliseconds: i * 150), () {
        if (!mounted) return;
        _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Opacity(
              opacity: _animations[index].value,
              child: Transform.translate(
                offset: Offset(0, -3 * (1 - _animations[index].value)),
                child: child,
              ),
            );
          },
          child: Container(
            width: 7,
            height: 7,
            margin: EdgeInsets.only(left: index == 0 ? 0 : 5),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.enabled,
    required this.isDark,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool isDark;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final fieldFill = isDark ? AppColors.bgDark : AppColors.gray100;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.gray900;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfDark : AppColors.surfLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        boxShadow: AppShadows.sm(isDark: isDark),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm + 4,
            AppSpacing.sm + 2,
            AppSpacing.sm + 4,
            AppSpacing.sm + 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  maxLines: 4,
                  minLines: 1,
                  textDirection: _chatDirection,
                  style: AppTypography.bodyMedium(textColor),
                  decoration: InputDecoration(
                    hintText: ChatbotUi.inputHint,
                    hintTextDirection: _chatDirection,
                    hintStyle: AppTypography.bodyMedium(AppColors.gray400),
                    filled: true,
                    fillColor: fieldFill,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 4,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: BorderSide(
                        color: AppColors.navy.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  onSubmitted: (_) {
                    if (enabled) onSend();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Semantics(
                button: true,
                label: AppStrings.sendMessage,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: enabled ? onSend : null,
                    customBorder: const CircleBorder(),
                    child: Ink(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: enabled
                            ? AppColors.navy
                            : AppColors.navy.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                        boxShadow: enabled ? AppShadows.sm() : null,
                      ),
                      child: const Icon(
                        CupertinoIcons.arrow_up,
                        color: AppColors.onPrimary,
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
    );
  }
}
