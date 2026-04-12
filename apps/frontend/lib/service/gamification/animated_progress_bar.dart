import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Animated progress bar with particle effects
class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final Duration duration;
  final double height;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.purple,
    this.duration = const Duration(milliseconds: 800),
    this.height = 8.0,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: _currentProgress,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _currentProgress = oldWidget.progress;
      _animation = Tween<double>(begin: _currentProgress, end: widget.progress)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) {
      return Colors.green;
    } else if (progress >= 0.75) {
      return Colors.purple;
    } else if (progress >= 0.5) {
      return Colors.orange;
    } else if (progress >= 0.25) {
      return Colors.blue;
    }
    return ColorManager.grey;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedProgress = _animation.value.clamp(0.0, 1.0);
        final progressColor = _getProgressColor(animatedProgress);

        return Stack(
          children: [
            // Background
            Container(
              width: double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                color: ColorManager.grey200,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
            ),

            // Progress fill
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: animatedProgress,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      progressColor,
                      progressColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(widget.height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: progressColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),

            // Shine effect
            if (animatedProgress > 0)
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: animatedProgress,
                child: Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Progress indicator with percentage and motivational message
class ProgressIndicatorWithMessage extends StatelessWidget {
  final double progress;
  final String goalName;

  const ProgressIndicatorWithMessage({
    super.key,
    required this.progress,
    required this.goalName,
  });

  @override
  Widget build(BuildContext context) {
    final message = AppStrings.journeyMotivation(progress);
    final scheme = Theme.of(context).colorScheme;
    final percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: progress >= 1.0 ? Colors.green : Colors.blue,
              ),
            ),
            Expanded(
              child: Text(
                message,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedProgressBar(progress: progress, height: 10),
      ],
    );
  }
}
