import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Bilingual strings for savings goals — popup copy delegates to [AppStrings].
class GoalStrings {
  GoalStrings._();

  static String formatAmount(double value) => AppCurrency.format(value);

  static String get createTitle => AppStrings.goalPopupCreateTitle;
  static String get createSubtitle => AppStrings.goalPopupCreateSubtitle;
  static String get goalName =>
      AppStrings.isEnglishLocale ? 'Goal name' : 'اسم الهدف';
  static String get goalNameHint => AppStrings.goalNameHint;
  static String get targetAmount => AppStrings.goalTargetAmountLabel;
  static String get currentAmount => AppStrings.goalCurrentAmountLabel;
  static String get goalType => AppStrings.goalTypeLabel;
  static String get goalPeriod => AppStrings.goalPeriodLabel;
  static String get startDate => AppStrings.fieldStartDate;
  static String get endDate => AppStrings.fieldEndDate;
  static String get pickImage => AppStrings.goalPickImage;
  static String get changeImage =>
      AppStrings.isEnglishLocale ? 'Change photo' : 'تغيير الصورة';
  static String get cancel => AppStrings.txCancel;
  static String get createButton => AppStrings.goalPopupCreateTitle;
  static String get nameRequired => AppStrings.goalNameRequired;
  static String get targetRequired => AppStrings.goalTargetRequired;
  static String get invalidAmount => AppStrings.goalsInvalidAmount;
  static String get typeRequired => AppStrings.goalTypeRequired;
  static String get startRequired => AppStrings.goalStartRequired;
  static String get endRequired => AppStrings.goalEndRequired;
  static String get endAfterStart => AppStrings.goalEndAfterStart;
  static String get createdSuccess => AppStrings.goalCreateSuccess;
  static String get createFailed => AppStrings.goalCreateFailed;
  static String get editTitle => AppStrings.goalEditTitle;
  static String get editSubtitle => AppStrings.goalEditSubtitle;
  static String get saveButton => AppStrings.goalSaveChanges;
  static String get updatedSuccess => AppStrings.goalUpdatedSuccess;
  static String get offlineBanner => AppStrings.goalOfflineBanner;
  static String get loadFailed => AppStrings.isEnglishLocale
      ? 'Failed to load goals.'
      : 'تعذر تحميل الأهداف.';
  static String get syncFailed => AppStrings.isEnglishLocale
      ? 'Goal sync failed.'
      : 'فشلت مزامنة الأهداف.';

  static String get deadlineLabel => AppStrings.goalPeriodLabel;
  static String get projectedLabel =>
      AppStrings.isEnglishLocale ? 'Expected completion' : 'تاريخ الوصول المتوقع';
  static String get remainingLabel =>
      AppStrings.isEnglishLocale ? 'Remaining' : 'المتبقي';
  static String get contributeHint =>
      AppStrings.isEnglishLocale ? 'Tap to add contribution' : 'اضغط لإضافة مساهمة';
  static String get monthlyNeeded =>
      AppStrings.isEnglishLocale ? 'Needed monthly to meet deadline' : 'المطلوب شهرياً للوصول للموعد';
  static String get avgMonthly =>
      AppStrings.isEnglishLocale ? 'Your avg. monthly contributions' : 'متوسط مساهماتك الشهرية';

  static String statusLabel(GoalTrackStatus status) {
    switch (status) {
      case GoalTrackStatus.onTrack:
        return AppStrings.isEnglishLocale ? 'On track' : 'على المسار';
      case GoalTrackStatus.behind:
        return AppStrings.isEnglishLocale ? 'Behind schedule' : 'متأخر عن الجدول';
      case GoalTrackStatus.overdue:
        return AppStrings.isEnglishLocale ? 'Past deadline' : 'تجاوز الموعد';
      case GoalTrackStatus.completed:
        return AppStrings.isEnglishLocale ? 'Completed' : 'مكتمل';
      case GoalTrackStatus.noData:
        return AppStrings.isEnglishLocale ? 'Not started' : 'لم تبدأ بعد';
    }
  }

  static List<String> get goalTypes => AppStrings.isEnglishLocale
      ? const ['Saving', 'Investment', 'Debt', 'Other']
      : const ['ادخار', 'استثمار', 'دين', 'أخرى'];

  /// Ensures edit dialogs never pass unknown DB values to [DropdownButton].
  static String resolveGoalTypeForDropdown(String? raw) {
    final types = goalTypes;
    if (raw != null && types.contains(raw)) return raw;
    return types.last;
  }

  static String formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  static String projectedDateText(DateTime? date) {
    if (date == null) {
      return AppStrings.isEnglishLocale ? 'Not enough data' : 'بيانات غير كافية';
    }
    return formatDate(date);
  }

  static String typeLabel(String raw) {
    if (AppStrings.isEnglishLocale) return raw;
    switch (raw) {
      case 'Saving':
        return 'ادخار';
      case 'Investment':
        return 'استثمار';
      case 'Debt':
        return 'دين';
      case 'Other':
        return 'أخرى';
      default:
        return raw;
    }
  }

  static String get contributionTitle =>
      AppStrings.isEnglishLocale ? 'Add contribution' : 'إضافة مساهمة';
  static String get contributionNote =>
      AppStrings.isEnglishLocale ? 'Note (optional)' : 'ملاحظة (اختياري)';
  static String get contributionSuccessTitle => AppStrings.isEnglishLocale
      ? 'Contribution saved!'
      : 'تم حفظ المساهمة!';
  static String contributionSuccessBody(double amount) => AppStrings.isEnglishLocale
      ? 'Added ${amount.toStringAsFixed(2)} to your goal.'
      : 'أُضيف ${amount.toStringAsFixed(2)} إلى هدفك.';
  static String get contributionSnackbarAction =>
      AppStrings.isEnglishLocale ? 'Keep going!' : 'واصل!';
  static String get journeyMotivationTapHint => AppStrings.isEnglishLocale
      ? 'Tap for encouragement'
      : 'اضغط للتحفيز';
  static String get updateFailed => AppStrings.isEnglishLocale
      ? 'Failed to update goal'
      : 'فشل تحديث الهدف';

  static String get completedAlertTitle =>
      AppStrings.isEnglishLocale ? 'Goal reached!' : 'تم تحقيق الهدف!';
  static String completedAlertBody(String name) => AppStrings.isEnglishLocale
      ? 'Congratulations! You completed "$name".'
      : 'مبروك! أكملت هدف "$name".';
  static String get savedOffline => AppStrings.isEnglishLocale
      ? 'Saved locally. Will sync when online.'
      : 'حُفظ محلياً. سيُزامَن عند عودة الاتصال.';
}
