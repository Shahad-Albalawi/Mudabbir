import 'package:intl/intl.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Unified Saudi Riyal formatting for the whole app.
class AppCurrency {
  AppCurrency._();

  /// Official Riyal sign (U+FDFC). Used app-wide instead of "ر.س".
  static const String riyalSymbol = '\uFDFC';

  static bool get _en => AppStrings.isEnglishLocale;

  static String format(
    num value, {
    int decimals = 0,
    bool? english,
  }) {
    final useEn = english ?? _en;
    final pattern = NumberFormat.decimalPattern(useEn ? 'en' : 'ar');
    pattern.minimumFractionDigits = decimals;
    pattern.maximumFractionDigits = decimals;
    final grouped = pattern.format(value);

    if (useEn) {
      return '$grouped SAR';
    }
    return '$grouped $riyalSymbol';
  }

  static String formatCompact(num value) => format(value, decimals: 0);

  static String formatDetailed(num value) => format(value, decimals: 2);
}
