import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Statistics and analysis screen copy.
class StatisticsStrings {
  StatisticsStrings._();

  static bool get _e => AppStrings.isEnglishLocale;

  static String get loadFailed => _e
      ? 'Could not load statistics. Pull to refresh or tap retry.'
      : 'تعذر تحميل الإحصائيات. اسحب للتحديث أو اضغط إعادة المحاولة.';

  static String get analysisLoadFailed => _e
      ? 'Could not build your financial analysis.'
      : 'تعذر إنشاء التحليل المالي.';

  static String get homeLoadFailed => _e
      ? 'Could not load your financial summary.'
      : 'تعذر تحميل ملخصك المالي.';

  static String get emptyTitle => _e
      ? 'No financial data yet'
      : 'لا توجد بيانات مالية بعد';

  static String get emptySubtitle => _e
      ? 'Add income or expenses to see statistics and insights.'
      : 'أضف دخلاً أو مصروفات لعرض الإحصائيات والرؤى.';
}
