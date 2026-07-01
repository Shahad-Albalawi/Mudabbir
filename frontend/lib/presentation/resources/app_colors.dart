import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_colors.dart' as core;

/// مدبر — presentation-layer palette (aliases [core.AppColors]).
abstract final class BrandPalette {
  // === Primary ===
  static const Color navy = core.AppColors.primary;
  static const Color green = core.AppColors.green;

  // === Chart ===
  static const Color chart1 = core.AppColors.chartBlue;
  static const Color chart2 = core.AppColors.chartPurple;
  static const Color chart3 = core.AppColors.chartIce;

  // === Light surfaces ===
  static const Color bg = core.AppColors.background;
  static const Color cardLight = core.AppColors.surface;
  static const Color borderLight = core.AppColors.border;
  static const Color textMutedLight = core.AppColors.textSecondary;
  static const Color textHint = core.AppColors.textTertiary;
  static const Color surface = core.AppColors.surfaceTint;
  static const Color gridline = core.AppColors.divider;

  // === Semantic ===
  static const Color danger = core.AppColors.red;
  static const Color dangerBg = core.AppColors.redSurface;
  static const Color greenBg = core.AppColors.greenSurface;
  static const Color warning = core.AppColors.gold;

  // === Dark mode (iOS layered surfaces) ===
  static const Color canvasDark = core.AppColors.darkBackground;
  static const Color cardDark = core.AppColors.darkSurface;
  static const Color textPrimaryDark = core.AppColors.darkTextPrimary;
  static const Color textSecondaryDark = core.AppColors.darkTextSecondary;
  static const Color borderDark = core.AppColors.darkBorder;
  static const Color inputFillDark = core.AppColors.darkSurfaceElevated;

  // Legacy aliases
  static const Color navy950 = core.AppColors.primaryDark;
  static const Color navy900 = navy;
  static const Color navy800 = navy;
  static const Color navy700 = core.AppColors.primaryDark;
  static const Color navy600 = navy;
  static const Color navy500 = chart1;

  static const Color brandPrimary = navy;
  static const Color brandPrimaryLight = core.AppColors.primaryLight;
  static const Color chrome = navy;
  static const Color chromeDeep = navy;
  static const Color chromeDeepest = core.AppColors.primaryDark;
  static const Color chromeBright = chart1;

  static const Color green500 = green;
  static const Color green400 = green;
  static const Color green600 = Color(0xFF059669);
  static const Color green300 = core.AppColors.darkGreen;
  static const Color green50 = greenBg;

  static const Color error = danger;
  static const Color gold = core.AppColors.gold;
  static const Color teal = green;

  static const Color slate950 = navy;
  static const Color slate500 = textMutedLight;
  static const Color slate400 = textSecondaryDark;
  static const Color slate200 = borderLight;
  static const Color slate100 = surface;

  static const Color canvasLight = bg;
  static const Color textPrimaryLight = core.AppColors.textPrimary;
  static const Color textSecondaryLight = textMutedLight;

  static const Color iosBlue = chart1;
  static const Color iosBlueDark = core.AppColors.darkPrimary;

  static const Color inputFillLight = surface;
  static const Color accentSkyStart = core.AppColors.primarySurface;
  static const Color accentSkyEnd = core.AppColors.surfaceTint;

  static const Color platinum = borderLight;
  static const Color iosGrouped = bg;
  static const Color mist = surface;
  static const Color ink = core.AppColors.textPrimary;
}

/// Chart palette — official segment colors.
abstract final class FintechPalette {
  static const List<Color> chart = [
    BrandPalette.chart1,
    BrandPalette.chart2,
    BrandPalette.chart3,
  ];

  static const Color expense = BrandPalette.textMutedLight;
  static const Color income = BrandPalette.green;
  static const Color balance = BrandPalette.navy;
}

/// Gamification accents — goals journey milestones.
abstract final class GamificationPalette {
  static const Color blue = BrandPalette.chart1;
  static const Color indigo = BrandPalette.chart2;
  static const Color purple = BrandPalette.chart2;
  static const Color amber = BrandPalette.warning;
  static const Color mint = BrandPalette.green;
  static const Color pink = BrandPalette.chart3;
  static const Color cyan = BrandPalette.chart3;

  static const List<Color> milestones = [
    BrandPalette.chart1,
    BrandPalette.chart2,
    BrandPalette.chart3,
    BrandPalette.warning,
    BrandPalette.green,
  ];

  static const List<Color> confetti = milestones;

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
    colors: [BrandPalette.navy, BrandPalette.chart1],
  );

  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [BrandPalette.navy, core.AppColors.navyGradientEnd],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [BrandPalette.green, BrandPalette.green300],
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

  static const Color primary = BrandPalette.navy;
  static const Color dataGreen = BrandPalette.green;
  static const Color secondary = BrandPalette.borderLight;
  static const Color background = BrandPalette.bg;
  static const Color card = BrandPalette.cardLight;
  static const Color textPrimary = BrandPalette.textPrimaryLight;
  static const Color textSecondary = BrandPalette.textMutedLight;
  static const Color textTertiary = BrandPalette.textHint;
  static const Color accent = BrandPalette.green;
}

class DarkAppColors {
  DarkAppColors._();

  static const Color primary = core.AppColors.darkPrimary;
  static const Color primaryMuted = core.AppColors.darkPrimary;

  static const Color secondary = BrandPalette.inputFillDark;
  static const Color background = BrandPalette.canvasDark;
  static const Color card = BrandPalette.cardDark;
  static const Color surfaceElevated = core.AppColors.darkSurfaceElevated;

  static const Color textPrimary = BrandPalette.textPrimaryDark;
  static const Color textSecondary = BrandPalette.textSecondaryDark;
  static const Color textTertiary = core.AppColors.darkTextTertiary;

  static const Color accent = core.AppColors.darkGreen;
  static const Color outline = BrandPalette.borderDark;
  static const Color outlineVariant = core.AppColors.darkDivider;
}
