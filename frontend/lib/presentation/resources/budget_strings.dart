import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Budget screen copy — prefer [AppStrings] for shared UI; card-specific here.
class BudgetStrings {
  BudgetStrings._();

  static bool get _e => AppStrings.isEnglishLocale;

  static String get offlineBanner => AppStrings.budgetOfflineBanner;
  static String get savedOffline => _e
      ? 'Saved locally. Will sync when online.'
      : 'حُفظ محلياً. سيُزامَن عند عودة الاتصال.';
  static String get loadFailed => _e
      ? 'Failed to load budgets.'
      : 'تعذر تحميل الميزانيات.';
  static String get syncFailed => _e
      ? 'Budget sync failed.'
      : 'فشلت مزامنة الميزانية.';

  static String get cardLabel => _e ? 'Budget' : 'الميزانية';
  static String get statusOverBudget =>
      _e ? 'Over budget' : 'تجاوزت الميزانية';
  static String get statusNearLimit => _e ? 'Near limit' : 'قريب من الحد';
  static String get statusOnTrack => _e ? 'On track' : 'ضمن الميزانية';

  static String remainingOf(double limit) => _e
      ? 'remaining of ${AppCurrency.format(limit)}'
      : 'متبقي من ${AppCurrency.format(limit)}';
}
