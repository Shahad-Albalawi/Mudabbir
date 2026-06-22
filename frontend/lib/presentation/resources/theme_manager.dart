import 'package:flutter/services.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/app_colors.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:mudabbir/presentation/resources/styles_manager.dart';
import 'package:flutter/material.dart';

RoundedRectangleBorder _buttonShape() => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );

ButtonStyle _filledButtonStyle({
  required Color background,
  required Color foreground,
}) {
  return FilledButton.styleFrom(
    backgroundColor: background,
    foregroundColor: foreground,
    elevation: 0,
    shadowColor: Colors.transparent,
    minimumSize: AppTouch.buttonMinSize,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    shape: _buttonShape(),
    animationDuration: AppMotion.fast,
    textStyle: getMediumStyle(
      color: foreground,
      fontSize: 14,
      height: 1.1,
    ),
  );
}

TextTheme _higTextTheme({
  required Color primary,
  required Color secondary,
  required Color tertiary,
}) {
  return TextTheme(
    headlineLarge: getMediumStyle(
      color: primary,
      fontSize: AppTypographyScale.display,
      height: AppTypographyScale.displayHeight,
      letterSpacing: AppTypographyScale.displayTracking,
    ),
    headlineMedium: getMediumStyle(
      color: primary,
      fontSize: AppTypographyScale.display,
      height: AppTypographyScale.displayHeight,
      letterSpacing: AppTypographyScale.displayTracking,
    ),
    headlineSmall: getMediumStyle(
      color: primary,
      fontSize: AppTypographyScale.title,
      height: AppTypographyScale.titleHeight,
      letterSpacing: AppTypographyScale.titleTracking,
    ),
    titleLarge: getMediumStyle(
      color: primary,
      fontSize: AppTypographyScale.title,
      height: AppTypographyScale.titleHeight,
      letterSpacing: AppTypographyScale.titleTracking,
    ),
    titleMedium: getMediumStyle(
      color: primary,
      fontSize: AppTypographyScale.title,
      height: AppTypographyScale.titleHeight,
      letterSpacing: AppTypographyScale.titleTracking,
    ),
    titleSmall: getMediumStyle(
      color: primary,
      fontSize: AppTypographyScale.body,
      height: AppTypographyScale.bodyHeight,
    ),
    bodyLarge: getRegularStyle(
      color: primary,
      fontSize: AppTypographyScale.body,
      height: AppTypographyScale.bodyHeight,
      letterSpacing: AppTypographyScale.bodyTracking,
    ),
    bodyMedium: getRegularStyle(
      color: primary,
      fontSize: AppTypographyScale.body,
      height: AppTypographyScale.bodyHeight,
    ),
    bodySmall: getRegularStyle(
      color: secondary,
      fontSize: AppTypographyScale.caption,
      height: AppTypographyScale.bodyHeight,
    ),
    labelLarge: getMediumStyle(
      color: primary,
      fontSize: 14,
    ),
    labelMedium: getRegularStyle(
      color: secondary,
      fontSize: AppTypographyScale.caption,
      height: AppTypographyScale.captionHeight,
    ),
    labelSmall: getRegularStyle(
      color: tertiary,
      fontSize: AppTypographyScale.caption,
      height: AppTypographyScale.captionHeight,
    ),
  );
}

InputDecorationTheme _higInputTheme({
  required Color fill,
  required Color primary,
  required Color hint,
  required Color label,
  required Color error,
  required Color outline,
  double enabledBorderAlpha = 0.22,
}) {
  final radius = BorderRadius.circular(AppRadius.input);
  return InputDecorationTheme(
    filled: true,
    fillColor: fill,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: 16,
    ),
    constraints: const BoxConstraints(minHeight: 56),
    hintStyle: getRegularStyle(color: hint, fontSize: AppTypographyScale.body),
    labelStyle: getMediumStyle(color: label, fontSize: AppTypographyScale.caption),
    floatingLabelStyle: getMediumStyle(color: primary, fontSize: AppTypographyScale.caption),
    errorStyle: getRegularStyle(color: error, fontSize: AppTypographyScale.caption),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: outline.withValues(alpha: enabledBorderAlpha)),
      borderRadius: radius,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: primary, width: 1.5),
      borderRadius: radius,
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: error),
      borderRadius: radius,
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: error, width: 1.5),
      borderRadius: radius,
    ),
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: outline.withValues(alpha: 0.15)),
      borderRadius: radius,
    ),
  );
}

ThemeData getApplicationTheme() {
  return ThemeData(
    primaryColor: AppColors.primary,
    primaryColorLight: ColorManager.lightPrimary,
    primaryColorDark: ColorManager.darkPrimary,
    disabledColor: AppColors.textSecondary,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    useMaterial3: true,
    fontFamily: FontConstants.thmanyahFamily,
    fontFamilyFallback: FontConstants.fontFamilyFallback,
    scaffoldBackgroundColor: BrandPalette.canvasLight,

    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: BrandPalette.green50,
      onPrimaryContainer: BrandPalette.slate950,
      secondary: AppColors.secondary,
      onSecondary: BrandPalette.slate950,
      tertiary: BrandPalette.iosBlue,
      onTertiary: Colors.white,
      error: ColorManager.error,
      onError: Colors.white,
      surface: BrandPalette.canvasLight,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: BrandPalette.borderLight,
      outlineVariant: BrandPalette.inputFillLight,
      shadow: ColorManager.shadowLight,
      surfaceContainerHighest: BrandPalette.inputFillLight,
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),

    cardTheme: CardThemeData(
      color: BrandPalette.cardLight,
      shadowColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: BrandPalette.borderLight, width: 0.5),
      ),
      margin: const EdgeInsets.all(8),
    ),

    // iOS-style flat navigation bar (light)
    appBarTheme: AppBarTheme(
      backgroundColor: BrandPalette.canvasLight,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: getMediumStyle(
        fontSize: AppTypographyScale.title,
        color: AppColors.textPrimary,
        height: AppTypographyScale.titleHeight,
      ),
      iconTheme: IconThemeData(color: AppColors.primary),
      actionsIconTheme: IconThemeData(color: AppColors.primary),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _filledButtonStyle(
        background: ColorManager.primary,
        foreground: Colors.white,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorManager.primary,
        minimumSize: AppTouch.buttonMinSize,
        side: BorderSide(
          color: ColorManager.primary.withValues(alpha: 0.35),
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: _buttonShape(),
        animationDuration: AppMotion.fast,
        textStyle: getMediumStyle(
          color: ColorManager.primary,
          fontSize: 14,
          height: 1.1,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColorManager.primary,
        minimumSize: AppTouch.buttonMinSize,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        shape: _buttonShape(),
        animationDuration: AppMotion.fast,
        textStyle: getMediumStyle(
          color: ColorManager.primary,
          fontSize: 14,
          height: 1.1,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: _filledButtonStyle(
        background: AppColors.primary,
        foreground: Colors.white,
      ),
    ),

    textTheme: _higTextTheme(
      primary: AppColors.textPrimary,
      secondary: AppColors.textSecondary,
      tertiary: AppColors.textTertiary,
    ),

    inputDecorationTheme: _higInputTheme(
      fill: BrandPalette.inputFillLight,
      primary: ColorManager.primary,
      hint: AppColors.textTertiary,
      label: AppColors.textPrimary,
      error: ColorManager.error,
      outline: ColorManager.grey,
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: BrandPalette.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      titleTextStyle: getMediumStyle(
        color: ColorManager.darkGrey,
        fontSize: AppTypographyScale.title,
      ),
      contentTextStyle: getRegularStyle(
        color: AppColors.textPrimary.withValues(alpha: 0.9),
        fontSize: AppTypographyScale.body,
      ),
    ),

    // Bottom sheet theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: BrandPalette.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
    ),

    // Snackbar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: BrandPalette.cardLight,
      contentTextStyle: getRegularStyle(
        color: AppColors.textPrimary,
        fontSize: AppTypographyScale.caption,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: BrandPalette.borderLight, width: 0.5),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ColorManager.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return ColorManager.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ColorManager.primary;
        }
        return ColorManager.grey.withValues(alpha: 0.3);
      }),
    ),

    // Divider theme
    dividerTheme: DividerThemeData(
      color: BrandPalette.borderLight.withValues(alpha: 0.8),
      thickness: 0.5,
      space: 1,
    ),

    // List tile theme — 44pt minimum row height
    listTileTheme: ListTileThemeData(
      minVerticalPadding: 10,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: getMediumStyle(
        color: AppColors.textPrimary,
        fontSize: FontSize.s16,
      ),
      subtitleTextStyle: getRegularStyle(
        color: AppColors.textSecondary,
        fontSize: FontSize.s14,
      ),
    ),

    // Floating action button theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ColorManager.primary,
      foregroundColor: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: BrandPalette.brandPrimary.withValues(alpha: 0.08),
      selectedColor: ColorManager.primary,
      disabledColor: ColorManager.grey.withValues(alpha: 0.2),
      labelStyle: getMediumStyle(
        color: ColorManager.primary,
        fontSize: FontSize.s12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      pressElevation: 0,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: BrandPalette.canvasLight,
      elevation: 0,
      indicatorColor: ColorManager.primaryWithOpacity12,
      labelTextStyle: WidgetStateProperty.all(
        getMediumStyle(color: AppColors.textSecondary, fontSize: AppTypographyScale.caption),
      ),
    ),
  );
}

// --- Dark theme: soft elevated surfaces and comfortable contrast.
ThemeData getApplicationDarkTheme() {
  final scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: DarkAppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFF1E3A5F),
    onPrimaryContainer: DarkAppColors.textPrimary,
    secondary: DarkAppColors.secondary,
    onSecondary: DarkAppColors.textPrimary,
    tertiary: BrandPalette.iosBlueDark,
    onTertiary: DarkAppColors.textPrimary,
    error: const Color(0xFFE57373),
    onError: const Color(0xFF1A0A0A),
    surface: BrandPalette.canvasDark,
    onSurface: DarkAppColors.textPrimary,
    onSurfaceVariant: DarkAppColors.textSecondary,
    outline: DarkAppColors.outline,
    outlineVariant: DarkAppColors.outlineVariant,
    shadow: Colors.transparent,
    surfaceContainerHighest: BrandPalette.inputFillDark,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: FontConstants.thmanyahFamily,
    fontFamilyFallback: FontConstants.fontFamilyFallback,
    primaryColor: DarkAppColors.primary,
    scaffoldBackgroundColor: BrandPalette.canvasDark,
    colorScheme: scheme,
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    cardTheme: CardThemeData(
      color: BrandPalette.cardDark,
      shadowColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.45), width: 0.5),
      ),
      margin: const EdgeInsets.all(8),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: BrandPalette.canvasDark,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: getMediumStyle(
        fontSize: AppTypographyScale.title,
        color: scheme.onSurface,
        height: AppTypographyScale.titleHeight,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      actionsIconTheme: IconThemeData(color: scheme.onSurface),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: BrandPalette.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.35), width: 0.5),
      ),
      titleTextStyle: getMediumStyle(
        color: scheme.onSurface,
        fontSize: AppTypographyScale.title,
      ),
      contentTextStyle: getRegularStyle(
        color: scheme.onSurface.withValues(alpha: 0.9),
        fontSize: AppTypographyScale.body,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: BrandPalette.cardDark,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: _filledButtonStyle(
        background: scheme.primary,
        foreground: scheme.onPrimary,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _filledButtonStyle(
        background: scheme.primary,
        foreground: scheme.onPrimary,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        minimumSize: AppTouch.buttonMinSize,
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: _buttonShape(),
        animationDuration: AppMotion.fast,
        textStyle: getMediumStyle(
          color: scheme.onSurface,
          fontSize: 14,
          height: 1.1,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.onSurface,
        minimumSize: AppTouch.buttonMinSize,
        animationDuration: AppMotion.fast,
      ),
    ),
    inputDecorationTheme: _higInputTheme(
      fill: BrandPalette.inputFillDark,
      primary: scheme.primary,
      hint: DarkAppColors.textSecondary,
      label: scheme.onSurface,
      error: scheme.error,
      outline: scheme.outline,
      enabledBorderAlpha: 0.4,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return DarkAppColors.textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.primary;
        }
        return scheme.outline.withValues(alpha: 0.55);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: BorderSide(color: scheme.outline.withValues(alpha: 0.55)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.outline.withValues(alpha: 0.2),
      selectedColor: scheme.primary.withValues(alpha: 0.25),
      labelStyle: getMediumStyle(
        color: scheme.onSurface,
        fontSize: FontSize.s12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: DarkAppColors.surfaceElevated,
      contentTextStyle: getRegularStyle(
        color: DarkAppColors.textPrimary,
        fontSize: AppTypographyScale.caption,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.45), width: 0.5),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outline.withValues(alpha: 0.35),
      thickness: 0.5,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: DarkAppColors.surfaceElevated,
      elevation: 0,
      indicatorColor: scheme.primary.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return getMediumStyle(
          color: selected ? scheme.onSurface : scheme.textMuted,
          fontSize: AppTypographyScale.caption,
        );
      }),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.textMuted,
      textColor: scheme.onSurface,
      titleTextStyle: getMediumStyle(
        color: scheme.onSurface,
        fontSize: FontSize.s16,
      ),
      subtitleTextStyle: getRegularStyle(
        color: scheme.textMuted,
        fontSize: FontSize.s14,
      ),
    ),
    textTheme: _higTextTheme(
      primary: scheme.onSurface,
      secondary: DarkAppColors.textSecondary,
      tertiary: DarkAppColors.textTertiary,
    ),
  );
}
