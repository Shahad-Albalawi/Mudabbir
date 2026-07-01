import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/presentation/auth/auth_screen_widgets.dart';

void main() {
  group('Auth screen validators', () {
    test('validateAuthEmail rejects empty and invalid addresses', () {
      expect(validateAuthEmail(null), isNotNull);
      expect(validateAuthEmail(''), isNotNull);
      expect(validateAuthEmail('bad'), isNotNull);
      expect(validateAuthEmail('user@example.com'), isNull);
    });

    test('validateAuthPassword enforces minimum length', () {
      expect(validateAuthPassword(null), isNotNull);
      expect(validateAuthPassword('1234567'), isNotNull);
      expect(validateAuthPassword('12345678'), isNull);
    });

    test('validateAuthName requires non-empty value', () {
      expect(validateAuthName(''), isNotNull);
      expect(validateAuthName('شهد'), isNull);
    });

    test('validateAuthConfirmPassword matches original password', () {
      expect(validateAuthConfirmPassword('abc', 'xyz'), isNotNull);
      expect(validateAuthConfirmPassword('secret', 'secret'), isNull);
    });
  });
}
