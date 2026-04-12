/// App Store–grade design constants. Refined, minimal, premium.
class IOSStyleConstants {
  IOSStyleConstants._();

  // Corner radius (8pt grid aligned)
  static const double radiusSmall = 10;
  static const double radiusMedium = 14;
  static const double radiusLarge = 18;
  static const double radiusXLarge = 22;

  // Animation – smooth, natural curves
  static const int durationFast = 180;
  static const int durationNormal = 280;
  static const int durationSlow = 400;
  static const int durationPage = 350;

  // Shadow (barely-there depth)
  static const double shadowBlur = 14;
  static const double shadowBlurLarge = 24;
  static const double shadowOpacity = 0.06;
  static const double shadowOpacityLight = 0.04;

  // Micro-interaction: subtle press (not jarring)
  static const double pressScale = 0.975;

  // Bottom nav (perfect alignment)
  static const double navBarHeight = 76;
  static const double navBarRadius = 24;
}
