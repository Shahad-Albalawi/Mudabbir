/// Auth form validators — Arabic messages per design spec.
abstract final class AuthValidators {
  AuthValidators._();

  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'البريد الإلكتروني مطلوب';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
      return 'صيغة البريد غير صحيحة';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) return 'كلمة المرور مطلوبة';
    if (value!.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    return null;
  }

  static String? validateName(String? value) {
    if (value?.trim().isEmpty ?? true) return 'الاسم الكامل مطلوب';
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value?.isEmpty ?? true) return 'تأكيد كلمة المرور مطلوب';
    if (value != password) return 'كلمتا المرور غير متطابقتين';
    return null;
  }
}
