import 'package:flutter/material.dart';

/// Font weights used across the type scale.
abstract final class AppFontWeights {
  AppFontWeights._();

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}

/// IBM Plex Sans Arabic — bundled in `assets/fonts/IBMPlexSansArabic/`.
abstract final class AppTypography {
  AppTypography._();

  static const String fontFamily = 'IBMPlexSansArabic';

  static TextTheme get textTheme => TextTheme(
        displayLarge: _eight(40, FontWeight.w800, -1.5),
        displayMedium: _eight(32, FontWeight.w800, -1.0),
        displaySmall: _eight(24, FontWeight.w700, -0.5),
        headlineLarge: _eight(22, FontWeight.w800, -0.3),
        headlineMedium: _eight(19, FontWeight.w700, 0.0),
        headlineSmall: _eight(17, FontWeight.w700, 0.0),
        titleLarge: _eight(15, FontWeight.w600, 0.0),
        titleMedium: _eight(14, FontWeight.w600, 0.0),
        titleSmall: _eight(13, FontWeight.w600, 0.1),
        bodyLarge: _eight(15, FontWeight.w400, 0.0),
        bodyMedium: _eight(14, FontWeight.w400, 0.0),
        bodySmall: _eight(12, FontWeight.w400, 0.1),
        labelLarge: _eight(13, FontWeight.w600, 0.1),
        labelMedium: _eight(11, FontWeight.w600, 0.2),
        labelSmall: _eight(10, FontWeight.w500, 0.2),
      );

  static TextStyle _eight(double size, FontWeight w, double spacing) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: w,
        letterSpacing: spacing,
        height: 1.4,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Applies primary/secondary colors to the base [textTheme].
  static TextTheme themed({
    required Color primary,
    required Color secondary,
  }) {
    return textTheme
        .apply(
          bodyColor: primary,
          displayColor: primary,
          fontFamily: fontFamily,
        )
        .copyWith(
          bodySmall: textTheme.bodySmall?.copyWith(color: secondary),
          labelMedium: textTheme.labelMedium?.copyWith(color: secondary),
          labelSmall: textTheme.labelSmall?.copyWith(color: secondary),
        );
  }

  static TextStyle withTabularFigures(TextStyle style) =>
      style.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  // Legacy color-parameter helpers — prefer Theme.of(context).textTheme
  static TextStyle displayLarge(Color color) =>
      textTheme.displayLarge!.copyWith(color: color);
  static TextStyle displayMedium(Color color) =>
      textTheme.displayMedium!.copyWith(color: color);
  static TextStyle displaySmall(Color color) =>
      textTheme.displaySmall!.copyWith(color: color);
  static TextStyle financialDisplayLarge(Color color) => displayLarge(color);
  static TextStyle financialDisplayMedium(Color color) => displayMedium(color);
  static TextStyle financialDisplaySmall(Color color) => displaySmall(color);
  static TextStyle headlineLarge(Color color) =>
      textTheme.headlineLarge!.copyWith(color: color);
  static TextStyle headlineMedium(Color color) =>
      textTheme.headlineMedium!.copyWith(color: color);
  static TextStyle headlineSmall(Color color) =>
      textTheme.headlineSmall!.copyWith(color: color);
  static TextStyle titleLarge(Color color) =>
      textTheme.titleLarge!.copyWith(color: color);
  static TextStyle titleMedium(Color color) =>
      textTheme.titleMedium!.copyWith(color: color);
  static TextStyle titleSmall(Color color) =>
      textTheme.titleSmall!.copyWith(color: color);
  static TextStyle bodyLarge(Color color) =>
      textTheme.bodyLarge!.copyWith(color: color);
  static TextStyle bodyMedium(Color color) =>
      textTheme.bodyMedium!.copyWith(color: color);
  static TextStyle bodySmall(Color color) =>
      textTheme.bodySmall!.copyWith(color: color);
  static TextStyle labelLarge(Color color) =>
      textTheme.labelLarge!.copyWith(color: color);
  static TextStyle labelMedium(Color color) =>
      textTheme.labelMedium!.copyWith(color: color);
  static TextStyle labelSmall(Color color) =>
      textTheme.labelSmall!.copyWith(color: color);
  static TextStyle heading1(Color color) => headlineLarge(color);
  static TextStyle heading2(Color color) => titleLarge(color);
  static TextStyle body(Color color) => bodyLarge(color);
  static TextStyle caption(Color color) => labelLarge(color);
  static TextStyle financialBodyLarge(Color color) => bodyLarge(color);
  static TextStyle financialBodyMedium(Color color) => bodyMedium(color);
}

extension AppTypographyTabular on TextStyle {
  TextStyle get tabular => AppTypography.withTabularFigures(this);
}
