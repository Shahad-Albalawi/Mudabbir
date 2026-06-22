import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Bilingual strings for expense tracking screens.
class ExpenseStrings {
  ExpenseStrings._();

  static bool get _e => AppStrings.isEnglishLocale;

  static String formatAmount(double value) => AppCurrency.format(value);

  static String get title => _e ? 'Expenses' : 'المصروفات';
  static String get addExpense => _e ? 'Add expense' : 'إضافة مصروف';
  static String get editExpense => _e ? 'Edit expense' : 'تعديل مصروف';
  static String get save => _e ? 'Save' : 'حفظ';
  static String get emptyTitle =>
      _e ? 'No expenses yet' : 'لا توجد مصروفات بعد';
  static String get emptySubtitle => _e
      ? 'Add your first expense to start tracking spending.'
      : 'أضف أول مصروف لبدء تتبع إنفاقك.';
  static String get filterMonth => _e ? 'Month' : 'الشهر';
  static String get filterCategory => _e ? 'Category' : 'الفئة';
  static String get filterType => _e ? 'Type' : 'النوع';
  static String get filterAll => _e ? 'All' : 'الكل';
  static String get filterRecurring =>
      _e ? 'Recurring only' : 'المتكررة فقط';
  static String get recurringMonthly =>
      _e ? 'Monthly recurring' : 'متكرر شهرياً';
  static String get amount => _e ? 'Amount' : 'المبلغ';
  static String get date => _e ? 'Date' : 'التاريخ';
  static String get account => _e ? 'Account' : 'الحساب';
  static String get category => _e ? 'Category' : 'الفئة';
  static String get notes => _e ? 'Notes' : 'ملاحظات';
  static String get requiredField => _e ? 'Required' : 'مطلوب';
  static String get invalidAmount => _e ? 'Invalid amount' : 'مبلغ غير صحيح';
  static String get amountTooLarge =>
      _e ? 'Amount is too large.' : 'المبلغ كبير جداً.';
  static String get dateRequired =>
      _e ? 'Date is required.' : 'التاريخ مطلوب.';
  static String get dateInvalid =>
      _e ? 'Invalid date.' : 'تاريخ غير صالح.';
  static String get dateCannotBeFuture => _e
      ? 'Date cannot be in the future.'
      : 'لا يمكن اختيار تاريخ في المستقبل.';
  static String get notesTooLong => _e
      ? 'Notes are too long (max 500 characters).'
      : 'الملاحظات طويلة جداً (الحد الأقصى 500 حرف).';
  static String get accountRequired =>
      _e ? 'Select an account.' : 'اختر حساباً.';
  static String get categoryRequired =>
      _e ? 'Select a category.' : 'اختر فئة.';
  static String get textTooLong => _e
      ? 'Text is too long (max 255 characters).'
      : 'النص طويل جداً (الحد الأقصى 255 حرف).';
  static String get loadFailed =>
      _e ? 'Failed to load expenses.' : 'تعذر تحميل المصروفات.';
  static String get syncFailed =>
      _e ? 'Expense sync failed.' : 'فشلت مزامنة المصروفات.';
  static String get saveFailed =>
      _e ? 'Failed to save expense.' : 'تعذر حفظ المصروف.';
  static String get updateFailed =>
      _e ? 'Failed to update expense.' : 'تعذر تحديث المصروف.';
  static String get deleteFailed =>
      _e ? 'Failed to delete expense.' : 'تعذر حذف المصروف.';
  static String get deleteConfirmTitle => AppStrings.expenseDeleteConfirmTitle;
  static String get deleteConfirmBody => AppStrings.expenseDeleteConfirmBody;
  static String get cancel => AppStrings.txCancel;
  static String get deleteExpense => AppStrings.delete;
  static String get savedSuccess =>
      _e ? 'Expense saved.' : 'تم حفظ المصروف.';
  static String get updatedSuccess =>
      _e ? 'Expense updated.' : 'تم تحديث المصروف.';
  static String get deletedSuccess =>
      _e ? 'Expense deleted.' : 'تم حذف المصروف.';
  static String get insufficientBalance => _e
      ? 'Amount exceeds available balance.'
      : 'المبلغ أكبر من الرصيد المتاح.';
  static String budgetExceeded(double remaining) => _e
      ? 'This expense exceeds the remaining budget (${AppCurrency.format(remaining)}).'
      : 'هذا المصروف يتجاوز المتبقي من الميزانية (${AppCurrency.format(remaining)}).';
  static String budgetLinked(double spent, double budget, double remaining) =>
      _e
      ? 'Budget link: spent ${AppCurrency.format(spent)} / ${AppCurrency.format(budget)} — remaining ${AppCurrency.format(remaining)}.'
      : 'ربط الميزانية: صرفت ${AppCurrency.format(spent)} / ${AppCurrency.format(budget)} — المتبقي ${AppCurrency.format(remaining)}.';
  static String get viewAllExpenses =>
      _e ? 'View all expenses' : 'عرض كل المصروفات';
  static String get totalFiltered =>
      _e ? 'Filtered total' : 'إجمالي الفلتر';
  static String get recurringBadge => _e ? 'Recurring' : 'متكرر';
  static String get offlineBanner => AppStrings.expenseOfflineBanner;
  static String get savedOffline => _e
      ? 'Saved locally. Will sync when online.'
      : 'حُفظ محلياً. سيُزامَن عند عودة الاتصال.';
}
