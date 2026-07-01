import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';

/// Semi-circular health score gauge (180° → 0°) with animated fill.
class HealthGauge extends StatefulWidget {
  const HealthGauge({super.key, required this.score});

  final int score;

  @override
  State<HealthGauge> createState() => _HealthGaugeState();
}

class _HealthGaugeState extends State<HealthGauge>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1500);

  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant HealthGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? AppColors.dvDark : AppColors.dvLight;
    final scoreColor = isDark ? AppColors.t1Dark : AppColors.navy1;

    return AnimatedBuilder(
      animation: _curve,
      builder: (context, _) {
        final progress =
            (widget.score.clamp(0, 100) / 100.0) * _curve.value;
        final displayScore =
            (widget.score * _curve.value).round().clamp(0, 100);

        return SizedBox(
          height: 148,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CustomPaint(
                size: const Size(228, 118),
                painter: _HealthGaugePainter(
                  progress: progress,
                  trackColor: trackColor,
                  fillColor: AppColors.navy1,
                  strokeWidth: 14,
                ),
              ),
              Positioned(
                bottom: 6,
                child: Text(
                  '$displayScore',
                  style: AppTypography.displayMedium(scoreColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HealthGaugePainter extends CustomPainter {
  const _HealthGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Arc from 180° (left) to 0° (right) through the bottom.
    canvas.drawArc(rect, math.pi, math.pi, false, trackPaint);

    if (progress > 0) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, math.pi, math.pi * progress, false, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HealthGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
