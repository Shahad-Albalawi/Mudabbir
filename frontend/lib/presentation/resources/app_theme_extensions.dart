import 'package:flutter/material.dart';

/// Theme-aware helpers — prefer [ColorScheme] over hardcoded colors.
extension AppThemeContext on BuildContext {
  ColorScheme get appColors => Theme.of(this).colorScheme;

  /// Deprecated: use bordered [AppCard] instead of shadows.
  List<BoxShadow> get appCardShadow => const [];
}
