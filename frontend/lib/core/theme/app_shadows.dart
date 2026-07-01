import 'package:flutter/material.dart';
import 'package:mudabbir/core/theme/app_colors.dart';

/// مدبّر — iOS-style shadows (light only; dark uses borders).
abstract final class AppShadows {
  AppShadows._();

  static const List<BoxShadow> none = [];

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static List<BoxShadow> card(BuildContext context) {
    if (_isDark(context)) return none;
    return cardLight;
  }

  static List<BoxShadow> cardForBrightness({required bool isDark}) {
    if (isDark) return none;
    return cardLight;
  }

  static const List<BoxShadow> cardLight = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> primaryCard(BuildContext context) {
    if (_isDark(context)) return none;
    return primaryCardLight;
  }

  static const List<BoxShadow> primaryCardLight = [
    BoxShadow(
      color: Color(0x400F2878),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x1A0F2878),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> xs({bool isDark = false}) {
    if (isDark) return none;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static List<BoxShadow> sm({bool isDark = false}) {
    if (isDark) return none;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> md({bool isDark = false}) {
    if (isDark) return none;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> lg({bool isDark = false}) {
    if (isDark) return none;
    return [
      BoxShadow(
        color: AppColors.navy1.withValues(alpha: 0.20),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static Border surfaceBorder({required bool isDark, double width = 0.5}) {
    return Border.all(
      color: isDark ? AppColors.bdDark : AppColors.bdLight,
      width: width,
    );
  }
}
