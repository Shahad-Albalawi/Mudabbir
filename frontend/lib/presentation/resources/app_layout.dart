import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/ios_style_constants.dart';

/// iOS grouped-table spacing and radii (8pt grid).
class AppLayout {
  AppLayout._();

  static const double pageGutter = 16;
  static const double sectionGap = 12;
  static const double cardRadius = IOSStyleConstants.radiusSmall;
  static const double chipRadius = 8;
  static const double listRowHeight = 44;
  static const double bottomNavClearance =
      IOSStyleConstants.navBarHeight + 12;
}

/// iOS system-like semantic colors (charts, status).
extension AppSemanticColors on ColorScheme {
  Color get success => brightness == Brightness.dark
      ? const Color(0xFF72C98E)
      : const Color(0xFF34C759);

  Color get warning => brightness == Brightness.dark
      ? const Color(0xFFD9A84A)
      : const Color(0xFFFF9500);

  /// Theme-aware chart palette (pie / bar legends).
  List<Color> get chartPalette => brightness == Brightness.dark
      ? [
          const Color(0xFF6EAD8A),
          const Color(0xFF8BB89A),
          const Color(0xFFA8C4B0),
          const Color(0xFFC4B08A),
          const Color(0xFF9AA8A0),
        ]
      : [
          const Color(0xFF2D6A4F),
          const Color(0xFF40916C),
          const Color(0xFF52B788),
          const Color(0xFF74C69D),
          const Color(0xFF8B7355),
        ];

  /// Home screen branded green — slightly brighter in dark for legibility.
  Color get homeGreen => brightness == Brightness.dark
      ? const Color(0xFF84D4A6)
      : primary;

  Color get homeGreenSoft => homeGreen.withValues(
        alpha: brightness == Brightness.dark ? 0.2 : 0.12,
      );

  Color get homeBannerFill => brightness == Brightness.dark
      ? homeGreen.withValues(alpha: 0.1)
      : const Color(0xFFE6F2EB);

  /// Primary readable text on cards (dark mode tuned).
  Color get textOnCard => brightness == Brightness.dark
      ? const Color(0xFFF8FAF9)
      : onSurface;

  /// Secondary labels under icons / muted card copy.
  Color get textMuted => brightness == Brightness.dark
      ? const Color(0xFFDCE6E0)
      : const Color(0xFF4A4A4A);
}
