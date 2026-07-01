import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mudabbir/core/theme/app_colors.dart';
import 'package:mudabbir/core/theme/app_dimensions.dart' as dim;
import 'package:mudabbir/core/theme/app_typography.dart';

export 'package:mudabbir/core/theme/app_colors.dart';
export 'package:mudabbir/core/theme/app_dimensions.dart';
export 'package:mudabbir/core/theme/app_text_styles.dart';
export 'package:mudabbir/core/theme/app_typography.dart';

/// مدبّر — Light / Dark [ThemeData] with Eight font.
abstract final class AppTheme {
  AppTheme._();

  // ── Corner radii ──
  static const double radiusCard = 20;
  static const double radiusButton = 14;
  static const double radiusChip = 100;
  static const double radiusSheet = 26;
  static const double radiusIcon = 14;
  static const double radiusAppIcon = 26;

  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? AppColors.surface1,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration navyGradient() => BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.navy, AppColors.navyMedium, AppColors.navyLight],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static const TextDirection defaultTextDirection = TextDirection.rtl;

  static ThemeData get light => lightTheme();
  static ThemeData get dark => darkTheme();

  static ThemeData lightTheme() => _build(
        brightness: Brightness.light,
        colors: AppColorScheme.light,
        overlayStyle: SystemUiOverlayStyle.dark,
      );

  static ThemeData darkTheme() => _build(
        brightness: Brightness.dark,
        colors: AppColorScheme.dark,
        overlayStyle: SystemUiOverlayStyle.light,
      );

  static Widget rtlScope({
    required Widget child,
    TextDirection direction = defaultTextDirection,
  }) {
    return Directionality(textDirection: direction, child: child);
  }

  static ThemeData _build({
    required Brightness brightness,
    required AppColorScheme colors,
    required SystemUiOverlayStyle overlayStyle,
  }) {
    final isDark = brightness == Brightness.dark;
    final baseText = AppTypography.themed(
      primary: colors.textPrimary,
      secondary: colors.textSecondary,
    );

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: colors.primary,
            onPrimary: AppColors.textInverse,
            primaryContainer: colors.primarySurface,
            secondary: colors.green,
            onSecondary: AppColors.textInverse,
            tertiary: colors.gold,
            error: colors.red,
            onError: AppColors.textInverse,
            surface: colors.surface,
            onSurface: colors.textPrimary,
            onSurfaceVariant: colors.textSecondary,
            outline: colors.border,
            outlineVariant: colors.divider,
            surfaceTint: AppColors.transparent,
          )
        : ColorScheme.light(
            primary: AppColors.navy1,
            onPrimary: AppColors.textInverse,
            primaryContainer: AppColors.navySurface,
            secondary: colors.green,
            onSecondary: AppColors.textInverse,
            tertiary: colors.gold,
            error: colors.red,
            onError: AppColors.textInverse,
            surface: AppColors.s1Light,
            onSurface: colors.textPrimary,
            onSurfaceVariant: colors.textSecondary,
            outline: colors.border,
            outlineVariant: colors.divider,
            surfaceTint: AppColors.transparent,
          );

    final chartColors = isDark
        ? const AppChartColors(
            segment1: AppColors.navyDark,
            segment2: Color(0xFF6B93ED),
            segment3: Color(0xFF8FAEF2),
            positive: AppColors.greenDark,
          )
        : const AppChartColors();

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusButton),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primary,
      colorScheme: colorScheme,
      textTheme: baseText,
      splashFactory: NoSplash.splashFactory,
      splashColor: AppColors.transparent,
      highlightColor: AppColors.transparent,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: [
        colors,
        chartColors,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: AppColors.transparent,
        surfaceTintColor: AppColors.transparent,
        centerTitle: false,
        titleTextStyle: baseText.headlineMedium?.copyWith(
          color: colors.textPrimary,
        ),
        iconTheme: IconThemeData(color: colors.primary),
        actionsIconTheme: IconThemeData(color: colors.primary),
        systemOverlayStyle: overlayStyle,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textTertiary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: baseText.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: baseText.labelMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        elevation: 0,
        indicatorColor: colors.primary.withValues(alpha: isDark ? 0.22 : 0.10),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return baseText.labelMedium?.copyWith(
            color: selected ? colors.primary : colors.textTertiary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colors.primary : colors.textTertiary,
            size: dim.IconSize.lg,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(
            color: colors.border,
            width: 0.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          minimumSize: const Size(double.infinity, dim.Spacing.buttonHeight),
          shape: buttonShape,
          textStyle: baseText.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          minimumSize: const Size(double.infinity, dim.Spacing.buttonHeight),
          shape: buttonShape,
          textStyle: baseText.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(0, dim.Spacing.buttonHeight),
          side: BorderSide(color: colors.primary.withValues(alpha: 0.35)),
          shape: buttonShape,
          textStyle: baseText.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(0, dim.Spacing.buttonHeight),
          textStyle: baseText.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? colors.surfaceElevated : colors.surfaceTint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: dim.Spacing.lg,
          vertical: 14,
        ),
        hintStyle: baseText.bodyMedium?.copyWith(color: colors.textTertiary),
        labelStyle: baseText.bodySmall?.copyWith(color: colors.textSecondary),
        errorStyle: baseText.bodySmall?.copyWith(color: colors.red),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: colors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: colors.red, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 0.5,
        space: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? colors.surfaceElevated : colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(color: colors.border, width: 0.5),
        ),
        titleTextStyle: baseText.titleLarge,
        contentTextStyle: baseText.bodyLarge,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? colors.surfaceElevated : colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(radiusSheet),
          ),
          side: BorderSide(color: colors.border, width: 0.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? colors.surfaceElevated : colors.surface,
        contentTextStyle: baseText.bodyMedium,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(color: colors.border, width: 0.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: AppColors.textInverse,
        elevation: 0,
        shape: const CircleBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceTint,
        selectedColor: colors.primary.withValues(alpha: isDark ? 0.22 : 0.12),
        labelStyle: baseText.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: dim.Spacing.md,
          vertical: dim.Spacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusChip),
          side: BorderSide(color: colors.border),
        ),
        elevation: 0,
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 10,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: dim.Spacing.lg,
          vertical: dim.Spacing.sm,
        ),
        titleTextStyle: baseText.bodyLarge,
        subtitleTextStyle: baseText.bodySmall,
        iconColor: colors.textSecondary,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.primary;
          return AppColors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textInverse),
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dim.AppRadius.xs / 2),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.textInverse;
          }
          return colors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.primary;
          return colors.border;
        }),
      ),
    );
  }
}

/// Chart segment colors for fl_chart widgets.
final class AppChartColors extends ThemeExtension<AppChartColors> {
  const AppChartColors({
    this.segment1 = AppColors.navy3,
    this.segment2 = AppColors.navy4,
    this.segment3 = AppColors.navyBorder,
    this.positive = AppColors.green,
  });

  final Color segment1;
  final Color segment2;
  final Color segment3;
  final Color positive;

  List<Color> get segments => [segment1, segment2, segment3];

  @override
  AppChartColors copyWith({
    Color? segment1,
    Color? segment2,
    Color? segment3,
    Color? positive,
  }) {
    return AppChartColors(
      segment1: segment1 ?? this.segment1,
      segment2: segment2 ?? this.segment2,
      segment3: segment3 ?? this.segment3,
      positive: positive ?? this.positive,
    );
  }

  @override
  AppChartColors lerp(ThemeExtension<AppChartColors>? other, double t) {
    if (other is! AppChartColors) return this;
    return AppChartColors(
      segment1: Color.lerp(segment1, other.segment1, t)!,
      segment2: Color.lerp(segment2, other.segment2, t)!,
      segment3: Color.lerp(segment3, other.segment3, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
    );
  }
}

extension AppChartColorsContext on BuildContext {
  AppChartColors get chartColors =>
      Theme.of(this).extension<AppChartColors>() ?? const AppChartColors();
}
