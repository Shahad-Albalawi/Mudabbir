import 'package:flutter/material.dart';

/// Theme-aware helpers so screens stay aligned with light/dark [ColorScheme].
extension AppThemeContext on BuildContext {
  ColorScheme get appColors => Theme.of(this).colorScheme;

  /// Elevated card shadow — softer in light mode, subtle depth in dark.
  List<BoxShadow> get appCardShadow => [
        BoxShadow(
          color: appColors.brightness == Brightness.dark
              ? Colors.black.withValues(alpha: 0.42)
              : const Color(0x08000000),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  Color primarySoft(double opacity) =>
      appColors.primary.withValues(alpha: opacity);
}
