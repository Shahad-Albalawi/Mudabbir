import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Shared validators for financial forms (expenses, budgets, goals).
abstract final class FinancialFormValidators {
  static const int maxNotesLength = 500;
  static const int maxNameLength = 255;
  static const double maxAmount = 999999999;

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldAmountInvalid;
    }
    final n = double.tryParse(value.trim());
    if (n == null || n <= 0) {
      return AppStrings.fieldAmountInvalid;
    }
    if (n > maxAmount) {
      return AppStrings.expensesAmountTooLarge;
    }
    return null;
  }

  static String? dateNotFuture(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.expensesDateRequired;
    }
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) {
      return AppStrings.expensesDateInvalid;
    }
    final today = DateTime.now();
    final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);
    if (parsed.isAfter(endOfToday)) {
      return AppStrings.expensesDateCannotBeFuture;
    }
    return null;
  }

  static String? notes(String? value) {
    if (value != null && value.length > maxNotesLength) {
      return AppStrings.fieldNotesTooLong;
    }
    return null;
  }

  static String? name(String? value, {String? requiredMessage}) {
    if (value == null || value.trim().isEmpty) {
      return requiredMessage ?? AppStrings.fieldRequired;
    }
    if (value.trim().length > maxNameLength) {
      return AppStrings.expensesTextTooLong;
    }
    return null;
  }

  static String? accountSelected(int? accountId) {
    if (accountId == null) {
      return AppStrings.expensesAccountRequired;
    }
    return null;
  }

  static String? categorySelected(int? categoryId) {
    if (categoryId == null) {
      return AppStrings.expensesCategoryRequired;
    }
    return null;
  }
}
