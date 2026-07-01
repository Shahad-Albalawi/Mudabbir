import 'package:flutter/material.dart';
import 'package:mudabbir/core/theme/app_theme.dart';

/// Rounded progress track used in budget, goals, and challenges.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.color,
    this.backgroundColor,
  });

  final double value;
  final double height;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final fill = color ?? AppColors.navy;
    final track = backgroundColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppColors.surface2Dark
            : AppColors.surface2);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusChip),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: clamped,
          minHeight: height,
          backgroundColor: track,
          color: fill,
        ),
      ),
    );
  }
}

typedef ProgressBar = AppProgressBar;
