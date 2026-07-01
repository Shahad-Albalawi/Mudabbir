import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';

enum _JourneyNodeState { completed, current, future }

/// Horizontal journey track — RTL-aware fill from the right.
class JourneyMap extends StatelessWidget {
  const JourneyMap({
    super.key,
    required this.totalMilestones,
    required this.completedMilestones,
    required this.isCurrent,
    required this.color,
    this.height = 44,
    this.nodeSize = 28,
  });

  final int totalMilestones;
  final int completedMilestones;
  final bool isCurrent;
  final Color color;
  final double height;
  final double nodeSize;

  @override
  Widget build(BuildContext context) {
    if (totalMilestones <= 0) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? AppColors.dvDark : AppColors.dvLight;
    final futureFill = isDark ? AppColors.s2Dark : AppColors.s2Light;
    final futureBorder = isDark ? AppColors.bdDark : AppColors.bdLight;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final centerY = height / 2;
          final fillWidth =
              (completedMilestones.clamp(0, totalMilestones) / totalMilestones) *
                  width;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: nodeSize / 2,
                right: nodeSize / 2,
                top: centerY - 2,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (fillWidth > 0)
                Positioned(
                  top: centerY - 2,
                  left: isRtl ? null : nodeSize / 2,
                  right: isRtl ? nodeSize / 2 : null,
                  width: fillWidth.clamp(0, width - nodeSize),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              for (var i = 0; i < totalMilestones; i++)
                _positionedNode(
                  index: i,
                  width: width,
                  centerY: centerY,
                  isRtl: isRtl,
                  state: _nodeState(i),
                  futureFill: futureFill,
                  futureBorder: futureBorder,
                ),
            ],
          );
        },
      ),
    );
  }

  _JourneyNodeState _nodeState(int index) {
    if (index < completedMilestones) return _JourneyNodeState.completed;
    if (isCurrent && index == completedMilestones) {
      return _JourneyNodeState.current;
    }
    return _JourneyNodeState.future;
  }

  double _nodeCenterX(int index, double width, bool isRtl) {
    final fraction = (index + 1) / totalMilestones;
    final ltrX = (width - nodeSize) * fraction + nodeSize / 2;
    return isRtl ? width - ltrX : ltrX;
  }

  Widget _positionedNode({
    required int index,
    required double width,
    required double centerY,
    required bool isRtl,
    required _JourneyNodeState state,
    required Color futureFill,
    required Color futureBorder,
  }) {
    final x = _nodeCenterX(index, width, isRtl);

    return Positioned(
      left: x - nodeSize / 2,
      top: centerY - nodeSize / 2,
      child: _JourneyNode(
        state: state,
        color: color,
        size: nodeSize,
        futureFill: futureFill,
        futureBorder: futureBorder,
      ),
    );
  }
}

class _JourneyNode extends StatelessWidget {
  const _JourneyNode({
    required this.state,
    required this.color,
    required this.size,
    required this.futureFill,
    required this.futureBorder,
  });

  final _JourneyNodeState state;
  final Color color;
  final double size;
  final Color futureFill;
  final Color futureBorder;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _JourneyNodeState.completed:
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.28),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.check_rounded,
            color: AppColors.textInverse,
            size: size * 0.52,
          ),
        );
      case _JourneyNodeState.current:
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.star_rounded,
            color: color,
            size: size * 0.5,
          ),
        );
      case _JourneyNodeState.future:
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: futureFill,
            shape: BoxShape.circle,
            border: Border.all(color: futureBorder, width: 1.5),
          ),
        );
    }
  }
}
