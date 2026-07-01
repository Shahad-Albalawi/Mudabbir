import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/resources/app_colors.dart' show GamificationPalette;

/// Animated circular progress ring for challenge cards.
class ChallengeProgressRing extends StatefulWidget {
  const ChallengeProgressRing({
    super.key,
    required this.percent,
    required this.color,
    this.size = 64,
    this.strokeWidth = 6,
    this.label,
  });

  final int percent;
  final Color color;
  final double size;
  final double strokeWidth;
  final String? label;

  @override
  State<ChallengeProgressRing> createState() => _ChallengeProgressRingState();
}

class _ChallengeProgressRingState extends State<ChallengeProgressRing>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 900);

  late AnimationController _controller;
  late Animation<double> _animation;
  int _displayPercent = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
    _animation.addListener(_onTick);
  }

  void _onTick() {
    final next = (widget.percent * _animation.value).round();
    if (next != _displayPercent && mounted) {
      setState(() => _displayPercent = next);
    }
  }

  @override
  void didUpdateWidget(covariant ChallengeProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _animation.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final track = isDark ? AppColors.dvDark : AppColors.dvLight;
    final value = (widget.percent.clamp(0, 100) / 100) * _animation.value;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: widget.strokeWidth,
              strokeCap: StrokeCap.round,
              backgroundColor: track,
              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_displayPercent%',
                style: AppTypography.labelMedium(widget.color).copyWith(
                  fontWeight: AppFontWeights.bold,
                  fontSize: widget.size * 0.22,
                ),
              ),
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: AppTypography.labelSmall(
                    isDark ? AppColors.t3Dark : AppColors.t3Light,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Resolves accent color from challenge progress.
Color challengeProgressColor(double progressFraction) =>
    GamificationPalette.progressColor(progressFraction.clamp(0.0, 1.0));
