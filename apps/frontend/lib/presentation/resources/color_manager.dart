import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_colors.dart';

/// Semantic colors for legacy widgets. Light values mirror [AppColors].
/// Prefer `Theme.of(context).colorScheme` in new UI (especially dark mode).
class ColorManager {
  static const Color primary = AppColors.primary;
  static const Color darkPrimary = Color(0xFF145C3D);
  static const Color lightPrimary = Color(0xFF2FA06F);

  static const Color grey = Color(0xFF9CA3AF);
  static const Color grey1 = AppColors.textSecondary;
  static const Color grey2 = Color(0xFF6B7280);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color lightGrey = Color(0xFFD1D5DB);
  static const Color darkGrey = AppColors.textPrimary;

  static const Color white = AppColors.card;
  static const Color black = Color(0xFF121212);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = AppColors.accent;

  static const Color accent = AppColors.accent;
  static const Color secondary = AppColors.secondary;

  static const Color background = AppColors.background;
  static const Color cardBackground = AppColors.card;
  static const Color shadow = Color(0x0D000000);

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  static const Color onboardingBackground = AppColors.background;
  static const Color onboardingCard = AppColors.card;
  static const Color dotInactive = Color(0xFFE5E7EB);
  static const Color overlay = Color(0x4D000000);

  static const Color navBarFrosted = Color(0xF2FFFFFF);

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
  static Color get shadowLight => const Color(0x08000000);
  static Color get shadowMedium => const Color(0x12000000);
}
