import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/ios_dialog_style.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/navigation_service.dart';

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

  /// Auto bottom snackbar when a journey milestone is reached.
  static void showMilestoneSnackbar(
    MilestoneType milestone,
    String goalName,
  ) {
    final context = getIt<NavigationService>().navigatorKey.currentContext;
    if (context == null) return;

    final info = getMilestoneInfo(milestone, Theme.of(context).colorScheme);
    HapticService.success();
    getIt<NavigationService>().showSuccessSnackbar(
      title: '${info.emoji} ${info.title}',
      body: goalName.isEmpty ? info.message : '$goalName — ${info.message}',
    );
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
  static MilestoneInfo getMilestoneInfo(
    MilestoneType type,
    ColorScheme scheme,
  ) {
    switch (type) {
      case MilestoneType.twentyFive:
        return MilestoneInfo(
          title: AppStrings.milestone25Title,
          message: AppStrings.milestone25Body,
          emoji: '🎯',
          color: scheme.primary,
        );
      case MilestoneType.fifty:
        return MilestoneInfo(
          title: AppStrings.milestone50Title,
          message: AppStrings.milestone50Body,
          emoji: '🔥',
          color: scheme.warning,
        );
      case MilestoneType.seventyFive:
        return MilestoneInfo(
          title: AppStrings.milestone75Title,
          message: AppStrings.milestone75Body,
          emoji: '⚡',
          color: scheme.tertiary,
        );
      case MilestoneType.completed:
        return MilestoneInfo(
          title: AppStrings.milestone100Title,
          message: AppStrings.milestone100Body,
          emoji: '🏆',
          color: scheme.success,
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
    final scheme = Theme.of(context).colorScheme;
    final info = CelebrationService.getMilestoneInfo(widget.milestone, scheme);

    return Dialog(
      shape: IOSDialogStyle.dialogShape(),
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: IOSDialogStyle.surfaceDecoration(context).copyWith(
            boxShadow: [
              BoxShadow(
                color: info.color.withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 2,
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: info.color,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                widget.goalName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                info.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.textMuted,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              Semantics(
                button: true,
                label: AppStrings.milestoneAwesome,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: info.color,
                    foregroundColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppStrings.milestoneAwesome),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
