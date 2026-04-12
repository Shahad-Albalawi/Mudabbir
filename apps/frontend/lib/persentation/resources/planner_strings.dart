import 'package:mudabbir/persentation/resources/strings_manager.dart';

class PlannerStrings {
  PlannerStrings._();

  static bool get _e => AppStrings.isEnglishLocale;

  static String get navPlanner =>
      _e ? 'Plan' : 'المخطط';

  static String get tabBudget =>
      _e ? 'Budgets' : 'الميزانيات';

  static String get tabNotes =>
      _e ? 'Notes' : 'ملاحظات';

  static String get tabTasks =>
      _e ? 'Tasks' : 'مهام';

  static String get tabIncome =>
      _e ? 'Income' : 'الدخل';

  static String get incomeTitle =>
      _e ? 'Monthly income plan' : 'الراتب / الدخل الشهري';

  static String get incomeSubtitle => _e
      ? 'Used for insights and AI suggestions (optional if you log salary as income).'
      : 'يُستخدم للتحليلات والاقتراحات (اختياري إذا سجّلت الراتب كمعاملة دخل).';

  static String get incomeAmountLabel =>
      _e ? 'Expected monthly income' : 'الدخل الشهري المتوقع';

  static String get currencyLabel =>
      _e ? 'Currency code' : 'رمز العملة';

  static String get currencyHint =>
      _e ? 'e.g. SAR' : 'مثال: SAR';

  static String get saveIncome =>
      _e ? 'Save' : 'حفظ';

  static String get budgetTitle =>
      _e ? 'Category budgets (this month)' : 'ميزانيات الفئات (هذا الشهر)';

  static String get budgetSubtitle => _e
      ? 'Set a limit per category. Spent is calculated from expenses this month.'
      : 'حدد سقفاً لكل فئة. المصروف يُحسب من معاملات هذا الشهر.';

  static String get limitHint =>
      _e ? 'Monthly limit' : 'الحد الشهري';

  static String get spentLabel =>
      _e ? 'Spent' : 'المصروف';

  static String get remainingLabel =>
      _e ? 'Left' : 'المتبقي';

  static String budgetPctUsed(String name, int pct) => _e
      ? '$name: $pct% of budget used'
      : '$name: تم استخدام $pct% من الميزانية';

  static String get aiSuggestTitle =>
      _e ? 'Suggested split (learning + 50/30/20)' : 'اقتراح توزيع (سلوك + 50/30/20)';

  static String get aiSuggestBody => _e
      ? 'Based on your last 3 months spending (when available) blended with essentials 50%, wants 30%, savings 20%. Tap a row to copy the value into the limit field.'
      : 'يعتمد على متوسط صرفك لآخر 3 أشهر عند توفرها، ممزوجاً بقاعدة 50٪ أساسيات، 30٪ رغبات، 20٪ ادخار. انسخ القيمة للحد.';

  static String get applySuggestion =>
      _e ? 'Use' : 'تطبيق';

  static String get notesTitle =>
      _e ? 'Notes & ideas' : 'ملاحظات وأفكار';

  static String get noteNew =>
      _e ? 'New note' : 'ملاحظة جديدة';

  static String get noteTitleHint =>
      _e ? 'Title' : 'العنوان';

  static String get noteBodyHint =>
      _e ? 'Write your idea…' : 'اكتب فكرتك…';

  static String get noteFinancialIdea =>
      _e ? 'Financial idea' : 'فكرة مالية';

  static String get noteToTask =>
      _e ? 'Turn into task' : 'تحويل لمهمة';

  static String get tasksTitle =>
      _e ? 'Tasks' : 'المهام';

  static String get taskNew =>
      _e ? 'New task' : 'مهمة جديدة';

  static String get taskPending =>
      _e ? 'Pending' : 'قيد التنفيذ';

  static String get taskDone =>
      _e ? 'Done' : 'منجز';

  static String get taskLinkBudget =>
      _e ? 'Link expense category (optional)' : 'ربط بفئة مصروف (اختياري)';

  static String get none =>
      _e ? 'None' : 'بدون';

  static String get delete =>
      _e ? 'Delete' : 'حذف';

  static String get cancel =>
      _e ? 'Cancel' : 'إلغاء';

  static String get saved =>
      _e ? 'Saved' : 'تم الحفظ';

  static String notifNearGoal(String name) => _e
      ? 'You are close to your savings goal: $name'
      : 'أنت قريب من هدف الادخار: $name';

  static String notifBudgetHigh(String line) => _e
      ? 'Budget alert: $line'
      : 'تنبيه ميزانية: $line';

  static String get notifImpulse =>
      _e ? 'Do you really need this purchase?' : 'هل تحتاج هذا الشراء فعلاً؟';

  static String get notifSpendingHigh =>
      _e ? 'Your spending is higher than usual this month.' : 'صرفك أعلى من المعتاد هذا الشهر.';

  static String get topCategoryInsight => _e
      ? 'Top spending category this month'
      : 'أكثر فئة صرفاً هذا الشهر';

  static String get monthSpendTotal => _e
      ? 'Total spent this month'
      : 'إجمالي الصرف هذا الشهر';

  static String get vsLastMonth => _e
      ? 'vs last month'
      : 'مقارنة بالشهر الماضي';
}
