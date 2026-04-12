import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mudabbir/persentation/resources/color_manager.dart';
import 'package:mudabbir/persentation/resources/strings_manager.dart';

/// Journey-style progress map with animated character traveling toward goal
class JourneyProgressMap extends StatefulWidget {
  final double progress;
  final String goalName;
  final Color primaryColor;
  final Color secondaryColor;
  final Duration animationDuration;

  const JourneyProgressMap({
    super.key,
    required this.progress,
    required this.goalName,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.purple,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<JourneyProgressMap> createState() => _JourneyProgressMapState();
}

class _JourneyProgressMapState extends State<JourneyProgressMap>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _bounceController;
  late Animation<double> _progressAnimation;
  late Animation<double> _bounceAnimation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // Progress animation controller
    _progressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Bounce animation for character
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: widget.progress)
        .animate(
          CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
        );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _progressController.forward();
  }

  @override
  void didUpdateWidget(JourneyProgressMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = oldWidget.progress;
      _progressAnimation =
          Tween<double>(begin: _previousProgress, end: widget.progress).animate(
            CurvedAnimation(
              parent: _progressController,
              curve: Curves.easeInOut,
            ),
          );
      _progressController.forward(from: 0.0);

      // Trigger bounce animation
      _bounceController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _bounceController.dispose();
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

  String _getMotivationalMessage(double progress) {
    return AppStrings.journeyMotivation(progress);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _bounceAnimation]),
      builder: (context, child) {
        final animatedProgress = _progressAnimation.value.clamp(0.0, 1.0);
        final progressColor = _getProgressColor(animatedProgress);
        final message = _getMotivationalMessage(animatedProgress);
        final percentage = (animatedProgress * 100).toInt();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress percentage and message
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    message,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorManager.grey700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Journey Map
            SizedBox(
              height: 120,
              child: CustomPaint(
                painter: JourneyPathPainter(
                  progress: animatedProgress,
                  progressColor: progressColor,
                  bounceValue: _bounceAnimation.value,
                ),
                child: Container(),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom painter for the journey path
class JourneyPathPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final double bounceValue;

  JourneyPathPainter({
    required this.progress,
    required this.progressColor,
    required this.bounceValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = ColorManager.grey300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final progressPathPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Define the journey path (curved path from left to right)
    final path = Path();
    final startX = 20.0;
    final endX = size.width - 20.0;
    final midY = size.height / 2;

    // Create a winding path with curves
    path.moveTo(startX, midY + 20);

    // First curve (25% mark)
    final point25X = startX + (endX - startX) * 0.25;
    path.quadraticBezierTo(point25X - 30, midY - 30, point25X, midY - 20);

    // Second curve (50% mark)
    final point50X = startX + (endX - startX) * 0.5;
    path.quadraticBezierTo(point50X - 20, midY + 30, point50X, midY + 10);

    // Third curve (75% mark)
    final point75X = startX + (endX - startX) * 0.75;
    path.quadraticBezierTo(point75X - 20, midY - 30, point75X, midY - 10);

    // Final stretch to goal (100%)
    path.quadraticBezierTo(endX - 20, midY + 20, endX, midY);

    // Draw the full path (background)
    canvas.drawPath(path, pathPaint);

    // Draw the progress path (colored)
    final pathMetrics = path.computeMetrics().first;
    final progressPath = pathMetrics.extractPath(
      0.0,
      pathMetrics.length * progress,
    );
    canvas.drawPath(progressPath, progressPathPaint);

    // Draw milestone markers
    _drawMilestone(canvas, size, 0.0, Icons.flag, ColorManager.grey600, false);
    _drawMilestone(
      canvas,
      size,
      0.25,
      Icons.location_on,
      Colors.blue,
      progress >= 0.25,
    );
    _drawMilestone(
      canvas,
      size,
      0.5,
      Icons.star,
      Colors.orange,
      progress >= 0.5,
    );
    _drawMilestone(
      canvas,
      size,
      0.75,
      Icons.bolt,
      Colors.purple,
      progress >= 0.75,
    );
    _drawMilestone(
      canvas,
      size,
      1.0,
      Icons.emoji_events,
      Colors.green,
      progress >= 1.0,
    );

    // Draw the animated traveler (character)
    if (progress > 0) {
      final travelerPathMetrics = path.computeMetrics().first;
      final travelerDistance = travelerPathMetrics.length * progress;
      final tangent = travelerPathMetrics.getTangentForOffset(travelerDistance);

      if (tangent != null) {
        final travelerPosition = tangent.position;

        // Add bounce effect
        final bounceOffset = sin(bounceValue * pi) * 8;

        _drawTraveler(
          canvas,
          Offset(travelerPosition.dx, travelerPosition.dy - bounceOffset),
          progressColor,
        );
      }
    }
  }

  void _drawMilestone(
    Canvas canvas,
    Size size,
    double position,
    IconData icon,
    Color color,
    bool isAchieved,
  ) {
    final startX = 20.0;
    final endX = size.width - 20.0;
    final midY = size.height / 2;

    // Calculate approximate Y position based on the path curve
    double yOffset = 0;
    if (position == 0.0) {
      yOffset = 20;
    } else if (position == 0.25) {
      yOffset = -20;
    } else if (position == 0.5) {
      yOffset = 10;
    } else if (position == 0.75) {
      yOffset = -10;
    } else if (position == 1.0) {
      yOffset = 0;
    }

    final x = startX + (endX - startX) * position;
    final y = midY + yOffset;

    // Draw glow effect for achieved milestones
    if (isAchieved) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(x, y), 18, glowPaint);
    }

    // Draw milestone circle
    final circlePaint = Paint()
      ..color = isAchieved ? color : ColorManager.grey300
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), 16, circlePaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(x, y), 16, borderPaint);

    // Draw icon
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 20,
          fontFamily: icon.fontFamily,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  void _drawTraveler(Canvas canvas, Offset position, Color color) {
    // Draw traveler shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(Offset(position.dx, position.dy + 22), 12, shadowPaint);

    // Draw traveler glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(position, 20, glowPaint);

    // Draw traveler body (circle)
    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 18, bodyPaint);

    // Draw traveler border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(position, 18, borderPaint);

    // Draw traveler icon (person walking)
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.directions_walk.codePoint),
        style: TextStyle(
          fontSize: 24,
          fontFamily: Icons.directions_walk.fontFamily,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        position.dx - iconPainter.width / 2,
        position.dy - iconPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(JourneyPathPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.bounceValue != bounceValue;
  }
}
