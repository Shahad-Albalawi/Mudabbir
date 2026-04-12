import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Maps canonical English [ApiException.message] values to Arabic for AR locale.
class ApiExceptionLocalizations {
  ApiExceptionLocalizations._();

  static final Map<String, String> _ar = {
    'Connection timed out. Check your internet and try again.':
        'انتهت مهلة الاتصال. تحقق من الإنترنت والمحاولة مرة أخرى.',
    'Request was cancelled.': 'تم إلغاء الطلب.',
    'No internet connection. Check your network and try again.':
        'لا يوجد اتصال بالإنترنت. تحقق من الشبكة والمحاولة مرة أخرى.',
    'Unable to reach the finance server. Check internet or try again later.':
        'تعذر الوصول لخادم التحديات. تحقق من الإنترنت أو أعد المحاولة لاحقاً.',
    'The finance server is temporarily unavailable. Please try again later.':
        'خادم التحديات غير متاح مؤقتاً. حاول مرة أخرى لاحقاً.',
    'Security certificate error. Please try again later.':
        'خطأ في شهادة الأمان. يرجى المحاولة لاحقاً.',
    'Something went wrong. Please try again.':
        'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
    'Bad request. Please check your input.':
        'طلب غير صحيح. يرجى التحقق من البيانات المدخلة.',
    'Please sign in again.': 'يجب تسجيل الدخول مرة أخرى.',
    'Access denied.': 'لا يوجد صلاحية للوصول.',
    'Resource not found.': 'المورد المطلوب غير موجود.',
    'Invalid input. Please correct and try again.':
        'البيانات المدخلة غير صحيحة. يرجى التصحيح.',
    'The server had an error. Please try again later.':
        'حدث خطأ في الخادم. جارٍ العمل على إصلاحه. يرجى المحاولة لاحقاً.',
    'Failed to load challenges': 'فشل تحميل التحديات',
    'Failed to load challenge': 'فشل تحميل التحدي',
    'Failed to create challenge': 'فشل إنشاء التحدي',
    'Failed to update challenge': 'فشل تحديث التحدي',
    'Failed to delete challenge': 'فشل حذف التحدي',
    'Failed to invite user': 'فشل دعوة المستخدم',
    'Failed to remove participant': 'فشل إزالة المشارك',
    'Failed to update status': 'فشل تحديث الحالة',
    'Failed to respond to invitation': 'فشل الرد على الدعوة',
    'Failed to load pending invitations': 'فشل تحميل الدعوات المعلقة',
    'Email is required to send an invitation.':
        'البريد الإلكتروني مطلوب لإرسال الدعوة.',
    'Please enter a valid email address.': 'الرجاء إدخال بريد إلكتروني صحيح.',
    'Unexpected server response while sending the invitation.':
        'استجابة الخادم غير متوقعة أثناء إرسال الدعوة.',
    'Connection timeout. Please check your internet connection.':
        'انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت.',
    'Request was cancelled': 'تم إلغاء الطلب',
    'No internet connection. Please check your network.':
        'لا يوجد اتصال بالإنترنت. تحقق من الشبكة.',
    'Security certificate error': 'خطأ في شهادة الأمان',
    'Bad request': 'طلب غير صحيح',
    'Unauthorized. Please login again.': 'يجب تسجيل الدخول مرة أخرى.',
    'Access denied': 'تم رفض الوصول',
    'Resource not found': 'المورد غير موجود',
    'Validation failed': 'فشل التحقق من البيانات',
    'Validation error': 'خطأ في البيانات المدخلة',
    'Server error. Please try again later.':
        'خطأ في الخادم. يرجى المحاولة لاحقاً.',
    'An unexpected error occurred': 'حدث خطأ غير متوقع',
  };

  /// User-facing text for current app language.
  static String display(String message) {
    if (AppStrings.isEnglishLocale) return message;
    return _ar[message] ?? message;
  }
}
