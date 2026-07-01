import 'package:flutter/services.dart';

/// Official Saudi Riyal symbol font (U+20C1) — bundled locally.
///
/// Source: [@emran-alhaddad/saudi-riyal-font](https://github.com/emran-alhaddad/Saudi-Riyal-Font) (OFL-1.1).
abstract final class SaudiRiyalFont {
  SaudiRiyalFont._();

  static const String family = 'SaudiRiyal';
  static const String regularAsset =
      'assets/fonts/saudi_riyal/SaudiRiyal-Regular.ttf';
  static const String boldAsset = 'assets/fonts/saudi_riyal/SaudiRiyal-Bold.ttf';

  /// Unicode 17 — Saudi Riyal sign (February 2025).
  static const String symbol = '\u20C1';

  static const String fallbackLabelAr = 'ريال';
  static const String fallbackLabelEn = 'SAR';

  static bool? _available;

  static bool get isAvailable => _available ?? true;

  /// Probes bundled font assets; sets [isAvailable] for fallback text.
  static Future<void> probe() async {
    try {
      await rootBundle.load(regularAsset);
      await rootBundle.load(boldAsset);
      _available = true;
    } catch (_) {
      _available = false;
    }
  }
}
