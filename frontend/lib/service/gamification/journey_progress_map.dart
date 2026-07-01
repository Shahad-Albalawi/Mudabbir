import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_colors.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/gamification/celebration_service.dart';

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
    this.primaryColor = GamificationPalette.blue,
    this.secondaryColor = GamificationPalette.purple,
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
  double _lastNotifiedProgress = 0.0;

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
    _lastNotifiedProgress = widget.progress;
  }

  void _notifyMilestoneIfNeeded(double from, double to) {
    if (to <= from) return;

    final milestone = CelebrationService.detectMilestone(
      from * 100,
      to * 100,
      100,
    );
    if (milestone == null) return;
    if (milestone == MilestoneType.completed) return;
    if (to <= _lastNotifiedProgress) return;

    _lastNotifiedProgress = to;
    CelebrationService.showMilestoneSnackbar(milestone, widget.goalName);
  }

  @override
  void didUpdateWidget(JourneyProgressMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = oldWidget.progress;
      _notifyMilestoneIfNeeded(_previousProgress, widget.progress);
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

  Color _getProgressColor(double progress) => GamificationPalette.progressColor(progress);

  String _getMotivationalMessage(double progress) {
    return AppStrings.journeyMotivation(progress);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _bounceAnimation]),
      builder: (context, child) {
        final scheme = Theme.of(context).colorScheme;
        final animatedProgress = _progressAnimation.value.clamp(0.0, 1.0);
        final progressColor = _getProgressColor(animatedProgress);
        final message = _getMotivationalMessage(animatedProgress);
        final percentage = (animatedProgress * 100).toInt();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                children: [
                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.textOnCard,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: CustomPaint(
                painter: JourneyPathPainter(
                  progress: animatedProgress,
                  progressColor: progressColor,
                  primaryColor: scheme.primary,
                  bounceValue: _bounceAnimation.value,
                  trackColor: scheme.brightness == Brightness.dark
                      ? const Color(0xFF475569)
                      : const Color(0xFFCBD5E1),
                  milestoneColors: GamificationPalette.milestones,
                  upcomingFill: scheme.groupedFill,
                  upcomingIcon: scheme.textTertiary,
                  upcomingBorder: scheme.outline.withValues(alpha: 0.45),
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
  final Color primaryColor;
  final double bounceValue;
  final Color trackColor;
  final List<Color> milestoneColors;
  final Color upcomingFill;
  final Color upcomingIcon;
  final Color upcomingBorder;

  JourneyPathPainter({
    required this.progress,
    required this.progressColor,
    required this.primaryColor,
    required this.bounceValue,
    required this.trackColor,
    required this.milestoneColors,
    required this.upcomingFill,
    required this.upcomingIcon,
    required this.upcomingBorder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = trackColor
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

    // Draw colored segments — each leg uses its milestone palette color
    _drawSegmentedProgress(canvas, path, progress);

    const milestoneStops = [0.0, 0.25, 0.5, 0.75, 1.0];
    const milestoneIcons = [
      Icons.flag,
      Icons.location_on,
      Icons.star,
      Icons.bolt,
      Icons.emoji_events,
    ];

    for (var i = 0; i < milestoneStops.length; i++) {
      _drawMilestone(
        canvas,
        size,
        milestoneStops[i],
        milestoneIcons[i],
        milestoneColors[i % milestoneColors.length],
        _milestoneState(milestoneStops[i], progress),
      );
    }

    // Draw the animated traveler (character)
    if (progress > 0) {
      final travelerPathMetrics = path.computeMetrics().first;
      final travelerDistance = travelerPathMetrics.length * progress;
      final tangent = travelerPathMetrics.getTangentForOffset(travelerDistance);

      if (tangent != null) {
        final travelerPosition = tangent.position;
        final bounceOffset = sin(bounceValue * pi) * 8;
        final travelerColor = _travelerColor(progress);

        _drawTraveler(
          canvas,
          Offset(travelerPosition.dx, travelerPosition.dy - bounceOffset),
          travelerColor,
        );
      }
    }
  }

  /// Achieved = passed; current = en route to this stop; upcoming = not yet.
  _MilestoneState _milestoneState(double position, double progress) {
    if (position == 0.0) {
      return progress > 0 ? _MilestoneState.achieved : _MilestoneState.upcoming;
    }
    if (progress >= position) return _MilestoneState.achieved;

    const stops = [0.0, 0.25, 0.5, 0.75, 1.0];
    final idx = stops.indexOf(position);
    if (idx > 0 && progress > stops[idx - 1] && progress < position) {
      return _MilestoneState.current;
    }
    return _MilestoneState.upcoming;
  }

  Color _travelerColor(double progress) {
    if (progress >= 1.0) return milestoneColors[4 % milestoneColors.length];
    if (progress >= 0.75) return milestoneColors[4 % milestoneColors.length];
    if (progress >= 0.5) return milestoneColors[3 % milestoneColors.length];
    if (progress >= 0.25) return milestoneColors[2 % milestoneColors.length];
    if (progress > 0) return milestoneColors[1 % milestoneColors.length];
    return milestoneColors[0];
  }

  void _drawSegmentedProgress(Canvas canvas, Path path, double progress) {
    if (progress <= 0) return;

    const stops = [0.0, 0.25, 0.5, 0.75, 1.0];
    final metrics = path.computeMetrics().first;

    for (var i = 0; i < stops.length - 1; i++) {
      final segStart = stops[i];
      final segEnd = stops[i + 1];
      if (progress <= segStart) break;

      final segProgress = min(progress, segEnd);
      final startDist = metrics.length * segStart;
      final endDist = metrics.length * segProgress;
      if (endDist <= startDist) continue;

      final segmentPath = metrics.extractPath(startDist, endDist);
      final segmentColor = milestoneColors[i.clamp(0, milestoneColors.length - 1)];
      canvas.drawPath(
        segmentPath,
        Paint()
          ..color = segmentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawMilestone(
    Canvas canvas,
    Size size,
    double position,
    IconData icon,
    Color color,
    _MilestoneState state,
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

    final isAchieved = state == _MilestoneState.achieved;
    final isCurrent = state == _MilestoneState.current;
    final isUpcoming = state == _MilestoneState.upcoming;

    if (isUpcoming) {
      final fillPaint = Paint()
        ..color = upcomingFill
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 16, fillPaint);

      final borderPaint = Paint()
        ..color = upcomingBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(x, y), 16, borderPaint);
    } else {
      if (isAchieved || isCurrent) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: isAchieved ? 0.38 : 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(Offset(x, y), 18, glowPaint);
      }

      final nodeFill = isAchieved ? color : color.withValues(alpha: 0.92);

      final circlePaint = Paint()
        ..color = nodeFill
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 16, circlePaint);

      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(Offset(x, y), 16, borderPaint);
    }

    final iconColor = isUpcoming
        ? upcomingIcon
        : Colors.white;

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 20,
          fontFamily: icon.fontFamily,
          color: iconColor,
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
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(Offset(position.dx, position.dy + 22), 12, shadowPaint);

    // Draw traveler glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
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
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.bounceValue != bounceValue ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.upcomingFill != upcomingFill ||
        oldDelegate.upcomingIcon != upcomingIcon ||
        oldDelegate.upcomingBorder != upcomingBorder;
  }
}

enum _MilestoneState { achieved, current, upcoming }
