import 'package:flutter/material.dart';

/// Classic neutral palette — clean whites and restrained green.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2D6A4F);
  static const Color secondary = Color(0xFFE8EDEA);
  static const Color background = Color(0xFFF7F7F5);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color accent = Color(0xFF8B7355);
}

class DarkAppColors {
  DarkAppColors._();

  /// iOS-style elevated dark — soft contrast, easy on the eyes.
  static const Color primary = Color(0xFF6EAD8A);
  static const Color secondary = Color(0xFF2A302D);
  static const Color background = Color(0xFF141615);
  static const Color card = Color(0xFF222624);
  static const Color surfaceElevated = Color(0xFF1A1D1B);
  static const Color textPrimary = Color(0xFFF8FAF9);
  static const Color textSecondary = Color(0xFFDCE6E0);
  static const Color accent = Color(0xFFC4B08A);
  static const Color outline = Color(0xFF3A403D);
  static const Color outlineVariant = Color(0xFF2E3431);
}
