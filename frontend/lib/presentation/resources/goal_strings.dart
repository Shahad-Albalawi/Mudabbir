import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Bilingual strings for savings goals (Feature D).
class GoalStrings {
  GoalStrings._();

  static bool get _e => AppStrings.isEnglishLocale;

  static String formatAmount(double value) =>
      '${value.toStringAsFixed(0)} ${_e ? 'SAR' : '﷼'}';

  static String get createTitle => _e ? 'Create goal' : 'إنشاء هدف';
  static String get createSubtitle =>
      _e ? 'Set your savings target' : 'حدد هدف ادخارك';
  static String get goalName => _e ? 'Goal name' : 'اسم الهدف';
  static String get goalNameHint =>
      _e ? 'e.g. New car, Emergency fund' : 'مثال: سيارة جديدة، صندوق طوارئ';
  static String get targetAmount => _e ? 'Target amount' : 'المبلغ المستهدف';
  static String get currentAmount =>
      _e ? 'Starting amount (optional)' : 'المبلغ الحالي (اختياري)';
  static String get goalType => _e ? 'Goal type' : 'نوع الهدف';
  static String get goalPeriod => _e ? 'Deadline' : 'الموعد النهائي';
  static String get startDate => _e ? 'Start date' : 'تاريخ البداية';
  static String get endDate => _e ? 'Target date' : 'تاريخ الهدف';
  static String get pickImage => _e ? 'Add photo' : 'إضافة صورة';
  static String get changeImage => _e ? 'Change photo' : 'تغيير الصورة';
  static String get cancel => _e ? 'Cancel' : 'إلغاء';
  static String get createButton => _e ? 'Create goal' : 'إنشاء الهدف';
  static String get nameRequired => _e ? 'Name is required' : 'الاسم مطلوب';
  static String get targetRequired =>
      _e ? 'Target amount is required' : 'المبلغ المستهدف مطلوب';
  static String get invalidAmount =>
      _e ? 'Enter a valid amount' : 'أدخل مبلغاً صحيحاً';
  static String get typeRequired =>
      _e ? 'Select a goal type' : 'اختر نوع الهدف';
  static String get startRequired =>
      _e ? 'Start date required' : 'تاريخ البداية مطلوب';
  static String get endRequired =>
      _e ? 'Target date required' : 'تاريخ الهدف مطلوب';
  static String get endAfterStart => _e
      ? 'Target date must be after start'
      : 'تاريخ الهدف يجب أن يكون بعد البداية';
  static String get createdSuccess =>
      _e ? 'Goal created successfully!' : 'تم إنشاء الهدف بنجاح!';
  static String get createFailed =>
      _e ? 'Failed to create goal' : 'فشل إنشاء الهدف';

  static String get deadlineLabel => _e ? 'Deadline' : 'الموعد النهائي';
  static String get projectedLabel =>
      _e ? 'Expected completion' : 'تاريخ الوصول المتوقع';
  static String get remainingLabel => _e ? 'Remaining' : 'المتبقي';
  static String get contributeHint =>
      _e ? 'Tap to add contribution' : 'اضغط لإضافة مساهمة';
  static String get monthlyNeeded =>
      _e ? 'Needed monthly to meet deadline' : 'المطلوب شهرياً للوصول للموعد';
  static String get avgMonthly =>
      _e ? 'Your avg. monthly contributions' : 'متوسط مساهماتك الشهرية';

  static String statusLabel(GoalTrackStatus status) {
    switch (status) {
      case GoalTrackStatus.onTrack:
        return _e ? 'On track' : 'على المسار';
      case GoalTrackStatus.behind:
        return _e ? 'Behind schedule' : 'متأخر عن الجدول';
      case GoalTrackStatus.overdue:
        return _e ? 'Past deadline' : 'تجاوز الموعد';
      case GoalTrackStatus.completed:
        return _e ? 'Completed' : 'مكتمل';
      case GoalTrackStatus.noData:
        return _e ? 'Add contributions' : 'أضف مساهمات';
    }
  }

  static String formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  static String projectedDateText(DateTime? date) {
    if (date == null) {
      return _e ? 'Not enough data' : 'بيانات غير كافية';
    }
    return formatDate(date);
  }

  static List<String> get goalTypes => _e
      ? const ['Saving', 'Investment', 'Debt', 'Other']
      : const ['ادخار', 'استثمار', 'دين', 'أخرى'];

  static String typeLabel(String raw) {
    if (_e) return raw;
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
      _e ? 'Add contribution' : 'إضافة مساهمة';
  static String get contributionNote =>
      _e ? 'Note (optional)' : 'ملاحظة (اختياري)';
  static String get updateFailed =>
      _e ? 'Failed to update goal' : 'فشل تحديث الهدف';
  static String get completedAlertTitle =>
      _e ? 'Goal reached!' : 'تم تحقيق الهدف!';
  static String completedAlertBody(String name) => _e
      ? 'Congratulations! You completed "$name".'
      : 'مبروك! أكملت هدف "$name".';
  static String get offlineBanner => _e
      ? 'Offline — showing cached goals. Changes will sync when you reconnect.'
      : 'وضع عدم الاتصال — عرض أهداف محفوظة. ستُزامَن التغييرات عند عودة الشبكة.';
  static String get savedOffline => _e
      ? 'Saved locally. Will sync when online.'
      : 'حُفظ محلياً. سيُزامَن عند عودة الاتصال.';
}
