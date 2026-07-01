import 'package:flutter/material.dart';

/// مدبّر — Navy brand palette + semantic + light/dark surfaces.
abstract final class AppColors {
  AppColors._();

  // ── BRAND NAVY (هوية مدبّر) ──
  static const Color navy = Color(0xFF0F2878);
  static const Color navyMedium = Color(0xFF1B3FA0);
  static const Color navyLight = Color(0xFF2C53C2);
  static const Color navySoft = Color(0xFFEEF2FF);
  static const Color navyPale = Color(0xFFC7D7F9);

  static const Color navy1 = navy;
  static const Color navy2 = navyMedium;
  static const Color navy3 = navyLight;
  static const Color navy4 = Color(0xFF3D6AE0);
  static const Color navySurface = navySoft;
  static const Color navyBorder = navyPale;

  // Dashboard — Navy متدرج
  static const Color db1 = navy;
  static const Color db2 = navyMedium;
  static const Color db3 = navyLight;
  static const Color db4 = navy4;
  static List<Color> get navyGradient => [navy1, navy4];

  // ── SEMANTIC ──
  static const Color success = Color(0xFF166534);
  static const Color successSoft = Color(0xFFF0FDF4);
  static const Color danger = Color(0xFF991B1B);
  static const Color dangerSoft = Color(0xFFFEF2F2);
  static const Color gold = Color(0xFF854D0E);
  static const Color goldSoft = Color(0xFFFFFBEB);

  static const Color green = success;
  static const Color greenS = successSoft;
  static const Color red = danger;
  static const Color redS = dangerSoft;
  static const Color goldS = goldSoft;

  // ── LIGHT SURFACES ──
  static const Color bg = Color(0xFFF5F5F7);
  static const Color surface1 = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF2F2F5);
  static const Color text1 = Color(0xFF111118);
  static const Color text2 = Color(0xFF525265);
  static const Color text3 = Color(0xFF9696A8);
  static const Color text4 = Color(0xFFD0D0DC);
  static const Color border = Color(0xFFE2E2EC);
  static const Color divider = Color(0xFFEEEEEF);

  static const Color bgLight = bg;
  static const Color s1Light = surface1;
  static const Color s2Light = surface2;
  static const Color t1Light = text1;
  static const Color t2Light = text2;
  static const Color t3Light = text3;
  static const Color t4Light = text4;
  static const Color bdLight = border;
  static const Color dvLight = divider;

  // ── DARK SURFACES (WCAG AA — text ≥ 4.5:1 on bg/card) ──
  static const Color bgDark = Color(0xFF0C0C0F);
  static const Color surface1Dark = Color(0xFF1C1C22);
  static const Color surface2Dark = Color(0xFF26262E);
  static const Color text1Dark = Color(0xFFF2F2F8);
  static const Color text2Dark = Color(0xFFA0A0B8);

  /// إطار خارجي خلف «شاشة الهاتف» (Splash).
  static const Color splashFrame = Color(0xFF141418);
  static const Color s1Dark = surface1Dark;
  static const Color s2Dark = surface2Dark;
  static const Color s3Dark = Color(0xFF2E2E36);
  static const Color t1Dark = text1Dark;
  static const Color t2Dark = text2Dark;
  static const Color t3Dark = Color(0xFF9A9AA6);
  static const Color t4Dark = Color(0xFF6E6E78);
  static const Color bdDark = Color(0xFF35353F);
  static const Color dvDark = Color(0xFF2A2A32);

  /// Primary في الداكن — أزرق أفتح (#4A7CE8) بدل الكحلي الغامق.
  static const Color navyDark = Color(0xFF4A7CE8);
  static const Color navySurfaceDark = Color(0xFF1E2A44);

  // ── Shared ──
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;
  static const Color orange = Color(0xFFE07A2F);
  static const Color orangeSurface = Color(0xFFFFF4EC);

  // ── Legacy aliases (backward compatibility) ──
  static const Color primary = navy1;
  static const Color primaryLight = navy2;
  static const Color primaryDark = Color(0xFF0A1F5C);
  static const Color primarySurface = navySurface;
  static const Color primarySurfaceDark = s2Dark;
  static const Color primaryDarkMode = navyDark;

  static const Color greenSurface = greenS;
  static const Color greenSurfaceDark = Color(0xFF0F2E1E);
  static const Color redSurface = redS;
  static const Color redSurfaceDark = Color(0xFF2D1515);
  static const Color goldSurface = goldS;
  static const Color goldSurfaceDark = Color(0xFF2D2510);
  static const Color goldDark = Color(0xFFD4A017);
  static const Color greenDark = Color(0xFF34D399);
  static const Color redDark = Color(0xFFF87171);

  static const Color backgroundLight = bgLight;
  static const Color surfaceLight = s1Light;
  static const Color surfaceElevatedLight = s1Light;
  static const Color surfaceTintLight = s2Light;

  static const Color backgroundDark = bgDark;
  static const Color surfaceDark = s1Dark;
  static const Color surfaceElevatedDark = s2Dark;
  static const Color surfaceTopDark = s3Dark;

  static const Color textPrimaryLight = t1Light;
  static const Color textSecondaryLight = t2Light;
  static const Color textTertiaryLight = t3Light;
  static const Color textDisabledLight = t4Light;

  static const Color textPrimaryDark = t1Dark;
  static const Color textSecondaryDark = t2Dark;
  static const Color textTertiaryDark = t3Dark;
  static const Color textDisabledDark = t4Dark;

  static const Color borderLight = bdLight;
  static const Color dividerLight = dvLight;
  static const Color borderDark = bdDark;
  static const Color dividerDark = dvDark;

  static const Color chartBlue = navy3;
  static const Color chartPurple = navy4;
  static const Color chartIce = navyBorder;
  static const List<Color> chartPalette = [chartBlue, chartPurple, chartIce];

  static const Color info = chartBlue;
  static const Color navyGradientEnd = navy4;
  static const Color primaryGreen = green;
  static const Color income = green;
  static const Color expense = red;
  static const Color warning = gold;
  static const Color error = red;
  static const Color onPrimary = textInverse;
  static const Color background = bgLight;
  static const Color surface = s1Light;
  static const Color surfaceElevated = s1Light;
  static const Color surfaceTint = s2Light;
  static const Color textPrimary = t1Light;
  static const Color textSecondary = t2Light;
  static const Color textTertiary = t3Light;
  static const Color textDisabled = t4Light;
  static const Color surfLight = s1Light;
  static const Color surfDark = s1Dark;
  static const Color darkPrimary = navyDark;
  static const Color darkGold = goldDark;
  static const Color darkGreen = greenDark;
  static const Color darkRed = redDark;
  static const Color darkBackground = bgDark;
  static const Color darkSurface = s1Dark;
  static const Color darkSurfaceElevated = s2Dark;
  static const Color darkTextPrimary = t1Dark;
  static const Color darkTextSecondary = t2Dark;
  static const Color darkTextTertiary = t3Dark;
  static const Color darkBorder = bdDark;
  static const Color darkDivider = dvDark;
  static const Color lightTextPrimary = t1Light;
  static const Color lightTextSecondary = t2Light;
  static const Color gray50 = dvLight;
  static const Color gray100 = dvLight;
  static const Color gray200 = bdLight;
  static const Color gray400 = t3Light;
  static const Color gray600 = t2Light;
  static const Color gray900 = t1Light;
}

/// Theme-resolved semantic colors — use via `context.colors`.
@immutable
final class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.primary,
    required this.primarySurface,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceTint,
    required this.surfaceTop,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.border,
    required this.divider,
    required this.gold,
    required this.goldSurface,
    required this.green,
    required this.greenSurface,
    required this.red,
    required this.redSurface,
    required this.orange,
    required this.orangeSurface,
  });

  final Color primary;
  final Color primarySurface;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceTint;
  final Color surfaceTop;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color border;
  final Color divider;
  final Color gold;
  final Color goldSurface;
  final Color green;
  final Color greenSurface;
  final Color red;
  final Color redSurface;
  final Color orange;
  final Color orangeSurface;

  static const AppColorScheme light = AppColorScheme(
    primary: AppColors.navy1,
    primarySurface: AppColors.navySurface,
    background: AppColors.bgLight,
    surface: AppColors.s1Light,
    surfaceElevated: AppColors.s1Light,
    surfaceTint: AppColors.s2Light,
    surfaceTop: AppColors.s1Light,
    textPrimary: AppColors.t1Light,
    textSecondary: AppColors.t2Light,
    textTertiary: AppColors.t3Light,
    textDisabled: AppColors.t4Light,
    border: AppColors.bdLight,
    divider: AppColors.dvLight,
    gold: AppColors.gold,
    goldSurface: AppColors.goldS,
    green: AppColors.green,
    greenSurface: AppColors.greenS,
    red: AppColors.red,
    redSurface: AppColors.redS,
    orange: AppColors.orange,
    orangeSurface: AppColors.orangeSurface,
  );

  static const AppColorScheme dark = AppColorScheme(
    primary: AppColors.navyDark,
    primarySurface: AppColors.navySurfaceDark,
    background: AppColors.bgDark,
    surface: AppColors.s1Dark,
    surfaceElevated: AppColors.s2Dark,
    surfaceTint: AppColors.s2Dark,
    surfaceTop: AppColors.s3Dark,
    textPrimary: AppColors.t1Dark,
    textSecondary: AppColors.t2Dark,
    textTertiary: AppColors.t3Dark,
    textDisabled: AppColors.t4Dark,
    border: AppColors.bdDark,
    divider: AppColors.dvDark,
    gold: AppColors.goldDark,
    goldSurface: AppColors.goldSurfaceDark,
    green: AppColors.greenDark,
    greenSurface: AppColors.greenSurfaceDark,
    red: AppColors.redDark,
    redSurface: AppColors.redSurfaceDark,
    orange: AppColors.orange,
    orangeSurface: AppColors.orangeSurface,
  );

  @override
  AppColorScheme copyWith({
    Color? primary,
    Color? primarySurface,
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceTint,
    Color? surfaceTop,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? border,
    Color? divider,
    Color? gold,
    Color? goldSurface,
    Color? green,
    Color? greenSurface,
    Color? red,
    Color? redSurface,
    Color? orange,
    Color? orangeSurface,
  }) {
    return AppColorScheme(
      primary: primary ?? this.primary,
      primarySurface: primarySurface ?? this.primarySurface,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceTint: surfaceTint ?? this.surfaceTint,
      surfaceTop: surfaceTop ?? this.surfaceTop,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      gold: gold ?? this.gold,
      goldSurface: goldSurface ?? this.goldSurface,
      green: green ?? this.green,
      greenSurface: greenSurface ?? this.greenSurface,
      red: red ?? this.red,
      redSurface: redSurface ?? this.redSurface,
      orange: orange ?? this.orange,
      orangeSurface: orangeSurface ?? this.orangeSurface,
    );
  }

  @override
  AppColorScheme lerp(ThemeExtension<AppColorScheme>? other, double t) {
    if (other is! AppColorScheme) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColorScheme(
      primary: l(primary, other.primary),
      primarySurface: l(primarySurface, other.primarySurface),
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceElevated: l(surfaceElevated, other.surfaceElevated),
      surfaceTint: l(surfaceTint, other.surfaceTint),
      surfaceTop: l(surfaceTop, other.surfaceTop),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textTertiary: l(textTertiary, other.textTertiary),
      textDisabled: l(textDisabled, other.textDisabled),
      border: l(border, other.border),
      divider: l(divider, other.divider),
      gold: l(gold, other.gold),
      goldSurface: l(goldSurface, other.goldSurface),
      green: l(green, other.green),
      greenSurface: l(greenSurface, other.greenSurface),
      red: l(red, other.red),
      redSurface: l(redSurface, other.redSurface),
      orange: l(orange, other.orange),
      orangeSurface: l(orangeSurface, other.orangeSurface),
    );
  }
}

extension AppColorSchemeContext on BuildContext {
  AppColorScheme get colors =>
      Theme.of(this).extension<AppColorScheme>() ?? AppColorScheme.light;
}
