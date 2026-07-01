import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';

/// Rating → semantic color for analysis / behavioral UI.
class AnalysisColors {
  AnalysisColors._();

  /// Score-based ring / accent: green (good), orange (medium), red (poor).
  static Color forScore(ColorScheme scheme, int score) {
    if (score >= 70) return scheme.success;
    if (score >= 45) return scheme.warning;
    return scheme.error;
  }

  static Color health(ColorScheme scheme, String rating) {
    final l = rating.toLowerCase();
    if (_is(rating, l, 'ممتاز', 'excellent') ||
        _is(rating, l, 'جيد', 'good') ||
        l == 'outstanding') {
      return scheme.success;
    }
    if (_is(rating, l, 'مقبول', 'fair')) {
      return scheme.warning;
    }
    if (_is(rating, l, 'ضعيف', 'weak') ||
        _is(rating, l, 'يحتاج تحسين', 'needs work') ||
        _is(rating, l, 'معرض للخطر', 'at risk')) {
      return scheme.error;
    }
    return scheme.textMuted;
  }

  static bool _is(String rating, String lower, String ar, String en) {
    return lower == ar || lower == en;
  }
}
