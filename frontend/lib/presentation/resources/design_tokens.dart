import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_shadows.dart';
import 'package:mudabbir/constants/app_spacing.dart';
import 'package:mudabbir/presentation/resources/ios_style_constants.dart';

export 'package:mudabbir/constants/app_radius.dart';
export 'package:mudabbir/constants/app_shadows.dart';
export 'package:mudabbir/constants/app_spacing.dart';
export 'package:mudabbir/constants/app_dimensions.dart' show Spacing, RadiusTokens, IconSize;

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
  static const double buttonHeight = AppSpacing.buttonHeight;
  static const Size buttonMinSize = Size(buttonHeight, buttonHeight);
}

abstract final class AppElevation {
  /// Card shadow — iOS sm in light; none in dark (use [cardBorder]).
  static List<BoxShadow> cardShadow({required bool isDark}) =>
      AppShadows.cardForBrightness(isDark: isDark);

  /// Dark mode border substitute for shadows.
  static Border cardBorder({required bool isDark}) =>
      AppShadows.surfaceBorder(isDark: isDark);

  static List<BoxShadow> heroShadow({required bool isDark}) =>
      AppShadows.lg(isDark: isDark);
}

/// مدبر type scale — prefer [AppTypography] in constants/app_typography.dart.
abstract final class AppTypographyScale {
  static const double display = 24;
  static const double title = 20;
  static const double cardTitle = 15;
  static const double body = 15;
  static const double caption = 13;

  static const double displayTracking = -0.5;
  static const double titleTracking = -0.3;
  static const double bodyTracking = 0;

  static const double displayHeight = 1.2;
  static const double titleHeight = 1.25;
  static const double bodyHeight = 1.45;
  static const double captionHeight = 1.35;

  // Legacy aliases
  static const double largeTitle = display;
  static const double pageTitle = display;
  static const double sectionTitle = title;
  static const double callout = body;
  static const double subhead = body;
  static const double footnote = caption;
  static const double caption2 = caption;

  static const double largeTitleTracking = displayTracking;
  static const double headlineTracking = displayTracking;
  static const double largeTitleHeight = displayHeight;
  static const double headlineHeight = displayHeight;
}
