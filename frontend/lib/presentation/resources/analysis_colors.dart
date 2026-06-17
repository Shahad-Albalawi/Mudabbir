import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';

/// Rating → semantic color for analysis / behavioral UI.
class AnalysisColors {
  AnalysisColors._();

  static Color health(ColorScheme scheme, String rating) {
    final l = rating.toLowerCase();
    if (_is(rating, l, 'ممتاز', 'excellent') || l == 'outstanding') {
      return scheme.success;
    }
    if (_is(rating, l, 'جيد', 'good')) {
      return scheme.success.withValues(alpha: 0.88);
    }
    if (_is(rating, l, 'مقبول', 'fair')) return scheme.warning;
    if (_is(rating, l, 'ضعيف', 'weak') ||
        _is(rating, l, 'يحتاج تحسين', 'needs work')) {
      return scheme.warning.withValues(alpha: 0.92);
    }
    if (_is(rating, l, 'معرض للخطر', 'at risk')) return scheme.error;
    return scheme.homeGreen;
  }

  static bool _is(String rating, String lower, String ar, String en) {
    return lower == ar || lower == en;
  }
}
