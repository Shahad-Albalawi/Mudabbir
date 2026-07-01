import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';

/// Compact encouragement strip — star icon + light tinted background.
class GoalMotivationBanner extends StatelessWidget {
  const GoalMotivationBanner({
    super.key,
    required this.message,
    required this.accent,
  });

  final String message;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? context.colors.textPrimary : AppColors.navy1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.28 : 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_rounded,
              size: 18,
              color: accent,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium(textColor).copyWith(
                fontWeight: AppFontWeights.semiBold,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
