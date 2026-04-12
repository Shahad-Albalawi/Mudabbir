import 'package:mudabbir/persentation/resources/strings_manager.dart';

/// Bilingual user-facing messages for [Failure] and network errors.
class NetworkUserMessages {
  NetworkUserMessages._();

  static bool get _en => AppStrings.isEnglishLocale;

  static String get network =>
      _en ? 'Cannot reach the server. Check the internet and try again.'
          : 'تعذر الاتصال بالخادم. تحقق من الإنترنت ثم أعد المحاولة.';

  static String get timeout => _en
      ? 'The connection timed out. Check the network or try again shortly.'
      : 'انتهت مهلة الاتصال. تحقق من الشبكة أو حاول بعد قليل.';

  static String get parsing => _en
      ? 'Unexpected response from the server. Update the app or try later.'
      : 'استجابة غير متوقعة من الخادم. حدّث التطبيق أو حاول لاحقاً.';

  static String get unknown =>
      _en ? 'Something went wrong. Please try again.'
          : 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  static String serverPolish(String raw, int statusCode) {
    final m = raw.trim();
    if (m.isEmpty ||
        m == 'Server error' ||
        m.toLowerCase() == '<none>') {
      return shortStatus(statusCode);
    }
    if (_en) {
      const known = {
        'The given data was invalid.':
            'Please check your input and try again.',
        'Unauthenticated.': 'Your session expired or you are not signed in.',
        'Unauthenticated': 'Your session expired or you are not signed in.',
        'These credentials do not match our records.':
            'Email or password is incorrect.',
      };
      return known[m] ?? m;
    }
    const knownAr = {
      'The given data was invalid.':
          'تحقق من صحة البيانات المدخلة ثم حاول مرة أخرى.',
      'Unauthenticated.': 'انتهت الجلسة أو لم يتم تسجيل الدخول.',
      'Unauthenticated': 'انتهت الجلسة أو لم يتم تسجيل الدخول.',
      'These credentials do not match our records.':
          'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
    };
    return knownAr[m] ?? m;
  }

  static String shortStatus(int code) {
    if (_en) {
      if (code == 401) return 'Email or password is incorrect.';
      if (code == 422) return 'The submitted data is not valid.';
      if (code >= 500) return 'The server is temporarily unavailable.';
      return 'Could not complete the request. Try again.';
    }
    if (code == 401) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    }
    if (code == 422) {
      return 'البيانات المدخلة غير صالحة.';
    }
    if (code >= 500) {
      return 'الخادم يواجه مشكلة مؤقتة.';
    }
    return 'تعذر إكمال الطلب. حاول مرة أخرى.';
  }
}
