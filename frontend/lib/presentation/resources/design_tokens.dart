import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/ios_style_constants.dart';

/// 8pt grid — Apple HIG spacing scale.
abstract final class AppSpacing {
  static const double unit = 8;
  static const double xs = 4;
  static const double sm = 8;
  static const double smd = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

/// Corner radii — premium iOS surfaces.
abstract final class AppRadius {
  /// Inputs: 8px radius.
  static const double input = 8;
  /// Buttons: 12px radius.
  static const double button = 12;
  /// Cards: 16px radius (fintech, confident).
  static const double card = 16;

  // Legacy aliases (mapped to the new system).
  static const double sm = input;
  static const double md = button;
  static const double lg = card;
  static const double xl = card;
  static const double xxl = card;
}

abstract final class AppMotion {
  static const Duration fast =
      Duration(milliseconds: IOSStyleConstants.durationFast);
  static const Duration normal =
      Duration(milliseconds: IOSStyleConstants.durationNormal);
  static const Duration slow =
      Duration(milliseconds: IOSStyleConstants.durationSlow);
  static const Curve standard = Curves.easeInOut;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
}

abstract final class AppTouch {
  static const double minTarget = 44;
  static const double buttonHeight = 48;
  static const Size buttonMinSize = Size(buttonHeight, buttonHeight);
}

abstract final class AppElevation {
  static List<BoxShadow> cardShadow({required bool isDark}) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.18),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
    }
    return [
      BoxShadow(
        color: const Color(0xFF111827).withValues(alpha: 0.06),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: const Color(0xFF111827).withValues(alpha: 0.02),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
  }
}

/// Fintech type scale (Thmanyah for Arabic).
abstract final class AppTypographyScale {
  /// Display: 28sp
  static const double display = 28;
  /// Title: 20sp
  static const double title = 20;
  /// Body: 16sp
  static const double body = 16;
  /// Caption: 13sp
  static const double caption = 13;

  /// Tracking & leading tuned for Arabic + numeric tables.
  static const double displayTracking = -0.2;
  static const double titleTracking = -0.1;
  static const double bodyTracking = 0;

  static const double displayHeight = 1.15;
  static const double titleHeight = 1.25;
  static const double bodyHeight = 1.45;
  static const double captionHeight = 1.35;

  // Legacy aliases (mapped to the new system).
  static const double largeTitle = display;
  static const double pageTitle = display;
  static const double sectionTitle = title;
  static const double cardTitle = title;
  static const double callout = body;
  static const double subhead = body;
  static const double footnote = caption;
  static const double caption2 = caption;

  static const double largeTitleTracking = displayTracking;
  static const double headlineTracking = displayTracking;
  static const double largeTitleHeight = displayHeight;
  static const double headlineHeight = displayHeight;
}
