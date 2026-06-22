import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Shared email/password validators for login and register forms.
abstract final class AuthFormValidators {
  static final _emailPattern = RegExp(r'\S+@\S+\.\S+');
  static const int _maxFieldLength = 255;

  static String get _nameTooLong => AppStrings.isEnglishLocale
      ? 'Name is too long (max 255 characters).'
      : 'الاسم طويل جداً (الحد الأقصى 255 حرف).';

  static String get _emailTooLong => AppStrings.isEnglishLocale
      ? 'Email is too long (max 255 characters).'
      : 'البريد الإلكتروني طويل جداً (الحد الأقصى 255 حرف).';

  static String? firstName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationFirstNameRequired;
    }
    if (value.trim().length > _maxFieldLength) {
      return _nameTooLong;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationEmailRequired;
    }
    if (value.length > _maxFieldLength) {
      return _emailTooLong;
    }
    if (!_emailPattern.hasMatch(value)) {
      return AppStrings.validationEmailInvalid;
    }
    return null;
  }

  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationPasswordRequired;
    }
    if (value.length < minLength) {
      return AppStrings.validationPasswordMinLength;
    }
    if (value.length > _maxFieldLength) {
      return AppStrings.isEnglishLocale
          ? 'Password is too long.'
          : 'كلمة المرور طويلة جداً.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value != password) {
      return AppStrings.validationPasswordMismatch;
    }
    return null;
  }
}
