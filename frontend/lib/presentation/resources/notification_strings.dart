import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Copy for local notification titles and bodies.
class NotificationStrings {
  static bool get _e => AppStrings.isEnglishLocale;

  static String get budgetWarningTitle =>
      _e ? 'Budget almost used' : 'الميزانية على وشك النفاد';
  static String budgetWarningBody(double spent, double limit) => _e
      ? 'You spent ${spent.toStringAsFixed(0)} of ${limit.toStringAsFixed(0)} ﷼ (80%+).'
      : 'أنفقت ${spent.toStringAsFixed(0)} من ${limit.toStringAsFixed(0)} ﷼ (أكثر من 80%).';

  static String get budgetExceededTitle =>
      _e ? 'Budget exceeded' : 'تجاوزت الميزانية';
  static String budgetExceededBody(double spent, double limit) => _e
      ? 'Spending ${spent.toStringAsFixed(0)} ﷼ exceeds your ${limit.toStringAsFixed(0)} ﷼ limit.'
      : 'الإنفاق ${spent.toStringAsFixed(0)} ﷼ يتجاوز حد ${limit.toStringAsFixed(0)} ﷼.';
}
