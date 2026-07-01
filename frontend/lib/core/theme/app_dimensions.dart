/// مدبّر — spacing and corner radius tokens (4px grid).
abstract final class Spacing {
  Spacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
  static const double buttonHeight = 52.0;
}

/// Corner radii — use [RadiusTokens] in UI code (avoids `dart:ui` [Radius] clash).
abstract final class AppRadius {
  AppRadius._();

  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 14.0;
  static const double lg = 20.0;
  static const double xl = 26.0;
  static const double xxl = 22.0;
  static const double full = 100.0;

  static const double input = md;
  static const double button = 14.0;
  static const double card = 20.0;
  static const double cardLarge = 20.0;
  static const double cardHero = 22.0;
  static const double pill = full;
  static const double cardSmall = 20.0;
  static const double logoMark = 26.0;
  static const double sheet = 26.0;
  static const double icon = 14.0;
  static const double appIcon = 26.0;
}

/// Design-system corner radii (preferred name in widgets).
abstract final class RadiusTokens {
  RadiusTokens._();

  static const double xs = AppRadius.xs;
  static const double sm = AppRadius.sm;
  static const double md = AppRadius.md;
  static const double lg = AppRadius.lg;
  static const double xl = AppRadius.xl;
  static const double xxl = AppRadius.xxl;
  static const double full = AppRadius.full;

  static const double input = AppRadius.md;
  static const double button = AppRadius.sm;
  static const double card = AppRadius.lg;
  static const double cardLarge = AppRadius.xl;
  static const double cardHero = AppRadius.xxl;
  static const double pill = AppRadius.full;
}

abstract final class IconSize {
  IconSize._();

  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
