import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Service to handle all celebration animations and effects
class CelebrationService {
  /// Detect milestone achievement
  static MilestoneType? detectMilestone(
    double previousAmount,
    double newAmount,
    double target,
  ) {
    if (target <= 0) return null;

    final previousPercent = (previousAmount / target * 100).floor();
    final newPercent = (newAmount / target * 100).floor();

    // Goal completed
    if (previousPercent < 100 && newPercent >= 100) {
      return MilestoneType.completed;
    }
    // 75% milestone
    if (previousPercent < 75 && newPercent >= 75) {
      return MilestoneType.seventyFive;
    }
    // 50% milestone
    if (previousPercent < 50 && newPercent >= 50) {
      return MilestoneType.fifty;
    }
    // 25% milestone
    if (previousPercent < 25 && newPercent >= 25) {
      return MilestoneType.twentyFive;
    }

    return null;
  }

  /// Show milestone achievement dialog
  static void showMilestoneDialog(
    BuildContext context,
    MilestoneType milestone,
    String goalName,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          MilestoneDialog(milestone: milestone, goalName: goalName),
    );
  }

  /// Get milestone info
  static MilestoneInfo getMilestoneInfo(MilestoneType type) {
    switch (type) {
      case MilestoneType.twentyFive:
        return MilestoneInfo(
          title: AppStrings.milestone25Title,
          message: AppStrings.milestone25Body,
          emoji: '🎯',
          color: Colors.blue,
        );
      case MilestoneType.fifty:
        return MilestoneInfo(
          title: AppStrings.milestone50Title,
          message: AppStrings.milestone50Body,
          emoji: '🔥',
          color: Colors.orange,
        );
      case MilestoneType.seventyFive:
        return MilestoneInfo(
          title: AppStrings.milestone75Title,
          message: AppStrings.milestone75Body,
          emoji: '⚡',
          color: Colors.purple,
        );
      case MilestoneType.completed:
        return MilestoneInfo(
          title: AppStrings.milestone100Title,
          message: AppStrings.milestone100Body,
          emoji: '🏆',
          color: Colors.green,
        );
    }
  }
}

/// Milestone types
enum MilestoneType { twentyFive, fifty, seventyFive, completed }

/// Milestone information
class MilestoneInfo {
  final String title;
  final String message;
  final String emoji;
  final Color color;

  MilestoneInfo({
    required this.title,
    required this.message,
    required this.emoji,
    required this.color,
  });
}

/// Milestone achievement dialog
class MilestoneDialog extends StatefulWidget {
  final MilestoneType milestone;
  final String goalName;

  const MilestoneDialog({
    super.key,
    required this.milestone,
    required this.goalName,
  });

  @override
  State<MilestoneDialog> createState() => _MilestoneDialogState();
}

class _MilestoneDialogState extends State<MilestoneDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = CelebrationService.getMilestoneInfo(widget.milestone);
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: info.color.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated emoji
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Text(
                      info.emoji,
                      style: const TextStyle(fontSize: 80),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                info.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: info.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Goal name
              Text(
                widget.goalName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                info.message,
                style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Close button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: info.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppStrings.milestoneAwesome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
