import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/presentation/goals/goal_theme.dart';
import 'package:mudabbir/presentation/goals/widgets/journey_map_mini.dart';
import 'package:mudabbir/presentation/goals/goal_copy_helpers.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/riyal_amount.dart';

/// Goal list card — colored accent, journey mini, progress, actions.
class GoalListCard extends StatelessWidget {
  const GoalListCard({
    super.key,
    required this.goal,
    required this.onContribute,
    required this.onDetails,
  });

  final SavingsGoal goal;
  final VoidCallback onContribute;
  final VoidCallback onDetails;

  Color _statusColor(GoalTrackStatus status) {
    switch (status) {
      case GoalTrackStatus.onTrack:
        return AppColors.green;
      case GoalTrackStatus.behind:
        return AppColors.gold;
      case GoalTrackStatus.overdue:
        return AppColors.red;
      case GoalTrackStatus.completed:
        return AppColors.navy1;
      case GoalTrackStatus.noData:
        return AppColors.gray400;
    }
  }

  String _daysLabel(SavingsGoal goal) {
    final days = goal.eta.daysToDeadline;
    if (goal.isCompleted) {
      return AppStrings.goalStatusCompleted;
    }
    if (days <= 0) {
      return AppStrings.goalDeadlinePassed;
    }
    return AppStrings.goalDaysLeft(days);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final theme = GoalTheme.forGoal(goal);
    final progress = goal.progressPercent / 100;
    final statusColor = _statusColor(goal.eta.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.border, width: 0.5),
        boxShadow: AppShadows.sm(),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 4, color: theme.color),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        theme.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _daysLabel(goal),
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        GoalCopyHelpers.statusLabel(goal.eta.status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                JourneyMapMini(
                  progressPercent: goal.progressPercent,
                  color: theme.color,
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 7,
                    backgroundColor: theme.color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.color),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          RiyalAmount(
                            goal.currentAmount,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            symbolBold: true,
                            color: theme.color,
                          ),
                          Text(
                            ' ${AppStrings.goalOfPrefix} ',
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                          RiyalAmount(
                            goal.target,
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${AppStrings.goalLeftLabel} ',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    RiyalAmount(
                      goal.remainingAmount,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: goal.isCompleted ? null : onContribute,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          AppStrings.goalContributeButtonShort,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.color,
                          side: BorderSide(color: theme.color.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: onDetails,
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.color,
                          foregroundColor: AppColors.textInverse,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          AppStrings.goalDetailsButton,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
