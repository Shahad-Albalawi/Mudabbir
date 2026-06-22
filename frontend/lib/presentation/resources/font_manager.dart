import 'package:flutter/material.dart';

/// App font — Thmanyah (خط ثمانية) for Arabic and English UI text.
class FontConstants {
  static const String thmanyahFamily = 'Thmanyah';
  /// Rare glyph fallback only; primary UI is always Thmanyah.
  static const String fallbackFamily = 'Tajawal';
  static const String fontFamily = thmanyahFamily;

  static const List<String> fontFamilyFallback = [fallbackFamily];
}

class FontWeightManager {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  // Only 400/500 globally (premium fintech consistency).
  static const FontWeight semibold = medium;
  static const FontWeight bold = medium;
  static const FontWeight light = regular;
}

// font sizes now
class FontSize {
  static const double s12 = 12.0;
  static const double s13 = 13.0;
  static const double s14 = 14.0;
  static const double s16 = 16.0;
  static const double s17 = 17.0;
  static const double s18 = 18.0;
  static const double s20 = 20.0;
  static const double s22 = 22.0;
  static const double s24 = 24.0;
  static const double s28 = 28.0;
}
