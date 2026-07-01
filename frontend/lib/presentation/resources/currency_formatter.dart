import 'package:intl/intl.dart';
import 'package:mudabbir/presentation/resources/saudi_riyal_font.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Unified Saudi Riyal formatting for the whole app.
class AppCurrency {
  AppCurrency._();

  /// @deprecated Use [SaudiRiyalFont.symbol] (U+20C1).
  static const String riyalSymbol = SaudiRiyalFont.symbol;

  static bool get _en => AppStrings.isEnglishLocale;

  /// Grouped number only (no currency symbol).
  static String formatNumber(
    num value, {
    int decimals = 0,
    bool? english,
  }) {
    final useEn = english ?? _en;
    final pattern = NumberFormat.decimalPattern(useEn ? 'en' : 'ar');
    pattern.minimumFractionDigits = decimals;
    pattern.maximumFractionDigits = decimals;
    return pattern.format(value);
  }

  /// Plain-text amount with symbol or fallback label (chat, PDF strings, etc.).
  static String format(
    num value, {
    int decimals = 0,
    bool? english,
  }) {
    final useEn = english ?? _en;
    final grouped = formatNumber(value, decimals: decimals, english: useEn);

    if (!SaudiRiyalFont.isAvailable) {
      final label = useEn
          ? SaudiRiyalFont.fallbackLabelEn
          : SaudiRiyalFont.fallbackLabelAr;
      return '$grouped $label';
    }

    if (useEn) {
      return '$grouped ${SaudiRiyalFont.symbol}';
    }
    return '$grouped ${SaudiRiyalFont.symbol}';
  }

  static String formatCompact(num value) => format(value, decimals: 0);

  static String formatDetailed(num value) => format(value, decimals: 2);
}
