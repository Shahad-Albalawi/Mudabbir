import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';

void main() {
  test('Thmanyah is the default app font', () {
    expect(FontConstants.fontFamily, FontConstants.thmanyahFamily);
  });

  test('AppCurrency formats Arabic riyal symbol', () {
    final formatted = AppCurrency.format(1000, english: false);
    expect(formatted, contains('\uFDFC'));
  });
}
