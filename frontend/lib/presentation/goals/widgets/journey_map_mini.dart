import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/goals/goal_milestone_utils.dart';

/// Compact horizontal journey — 4 stations with percent labels.
class JourneyMapMini extends StatelessWidget {
  const JourneyMapMini({
    super.key,
    required this.progressPercent,
    required this.color,
  });

  final double progressPercent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? AppColors.dvDark : AppColors.dvLight;
    final completed = GoalMilestoneUtils.completedMilestones(progressPercent);
    final hasCurrent = GoalMilestoneUtils.hasCurrentMilestone(progressPercent);
    final labels = GoalMilestoneUtils.milestonePercents;

    return Column(
      children: [
        SizedBox(
          height: 28,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              const nodeSize = 18.0;
              final centerY = 14.0;
              final isRtl = Directionality.of(context) == TextDirection.rtl;
              final fillWidth =
                  (completed / GoalMilestoneUtils.defaultMilestoneCount) *
                      (width - nodeSize);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: nodeSize / 2,
                    right: nodeSize / 2,
                    top: centerY - 1.5,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: trackColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (fillWidth > 0)
                    Positioned(
                      top: centerY - 1.5,
                      left: isRtl ? null : nodeSize / 2,
                      right: isRtl ? nodeSize / 2 : null,
                      width: fillWidth.clamp(0, width - nodeSize),
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  for (var i = 0; i < labels.length; i++)
                    _node(
                      context: context,
                      index: i,
                      width: width,
                      nodeSize: nodeSize,
                      centerY: centerY,
                      isRtl: isRtl,
                      isCompleted: i < completed,
                      isCurrent: hasCurrent && i == completed,
                      color: color,
                      isDark: isDark,
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Text(
                  GoalMilestoneUtils.milestonePercentLabel(i),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: i < completed ? FontWeight.w600 : FontWeight.w400,
                    color: i < completed
                        ? color
                        : (isDark ? AppColors.t3Dark : AppColors.t3Light),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _node({
    required BuildContext context,
    required int index,
    required double width,
    required double nodeSize,
    required double centerY,
    required bool isRtl,
    required bool isCompleted,
    required bool isCurrent,
    required Color color,
    required bool isDark,
  }) {
    final total = GoalMilestoneUtils.defaultMilestoneCount;
    final fraction = (index + 1) / total;
    final ltrX = (width - nodeSize) * fraction + nodeSize / 2;
    final x = isRtl ? width - ltrX : ltrX;

    final futureFill = isDark ? AppColors.s2Dark : AppColors.s2Light;
    final futureBorder = isDark ? AppColors.bdDark : AppColors.bdLight;

    Widget child;
    if (isCompleted) {
      child = Container(
        width: nodeSize,
        height: nodeSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(
          Icons.check_rounded,
          size: 11,
          color: AppColors.textInverse,
        ),
      );
    } else if (isCurrent) {
      child = Container(
        width: nodeSize,
        height: nodeSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: color, width: 2),
        ),
      );
    } else {
      child = Container(
        width: nodeSize,
        height: nodeSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: futureFill,
          border: Border.all(color: futureBorder),
        ),
      );
    }

    return Positioned(
      left: x - nodeSize / 2,
      top: centerY - nodeSize / 2,
      child: child,
    );
  }
}
