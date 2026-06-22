import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/chatbot_ui_strings.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_animated_list_item.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/presentation/widgets/ios_pressable.dart';
import 'package:mudabbir/service/haptic_service.dart';

TextDirection _chatTextDirection(BuildContext context) =>
    Directionality.of(context);

/// Starter prompts shown until the user sends their first message.
class ChatbotEmptyState extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;

  const ChatbotEmptyState({
    super.key,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final direction = _chatTextDirection(context);
    final suggestions = [
      _Suggestion(
        icon: AppIcons.wallet,
        title: ChatbotUi.suggestBalanceTitle,
        subtitle: ChatbotUi.suggestBalanceSubtitle,
        prompt: ChatbotUi.suggestBalancePrompt,
      ),
      _Suggestion(
        icon: CupertinoIcons.chart_bar,
        title: ChatbotUi.suggestExpenseTitle,
        subtitle: ChatbotUi.suggestExpenseSubtitle,
        prompt: ChatbotUi.suggestExpensePrompt,
      ),
      _Suggestion(
        icon: AppIcons.goals,
        title: ChatbotUi.suggestGoalsTitle,
        subtitle: ChatbotUi.suggestGoalsSubtitle,
        prompt: ChatbotUi.suggestGoalsPrompt,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.pageGutter,
        8,
        AppLayout.pageGutter,
        16,
      ),
      child: Column(
        children: [
          IOSEmptyState(
            icon: CupertinoIcons.sparkles,
            title: AppStrings.emptyChatTitle,
            subtitle: AppStrings.emptyChatSubtitle,
            animate: false,
            compact: true,
          ),
          const SizedBox(height: 8),
          ...suggestions.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppAnimatedListItem(
                    index: entry.key,
                    child: _SuggestionTile(
                      suggestion: entry.value,
                      textDirection: direction,
                      onTap: () {
                        HapticService.light();
                        onSuggestionTap(entry.value.prompt);
                      },
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _Suggestion {
  final IconData icon;
  final String title;
  final String subtitle;
  final String prompt;

  const _Suggestion({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.prompt,
  });
}

class _SuggestionTile extends StatelessWidget {
  final _Suggestion suggestion;
  final TextDirection textDirection;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.suggestion,
    required this.textDirection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: '${suggestion.title}. ${suggestion.subtitle}',
      child: IOSPressable(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: scheme.outline.withValues(
                alpha: scheme.brightness == Brightness.dark ? 0.38 : 0.28,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.chromeIconFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  suggestion.icon,
                  color: scheme.chromeIcon,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                      textDirection: textDirection,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      suggestion.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.textMuted,
                          ),
                      textDirection: textDirection,
                    ),
                  ],
                ),
              ),
              Icon(
                textDirection == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: scheme.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
