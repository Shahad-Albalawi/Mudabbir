import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/goals/goal_milestone_utils.dart';
import 'package:mudabbir/presentation/widgets/riyal_amount.dart';

/// Full journey map — gradient track, person on current node, amounts per station.
class JourneyMapFull extends StatelessWidget {
  const JourneyMapFull({
    super.key,
    required this.targetAmount,
    required this.progressPercent,
    required this.color,
    this.totalMilestones = GoalMilestoneUtils.defaultMilestoneCount,
  });

  final double targetAmount;
  final double progressPercent;
  final Color color;
  final int totalMilestones;

  @override
  Widget build(BuildContext context) {
    final completed = GoalMilestoneUtils.completedMilestones(progressPercent);
    final isCurrent = GoalMilestoneUtils.hasCurrentMilestone(progressPercent);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? AppColors.dvDark : AppColors.dvLight;
    final textPrimary = isDark ? AppColors.t1Dark : AppColors.t1Light;
    final textMuted = isDark ? AppColors.t3Dark : AppColors.t3Light;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    const nodeSize = 46.0;
    const trackY = 4.0;
    const trackHeight = 5.0;

    return SizedBox(
      height: 148,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final fillWidth =
              (completed.clamp(0, totalMilestones) / totalMilestones) *
                  (width - nodeSize);
          final trackTop = trackY + nodeSize / 2 - trackHeight / 2;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: nodeSize / 2,
                right: nodeSize / 2,
                top: trackTop,
                child: Container(
                  height: trackHeight,
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (fillWidth > 0)
                Positioned(
                  top: trackTop,
                  left: isRtl ? null : nodeSize / 2,
                  right: isRtl ? nodeSize / 2 : null,
                  width: fillWidth,
                  child: Container(
                    height: trackHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        begin: isRtl
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        end: isRtl
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        colors: [
                          color.withValues(alpha: 0.55),
                          color,
                        ],
                      ),
                    ),
                  ),
                ),
              for (var i = 0; i < totalMilestones; i++)
                _fullNodeColumn(
                  index: i,
                  width: width,
                  nodeSize: nodeSize,
                  trackY: trackY,
                  isRtl: isRtl,
                  completed: completed,
                  isCurrent: isCurrent,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _fullNodeColumn({
    required int index,
    required double width,
    required double nodeSize,
    required double trackY,
    required bool isRtl,
    required int completed,
    required bool isCurrent,
    required Color textPrimary,
    required Color textMuted,
  }) {
    final fraction = (index + 1) / totalMilestones;
    final ltrX = (width - nodeSize) * fraction;
    final left = isRtl ? width - ltrX - nodeSize : ltrX;

    final isCompleted = index < completed;
    final isCurrentNode = isCurrent && index == completed;

    return Positioned(
      left: left,
      top: trackY,
      width: nodeSize,
      child: Column(
        children: [
          _FullNodeIcon(
            isCompleted: isCompleted,
            isCurrent: isCurrentNode,
            color: color,
            size: nodeSize,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            GoalMilestoneUtils.milestonePercentLabel(index),
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall(
              isCompleted || isCurrentNode ? color : textMuted,
            ).copyWith(
              fontWeight: isCompleted || isCurrentNode
                  ? AppFontWeights.bold
                  : AppFontWeights.medium,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          RiyalAmount(
            GoalMilestoneUtils.milestoneAmount(targetAmount, index),
            fontSize: 11,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            color: isCompleted || isCurrentNode ? textPrimary : textMuted,
            fontWeight: isCompleted || isCurrentNode
                ? AppFontWeights.semiBold
                : AppFontWeights.regular,
          ),
        ],
      ),
    );
  }
}

class _FullNodeIcon extends StatelessWidget {
  const _FullNodeIcon({
    required this.isCompleted,
    required this.isCurrent,
    required this.color,
    required this.size,
  });

  final bool isCompleted;
  final bool isCurrent;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final futureFill = isDark ? AppColors.s2Dark : AppColors.s2Light;
    final futureBorder = isDark ? AppColors.bdDark : AppColors.bdLight;
    final muted = isDark ? AppColors.t3Dark : AppColors.t3Light;

    if (isCompleted) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.check_rounded,
          color: AppColors.textInverse,
          size: size * 0.46,
        ),
      );
    }

    if (isCurrent) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.person_rounded,
          color: color,
          size: size * 0.48,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: futureFill,
        shape: BoxShape.circle,
        border: Border.all(color: futureBorder, width: 1.5),
      ),
      child: Icon(
        Icons.circle_outlined,
        color: muted,
        size: size * 0.34,
      ),
    );
  }
}
