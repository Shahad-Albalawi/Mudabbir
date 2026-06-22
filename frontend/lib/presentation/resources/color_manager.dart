import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_colors.dart';

/// Semantic colors for legacy widgets. Light values mirror [AppColors].
/// Prefer `Theme.of(context).colorScheme` in new UI (especially dark mode).
class ColorManager {
  static const Color primary = AppColors.primary;
  static const Color darkPrimary = BrandPalette.brandPrimary;
  static const Color lightPrimary = BrandPalette.brandPrimary;
  static const Color dataGreen = BrandPalette.green500;

  static const Color grey = Color(0xFF8B95AD);
  static const Color grey1 = AppColors.textSecondary;
  static const Color grey2 = BrandPalette.navy500;
  static const Color grey200 = Color(0xFFDDE2EE);
  static const Color grey300 = Color(0xFFC8D0E0);
  static const Color grey600 = BrandPalette.navy600;
  static const Color grey700 = BrandPalette.navy700;
  static const Color grey800 = BrandPalette.navy800;
  static const Color lightGrey = Color(0xFFC8D0E0);
  static const Color darkGrey = AppColors.textPrimary;

  static const Color white = AppColors.card;
  static const Color black = BrandPalette.ink;
  static const Color error = BrandPalette.error;
  static const Color success = BrandPalette.green500;
  static const Color warning = BrandPalette.warning;

  static const Color accent = AppColors.accent;
  static const Color secondary = AppColors.secondary;

  static const Color background = AppColors.background;
  static const Color cardBackground = AppColors.card;
  static const Color shadow = Color(0x0D000000);

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  static const Color onboardingBackground = AppColors.background;
  static const Color onboardingCard = AppColors.card;
  static const Color dotInactive = Color(0xFFDDE2EE);
  static const Color overlay = Color(0x660B1328);

  static const Color navBarFrosted = Color(0xE6FFFFFF);

  static Color get primaryWithOpacity08 => primary.withValues(alpha: 0.08);
  static Color get primaryWithOpacity10 => primary.withValues(alpha: 0.10);
  static Color get primaryWithOpacity12 => primary.withValues(alpha: 0.12);
  static Color get primaryWithOpacity20 => primary.withValues(alpha: 0.20);
  static Color get primaryWithOpacity25 => primary.withValues(alpha: 0.25);
  static Color get primaryWithOpacity30 => primary.withValues(alpha: 0.30);
  static Color get whiteWithOpacity15 => Colors.white.withValues(alpha: 0.15);
  static Color get whiteWithOpacity20 => Colors.white.withValues(alpha: 0.20);
  static Color get whiteWithOpacity25 => Colors.white.withValues(alpha: 0.25);
  static Color get whiteWithOpacity30 => Colors.white.withValues(alpha: 0.30);
  static Color get shadowLight => const Color(0x080B1328);
  static Color get shadowMedium => const Color(0x120B1328);
}
