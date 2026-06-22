import 'package:mudabbir/presentation/resources/expense_strings.dart';

/// Shared validators for financial forms (expenses, budgets, goals).
abstract final class FinancialFormValidators {
  static const int maxNotesLength = 500;
  static const int maxNameLength = 255;
  static const double maxAmount = 999999999;

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ExpenseStrings.invalidAmount;
    }
    final n = double.tryParse(value.trim());
    if (n == null || n <= 0) {
      return ExpenseStrings.invalidAmount;
    }
    if (n > maxAmount) {
      return ExpenseStrings.amountTooLarge;
    }
    return null;
  }

  static String? dateNotFuture(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ExpenseStrings.dateRequired;
    }
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) {
      return ExpenseStrings.dateInvalid;
    }
    final today = DateTime.now();
    final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);
    if (parsed.isAfter(endOfToday)) {
      return ExpenseStrings.dateCannotBeFuture;
    }
    return null;
  }

  static String? notes(String? value) {
    if (value != null && value.length > maxNotesLength) {
      return ExpenseStrings.notesTooLong;
    }
    return null;
  }

  static String? name(String? value, {String? requiredMessage}) {
    if (value == null || value.trim().isEmpty) {
      return requiredMessage ?? ExpenseStrings.requiredField;
    }
    if (value.trim().length > maxNameLength) {
      return ExpenseStrings.textTooLong;
    }
    return null;
  }

  static String? accountSelected(int? accountId) {
    if (accountId == null) {
      return ExpenseStrings.accountRequired;
    }
    return null;
  }

  static String? categorySelected(int? categoryId) {
    if (categoryId == null) {
      return ExpenseStrings.categoryRequired;
    }
    return null;
  }
}
