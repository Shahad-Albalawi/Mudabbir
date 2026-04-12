import 'package:flutter/material.dart';

/// Vivid but readable palette — stronger saturation on mobile, iOS-friendly contrast.
class AppColors {
  AppColors._();

  /// Primary — saturated forest green
  static const Color primary = Color(0xFF1F7A54);

  /// Supporting tint (cards / chips)
  static const Color secondary = Color(0xFFB8D9C8);

  /// App background (slightly cool mint-gray)
  static const Color background = Color(0xFFE8F0EB);

  static const Color card = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF14231C);

  static const Color textSecondary = Color(0xFF4D5C54);

  /// Warm gold accent
  static const Color accent = Color(0xFFC49A3A);
}

/// Dark mode — high contrast text on deep surfaces (fixes low legibility).
class DarkAppColors {
  DarkAppColors._();

  static const Color primary = Color(0xFF4BE39A);
  static const Color secondary = Color(0xFF3D5248);
  static const Color background = Color(0xFF0C100E);
  static const Color card = Color(0xFF151C18);
  static const Color textPrimary = Color(0xFFF4FBF7);
  static const Color textSecondary = Color(0xFFC5D1CA);
  static const Color accent = Color(0xFFE8D18A);
}
