import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/riyal_amount.dart';
import 'package:mudabbir/presentation/widgets/score_ring_widget.dart';

/// Top summary — overall progress ring + total saved across goals.
class GoalsSummaryCard extends StatelessWidget {
  const GoalsSummaryCard({
    super.key,
    required this.goals,
  });

  final List<SavingsGoal> goals;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final active = goals.where((g) => !g.isCompleted).toList();
    final list = active.isEmpty ? goals : active;

    final totalSaved =
        list.fold<double>(0, (sum, g) => sum + g.currentAmount);
    final totalTarget = list.fold<double>(0, (sum, g) => sum + g.target);
    final overallPercent = totalTarget <= 0
        ? 0
        : ((totalSaved / totalTarget) * 100).clamp(0, 100).round();

    final title = AppStrings.isEnglishLocale
        ? 'Total savings'
        : 'إجمالي التوفير';
    final subtitle = AppStrings.isEnglishLocale
        ? 'of ${AppCurrency.formatNumber(totalTarget)} across ${list.length} goals'
        : 'من ${AppCurrency.formatNumber(totalTarget)} في ${list.length} أهداف';

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          ScoreRingWidget(
            score: overallPercent,
            color: colors.primary,
            size: 72,
            strokeWidth: 7,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                RiyalAmount(
                  totalSaved,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  symbolBold: true,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
