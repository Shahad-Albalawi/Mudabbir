import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_colors.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/ios_style_constants.dart';

/// iOS grouped-table spacing and radii (8pt grid).
class AppLayout {
  AppLayout._();

  /// Screen horizontal padding: 20px (premium fintech).
  static const double pageGutter = 20;
  static const double sectionGap = AppSpacing.smd;
  static const double cardRadius = AppRadius.card;
  static const double chipRadius = AppSpacing.sm;
  static const double listRowHeight = AppTouch.minTarget;
  static const double bottomNavHeight = IOSStyleConstants.navBarHeight;
  /// Space for bottom nav + floating chat FAB so list content is not obscured.
  static const double fabClearance = 56 + 16 + 20;
  static const double bottomNavClearance = bottomNavHeight + fabClearance;
}

/// iOS system-like semantic colors (charts, status).
extension AppSemanticColors on ColorScheme {
  Color get success => brightness == Brightness.dark
      ? BrandPalette.green500
      : BrandPalette.green600;

  Color get warning => BrandPalette.warning;

  /// Muted fintech chart palette — calm, distinct segments.
  List<Color> get chartPalette => brightness == Brightness.dark
      ? FintechPalette.chart
      : FintechPalette.chart;

  /// Expense amounts — neutral slate, not alarming red.
  Color get expenseAmount => brightness == Brightness.dark
      ? const Color(0xFFB8C4D4)
      : BrandPalette.slate950;

  /// Income / positive balance amounts.
  Color get incomeAmount => dataGreen;

  /// Strong label color for financial rows (readable navy/slate).
  Color get financialLabel => brightness == Brightness.dark
      ? const Color(0xFFE2E8F0)
      : BrandPalette.slate950;

  /// Green reserved for numeric values (amounts, scores) — not labels or links.
  Color get dataGreen => BrandPalette.green500;

  /// Neutral icon / chrome on cards — brighter in dark for legibility.
  Color get chromeIcon => brightness == Brightness.dark
      ? DarkAppColors.primary
      : BrandPalette.brandPrimary;

  Color get chromeIconFill => brightness == Brightness.dark
      ? const Color(0xFF21262D)
      : BrandPalette.inputFillLight;

  /// Branded accent — prefer [dataGreen] for amounts only.
  Color get homeGreen => dataGreen;

  Color get homeGreenSoft => dataGreen.withValues(
        alpha: brightness == Brightness.dark ? 0.18 : 0.12,
      );

  /// Subtle branded tint for welcome cards.
  Color get homeBannerFill => brightness == Brightness.dark
      ? DarkAppColors.card
      : BrandPalette.cardLight;

  Color get heroOnGradient => onSurface;

  Color get heroMutedOnGradient => textMuted;

  /// Primary readable text on cards (dark mode tuned).
  Color get textOnCard => brightness == Brightness.dark
      ? DarkAppColors.textPrimary
      : onSurface;

  /// Tertiary labels — timestamps, hints, captions.
  Color get textTertiary => brightness == Brightness.dark
      ? DarkAppColors.textTertiary
      : AppColors.textTertiary;

  /// Secondary labels under icons / muted card copy.
  Color get textMuted => brightness == Brightness.dark
      ? DarkAppColors.textSecondary
      : AppColors.textSecondary;

  /// Skeleton shimmer base — visible in dark without harsh contrast.
  Color get skeletonBase => brightness == Brightness.dark
      ? const Color(0xFF21262D)
      : BrandPalette.borderLight.withValues(alpha: 0.5);

  /// Skeleton shimmer peak opacity multiplier.
  double get skeletonPulseHigh => brightness == Brightness.dark ? 0.55 : 0.65;

  double get skeletonPulseLow => brightness == Brightness.dark ? 0.28 : 0.35;

  /// iOS grouped table background — used for full-page scaffolds.
  Color get pageBackground => brightness == Brightness.dark
      ? BrandPalette.canvasDark
      : BrandPalette.canvasLight;

  /// Secondary grouped fill (insets, chips, skeleton tracks).
  Color get groupedFill => brightness == Brightness.dark
      ? BrandPalette.inputFillDark
      : BrandPalette.inputFillLight;

  /// Tab bar / elevated chrome above page background.
  Color get elevatedSurface => brightness == Brightness.dark
      ? DarkAppColors.surfaceElevated
      : surface;

  /// Insight / assistant surface tint.
  Color get insightSurface => groupedFill;

  /// Inset field background (forms).
  Color get inputFill => groupedFill;
}
