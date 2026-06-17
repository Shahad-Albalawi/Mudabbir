import 'package:flutter/services.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/app_colors.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:mudabbir/presentation/resources/styles_manager.dart';
import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    primaryColor: AppColors.primary,
    primaryColorLight: ColorManager.lightPrimary,
    primaryColorDark: ColorManager.darkPrimary,
    disabledColor: AppColors.textSecondary,
    splashColor: ColorManager.primaryWithOpacity20,
    highlightColor: ColorManager.primaryWithOpacity08,
    useMaterial3: true,
    fontFamily: FontConstants.thmanyahFamily,
    fontFamilyFallback: FontConstants.fontFamilyFallback,
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFE3F0E8),
      onPrimaryContainer: const Color(0xFF1B4332),
      secondary: AppColors.secondary,
      onSecondary: const Color(0xFF0A2E1F),
      tertiary: AppColors.accent,
      onTertiary: const Color(0xFF2A2210),
      error: ColorManager.error,
      onError: Colors.white,
      surface: AppColors.card,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: ColorManager.grey,
      outlineVariant: ColorManager.grey300,
      shadow: ColorManager.shadowLight,
      surfaceContainerHighest: AppColors.background,
    ),

    cardTheme: CardThemeData(
      color: AppColors.card,
      shadowColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.15)),
      ),
      margin: const EdgeInsets.all(8),
    ),

    // Modern app bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.card,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: getBoldStyle(
        fontSize: FontSize.s20,
        color: AppColors.textPrimary,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      actionsIconTheme: IconThemeData(color: AppColors.textPrimary),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),

    // Enhanced button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorManager.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: getSemiBoldStyle(
          color: Colors.white,
          fontSize: FontSize.s16,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorManager.primary,
        side: BorderSide(
          color: ColorManager.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: getSemiBoldStyle(
          color: ColorManager.primary,
          fontSize: FontSize.s16,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColorManager.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: getMediumStyle(
          color: ColorManager.primary,
          fontSize: FontSize.s16,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // Enhanced text theme
    textTheme: TextTheme(
      // Headlines
      headlineLarge: getBoldStyle(
        color: AppColors.textPrimary,
        fontSize: FontSize.s20,
      ),
      headlineMedium: getBoldStyle(
        color: AppColors.textPrimary,
        fontSize: FontSize.s14,
      ),
      headlineSmall: getBoldStyle(
        color: AppColors.textPrimary,
        fontSize: FontSize.s16,
      ),

      // Titles
      titleLarge: getSemiBoldStyle(
        color: AppColors.textPrimary,
        fontSize: FontSize.s18,
      ),
      titleMedium: getMediumStyle(
        color: AppColors.textPrimary,
        fontSize: FontSize.s16,
      ),
      titleSmall: getMediumStyle(
        color: AppColors.textPrimary,
        fontSize: FontSize.s14,
      ),

      // Body
      bodyLarge: getRegularStyle(
        color: AppColors.textPrimary,
        fontSize: FontSize.s16,
      ),
      bodyMedium: getRegularStyle(
        color: AppColors.textPrimary.withValues(alpha: 0.9),
        fontSize: FontSize.s14,
      ),
      bodySmall: getRegularStyle(
        color: AppColors.textSecondary,
        fontSize: FontSize.s14,
      ),

      // Labels
      labelLarge: getMediumStyle(
        color: AppColors.textPrimary,
        fontSize: FontSize.s14,
      ),
      labelMedium: getMediumStyle(
        color: AppColors.textSecondary,
        fontSize: FontSize.s13,
      ),
      labelSmall: getMediumStyle(
        color: AppColors.textSecondary,
        fontSize: FontSize.s12,
      ),
    ),

    // Modern input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

      // Hint style
      hintStyle: getRegularStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.85),
        fontSize: FontSize.s14,
      ),

      // Label style
      labelStyle: getMediumStyle(
        color: AppColors.textPrimary.withValues(alpha: 0.88),
        fontSize: FontSize.s14,
      ),
      floatingLabelStyle: getMediumStyle(
        color: ColorManager.primary,
        fontSize: FontSize.s12,
      ),

      // Error style
      errorStyle: getRegularStyle(
        color: ColorManager.error,
        fontSize: FontSize.s12,
      ),

      // Border styles
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.grey.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),

      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorManager.primary, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),

      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorManager.error, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorManager.error, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),

      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.grey.withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.15)),
      ),
      titleTextStyle: getBoldStyle(
        color: ColorManager.darkGrey,
        fontSize: FontSize.s20,
      ),
      contentTextStyle: getRegularStyle(
        color: AppColors.textPrimary.withValues(alpha: 0.9),
        fontSize: FontSize.s14,
      ),
    ),

    // Bottom sheet theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    ),

    // Snackbar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ColorManager.darkGrey,
      contentTextStyle: getRegularStyle(
        color: Colors.white,
        fontSize: FontSize.s14,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
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
      color: ColorManager.grey.withValues(alpha: 0.2),
      thickness: 1,
      space: 1,
    ),

    // List tile theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
      backgroundColor: ColorManager.primary.withValues(alpha: 0.1),
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
      backgroundColor: AppColors.card,
      elevation: 0,
      indicatorColor: ColorManager.primaryWithOpacity12,
      labelTextStyle: WidgetStateProperty.all(
        getMediumStyle(color: AppColors.textSecondary, fontSize: FontSize.s12),
      ),
    ),
  );
}

// --- Dark theme: soft elevated surfaces and comfortable contrast.
ThemeData getApplicationDarkTheme() {
  final scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: DarkAppColors.primary,
    onPrimary: const Color(0xFF102018),
    primaryContainer: const Color(0xFF2A3A32),
    onPrimaryContainer: const Color(0xFFB8E6C8),
    secondary: DarkAppColors.secondary,
    onSecondary: DarkAppColors.textPrimary,
    tertiary: DarkAppColors.accent,
    onTertiary: const Color(0xFF1E1A12),
    error: const Color(0xFFE57373),
    onError: const Color(0xFF1A0A0A),
    surface: DarkAppColors.card,
    onSurface: DarkAppColors.textPrimary,
    onSurfaceVariant: DarkAppColors.textSecondary,
    outline: DarkAppColors.outline,
    outlineVariant: DarkAppColors.outlineVariant,
    shadow: Colors.transparent,
    surfaceContainerHighest: DarkAppColors.surfaceElevated,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: FontConstants.thmanyahFamily,
    fontFamilyFallback: FontConstants.fontFamilyFallback,
    primaryColor: DarkAppColors.primary,
    scaffoldBackgroundColor: DarkAppColors.background,
    colorScheme: scheme,
    splashColor: DarkAppColors.primary.withValues(alpha: 0.14),
    highlightColor: DarkAppColors.primary.withValues(alpha: 0.08),
    cardTheme: CardThemeData(
      color: scheme.surface,
      shadowColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
      ),
      margin: const EdgeInsets.all(8),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: DarkAppColors.surfaceElevated,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: getBoldStyle(
        fontSize: FontSize.s20,
        color: scheme.onSurface,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      actionsIconTheme: IconThemeData(color: scheme.onSurface),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.25)),
      ),
      titleTextStyle: getBoldStyle(
        color: scheme.onSurface,
        fontSize: FontSize.s20,
      ),
      contentTextStyle: getRegularStyle(
        color: scheme.onSurface.withValues(alpha: 0.9),
        fontSize: FontSize.s14,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DarkAppColors.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: getSemiBoldStyle(
          color: scheme.onPrimary,
          fontSize: FontSize.s16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.65)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: scheme.primary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: getRegularStyle(
        color: scheme.onSurface.withValues(alpha: 0.72),
        fontSize: FontSize.s14,
      ),
      labelStyle: getMediumStyle(
        color: scheme.onSurface.withValues(alpha: 0.88),
        fontSize: FontSize.s14,
      ),
      floatingLabelStyle: getMediumStyle(
        color: scheme.primary,
        fontSize: FontSize.s12,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.error.withValues(alpha: 0.85)),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      contentTextStyle: getRegularStyle(
        color: scheme.onSurface,
        fontSize: FontSize.s14,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
          fontSize: FontSize.s13,
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
    textTheme: TextTheme(
      headlineLarge: getBoldStyle(
        color: scheme.onSurface,
        fontSize: FontSize.s20,
      ),
      headlineMedium: getBoldStyle(
        color: scheme.onSurface,
        fontSize: FontSize.s14,
      ),
      headlineSmall: getBoldStyle(
        color: scheme.onSurface,
        fontSize: FontSize.s16,
      ),
      titleLarge: getSemiBoldStyle(
        color: scheme.onSurface,
        fontSize: FontSize.s18,
      ),
      titleMedium: getMediumStyle(
        color: scheme.onSurface,
        fontSize: FontSize.s16,
      ),
      titleSmall: getMediumStyle(
        color: scheme.onSurface.withValues(alpha: 0.88),
        fontSize: FontSize.s14,
      ),
      bodyLarge: getRegularStyle(
        color: scheme.onSurface,
        fontSize: FontSize.s16,
      ),
      bodyMedium: getRegularStyle(
        color: scheme.onSurface.withValues(alpha: 0.92),
        fontSize: FontSize.s14,
      ),
      bodySmall: getRegularStyle(
        color: scheme.textMuted,
        fontSize: FontSize.s14,
      ),
      labelLarge: getMediumStyle(
        color: scheme.onSurface,
        fontSize: FontSize.s14,
      ),
      labelMedium: getMediumStyle(
        color: scheme.textMuted,
        fontSize: FontSize.s13,
      ),
      labelSmall: getMediumStyle(
        color: scheme.textMuted,
        fontSize: FontSize.s12,
      ),
    ),
  );
}
