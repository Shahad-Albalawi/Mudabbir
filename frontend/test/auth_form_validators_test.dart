import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/presentation/auth/auth_form_validators.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

void main() {
  group('AuthFormValidators', () {
    test('email rejects empty and invalid addresses', () {
      expect(AuthFormValidators.email(null), AppStrings.validationEmailRequired);
      expect(AuthFormValidators.email(''), AppStrings.validationEmailRequired);
      expect(AuthFormValidators.email('bad'), AppStrings.validationEmailInvalid);
      expect(AuthFormValidators.email('user@example.com'), isNull);
    });

    test('password enforces minimum length', () {
      expect(AuthFormValidators.password(null), AppStrings.validationPasswordRequired);
      expect(AuthFormValidators.password('1234567'), AppStrings.validationPasswordMinLength);
      expect(AuthFormValidators.password('12345678'), isNull);
    });

    test('firstName requires non-empty value', () {
      expect(AuthFormValidators.firstName(''), AppStrings.validationFirstNameRequired);
      expect(AuthFormValidators.firstName('شهد'), isNull);
    });

    test('confirmPassword matches original password', () {
      expect(
        AuthFormValidators.confirmPassword('abc', 'xyz'),
        AppStrings.validationPasswordMismatch,
      );
      expect(AuthFormValidators.confirmPassword('secret', 'secret'), isNull);
    });
  });
}
