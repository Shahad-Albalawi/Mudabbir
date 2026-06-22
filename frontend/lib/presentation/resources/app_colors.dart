import 'package:flutter/material.dart';

/// Mudabbir design-system palette — navy primary, success green, slate neutrals.
abstract final class BrandPalette {
  // Primary navy scale
  static const Color navy950 = Color(0xFF0B1120);
  static const Color navy900 = Color(0xFF0A1F44);
  static const Color navy800 = Color(0xFF112B5A);
  static const Color navy700 = Color(0xFF163A73);
  static const Color navy600 = Color(0xFF1D4E89);
  static const Color navy500 = Color(0xFF2B6CB0);

  /// Calm trust blue — premium fintech (not corporate banking navy).
  static const Color trustBlue = Color(0xFF3D6B8C);
  static const Color trustBlueLight = Color(0xFF5A8BA8);
  static const Color trustBlueMuted = Color(0xFF7B9DB5);

  /// App brand — softened for clarity and confidence.
  static const Color brandBlue = trustBlue;
  static const Color brandBlueLight = trustBlueLight;

  /// Unified app brand — iOS-native interactive blue.
  static const Color brandPrimary = iosBlue;
  static const Color brandPrimaryLight = Color(0xFF409CFF);

  /// Branded chrome surfaces (AppBar, nav, splash).
  static const Color chrome = brandPrimary;
  static const Color chromeDeep = brandPrimary;
  static const Color chromeDeepest = navy700;
  static const Color chromeBright = brandPrimaryLight;

  // Success / income — calm positive green
  static const Color green500 = Color(0xFF34C759);
  static const Color green400 = Color(0xFF52B788);
  static const Color green600 = Color(0xFF2F8556);
  static const Color green300 = Color(0xFF6BC49A);
  static const Color green50 = Color(0xFFE8F4EE);

  // Functional — iOS system semantics
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color gold = Color(0xFFC9A227);
  static const Color teal = Color(0xFF14B8A6);

  static const Color slate950 = textPrimaryLight;
  static const Color slate500 = textSecondaryLight;
  static const Color slate400 = textSecondaryDark;
  static const Color slate200 = borderLight;
  static const Color slate100 = Color(0xFFF3F4F6);

  static const Color canvasLight = Color(0xFFF5F5F7);
  static const Color canvasDark = Color(0xFF1C1C1E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2E);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF30363D);

  /// iOS system blue — native interactive accent.
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosBlueDark = Color(0xFF0A84FF);

  static const Color inputFillLight = Color(0xFFF3F4F6);
  static const Color inputFillDark = Color(0xFF21262D);

  static const Color accentSkyStart = Color(0xFFE0F2FE);
  static const Color accentSkyEnd = Color(0xFFBAE6FD);

  // Legacy aliases
  static const Color platinum = slate200;
  static const Color iosGrouped = canvasLight;
  static const Color mist = slate100;
  static const Color ink = slate950;
}

/// Muted chart palette — calm, App Store–quality analytics.
abstract final class FintechPalette {
  static const List<Color> chart = [
    Color(0xFF007AFF),
    Color(0xFF34C759),
    Color(0xFF8E8E93),
    Color(0xFFFF9F0A),
    Color(0xFFAF52DE),
    Color(0xFF5AC8FA),
    Color(0xFF64D2FF),
  ];

  static const Color expense = Color(0xFF8E8E93);
  static const Color income = Color(0xFF34C759);
  static const Color balance = Color(0xFF007AFF);
}

/// Gamification accents — goals journey milestones.
abstract final class GamificationPalette {
  static const Color blue = Color(0xFF3B82F6);
  static const Color indigo = Color(0xFF6366F1);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color amber = Color(0xFFF59E0B);
  static const Color mint = Color(0xFF22C55E);
  static const Color pink = Color(0xFFEC4899);
  static const Color cyan = Color(0xFF06B6D4);

  static const List<Color> milestones = [
    Color(0xFF3B82F6), // مرحلة 1 — أزرق
    Color(0xFF6366F1), // مرحلة 2 — نيلي
    Color(0xFF8B5CF6), // مرحلة 3 — بنفسجي
    Color(0xFFF59E0B), // مرحلة 4 — كهرماني
    Color(0xFF22C55E), // مرحلة 5 — أخضر
  ];

  static const List<Color> confetti = [blue, indigo, purple, amber, mint, pink, cyan];

  static Color progressColor(double progress) {
    if (progress >= 1.0) return mint;
    if (progress >= 0.75) return amber;
    if (progress >= 0.5) return purple;
    if (progress >= 0.25) return indigo;
    return blue;
  }
}

/// Brand gradients from the design guide.
abstract final class BrandGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [BrandPalette.brandPrimary, BrandPalette.brandPrimaryLight],
  );

  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [BrandPalette.brandPrimary, BrandPalette.brandPrimaryLight],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [BrandPalette.green500, BrandPalette.green300],
  );

  static const LinearGradient accentSky = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [BrandPalette.accentSkyStart, BrandPalette.accentSkyEnd],
  );
}

/// Light theme semantic colors.
class AppColors {
  AppColors._();

  static const Color primary = BrandPalette.brandPrimary;
  static const Color dataGreen = BrandPalette.green500;
  static const Color secondary = BrandPalette.slate200;
  static const Color background = BrandPalette.canvasLight;
  static const Color card = BrandPalette.cardLight;
  static const Color textPrimary = BrandPalette.textPrimaryLight;
  static const Color textSecondary = BrandPalette.textSecondaryLight;
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color accent = BrandPalette.green500;
}

class DarkAppColors {
  DarkAppColors._();

  static const Color primary = BrandPalette.iosBlueDark;
  static const Color primaryMuted = Color(0xFF409CFF);

  static const Color secondary = Color(0xFF21262D);
  static const Color background = BrandPalette.canvasDark;
  static const Color card = BrandPalette.cardDark;
  static const Color surfaceElevated = Color(0xFF2A2A2C);

  static const Color textPrimary = BrandPalette.textPrimaryDark;
  static const Color textSecondary = BrandPalette.textSecondaryDark;
  static const Color textTertiary = Color(0xFF64748B);

  static const Color accent = BrandPalette.green400;
  static const Color outline = BrandPalette.borderDark;
  static const Color outlineVariant = Color(0xFF21262D);
}
