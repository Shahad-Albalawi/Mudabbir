import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';

void main() {
  test('IBM Plex Sans Arabic is the default app font', () {
    expect(FontConstants.fontFamily, 'IBMPlexSansArabic');
  });

  test('AppCurrency formats Saudi Riyal symbol U+20C1', () {
    final formatted = AppCurrency.format(1000, english: false);
    expect(formatted, contains('\u20C1'));
  });
}
