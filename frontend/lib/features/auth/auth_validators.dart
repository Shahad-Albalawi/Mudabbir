import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Auth form validators — localized via [AppStrings].
abstract final class AuthValidators {
  AuthValidators._();

  static final RegExp _emailPattern = RegExp(
    r'^[\w.+-]+@[\w.-]+\.[a-zA-Z]{2,}$',
  );

  static String? validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return AppStrings.validationEmailRequired;
    if (!_emailPattern.hasMatch(trimmed)) {
      return AppStrings.authEmailFormatInvalid;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) return AppStrings.validationPasswordRequired;
    if (value!.length < 8) return AppStrings.validationPasswordMinLength;
    return null;
  }

  static String? validateName(String? value) {
    if (value?.trim().isEmpty ?? true) return AppStrings.authFullNameRequired;
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value?.isEmpty ?? true) return AppStrings.authConfirmPasswordRequired;
    if (value != password) return AppStrings.validationPasswordMismatch;
    return null;
  }
}

String? mergeFieldError(String? localError, String? serverError) {
  if (serverError != null && serverError.isNotEmpty) return serverError;
  return localError;
}
