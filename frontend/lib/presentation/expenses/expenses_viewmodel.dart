import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/data/network/api_exception.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/domain/repository/synced_expense_repository/synced_expense_repository.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/notifications/financial_alert_service.dart';

const _unsetExpenseError = Object();

class ExpensesState {
  final bool isLoading;
  final List<ExpenseTransaction> expenses;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> accounts;
  final String? errorMessage;
  final String? successMessage;
  final bool isOffline;
  final String selectedMonth;
  final int? selectedCategoryId;
  final bool recurringOnly;
  final double filteredTotal;

  ExpensesState({
    this.isLoading = false,
    this.expenses = const [],
    this.categories = const [],
    this.accounts = const [],
    this.errorMessage,
    this.successMessage,
    this.isOffline = false,
    String? selectedMonth,
    this.selectedCategoryId,
    this.recurringOnly = false,
    this.filteredTotal = 0,
  }) : selectedMonth = selectedMonth ?? ExpensesNotifier.currentMonthKey();

  ExpensesState copyWith({
    bool? isLoading,
    List<ExpenseTransaction>? expenses,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? accounts,
    Object? errorMessage = _unsetExpenseError,
    Object? successMessage = _unsetExpenseError,
    bool? isOffline,
    String? selectedMonth,
    int? selectedCategoryId,
    bool? recurringOnly,
    double? filteredTotal,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ExpensesState(
      isLoading: isLoading ?? this.isLoading,
      expenses: expenses ?? this.expenses,
      categories: categories ?? this.categories,
      accounts: accounts ?? this.accounts,
      errorMessage: clearError
          ? null
          : identical(errorMessage, _unsetExpenseError)
              ? this.errorMessage
              : errorMessage as String?,
      successMessage: clearSuccess
          ? null
          : identical(successMessage, _unsetExpenseError)
              ? this.successMessage
              : successMessage as String?,
      isOffline: isOffline ?? this.isOffline,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      recurringOnly: recurringOnly ?? this.recurringOnly,
      filteredTotal: filteredTotal ?? this.filteredTotal,
    );
  }
}

class ExpensesNotifier extends StateNotifier<ExpensesState> {
  final SyncedExpenseRepository _repository = getIt<SyncedExpenseRepository>();

  ExpensesNotifier() : super(ExpensesState());

  static String currentMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _loadMeta();
    await loadExpenses();
    state = state.copyWith(isLoading: false);
  }

  Future<void> _loadMeta() async {
    final cats = await _repository.getExpenseCategories();
    final accs = await _repository.getAccounts();
    state = state.copyWith(
      categories: cats.fold((_) => <Map<String, dynamic>>[], (data) => data),
      accounts: accs.fold((_) => <Map<String, dynamic>>[], (data) => data),
    );
  }

  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.getTransactions(
        type: 'expense',
        monthKey: state.selectedMonth,
        categoryId: state.selectedCategoryId,
        recurringOnly: state.recurringOnly,
      );
      final total = result.expenses.fold(0.0, (sum, item) => sum + item.amount);
      state = state.copyWith(
        isLoading: false,
        isOffline: result.isOffline,
        expenses: result.expenses,
        filteredTotal: total,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.userMessage,
        expenses: const [],
        filteredTotal: 0,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.expensesLoadFailed,
        expenses: const [],
        filteredTotal: 0,
      );
    }
  }

  void setMonth(String monthKey) {
    state = state.copyWith(selectedMonth: monthKey);
    loadExpenses();
  }

  void setCategoryFilter(int? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
    loadExpenses();
  }

  void toggleRecurringOnly(bool value) {
    state = state.copyWith(recurringOnly: value);
    loadExpenses();
  }

  Future<String?> addExpense({
    required double amount,
    required String date,
    required int accountId,
    required int categoryId,
    String? notes,
    bool isRecurring = false,
    bool allowOverBudget = false,
  }) async {
    final tx = ExpenseTransaction(
      id: 0,
      amount: amount,
      date: date,
      type: 'expense',
      notes: notes,
      accountId: accountId,
      categoryId: categoryId,
      accountName: _resolveAccountName(accountId),
      categoryName: _resolveCategoryName(categoryId),
      isRecurring: isRecurring,
      recurrenceInterval: isRecurring ? 'monthly' : null,
    );

    final result = await _repository.addTransaction(
      tx,
      allowOverBudget: allowOverBudget,
    );
    return result.fold((failure) {
      state = state.copyWith(errorMessage: failure.userFacingMessage);
      return null;
    }, (write) async {
      String? message;
      if (write.queuedOffline) {
        message = AppStrings.offlineSavedPendingSync;
      } else {
        message = AppStrings.expensesSavedSuccess;
        if (write.result.budgetMessage != null) {
          message =
              '${AppStrings.expensesSavedSuccess}\n${write.result.budgetMessage}';
        }
      }
      state = state.copyWith(successMessage: message);
      await FinancialAlertService.instance.maybeNotifyBudgetUsage(
        write.result.budgetSnapshot,
      );
      await loadExpenses();
      return message;
    });
  }

  Future<String?> updateExpense(
    ExpenseTransaction existing, {
    required double amount,
    required String date,
    required int accountId,
    required int categoryId,
    String? notes,
    bool isRecurring = false,
    bool allowOverBudget = false,
  }) async {
    final tx = ExpenseTransaction(
      id: existing.id,
      amount: amount,
      date: date,
      type: 'expense',
      notes: notes,
      accountId: accountId,
      categoryId: categoryId,
      accountName: _resolveAccountName(accountId),
      categoryName: _resolveCategoryName(categoryId),
      isRecurring: isRecurring,
      recurrenceInterval: isRecurring ? 'monthly' : null,
    );

    final result = await _repository.updateTransaction(
      tx,
      allowOverBudget: allowOverBudget,
    );

    return result.fold((failure) {
      state = state.copyWith(errorMessage: failure.userFacingMessage);
      return null;
    }, (write) async {
      String? message;
      if (write.queuedOffline) {
        message = AppStrings.offlineSavedPendingSync;
      } else {
        message = AppStrings.expensesUpdatedSuccess;
        if (write.result.budgetMessage != null) {
          message =
              '${AppStrings.expensesUpdatedSuccess}\n${write.result.budgetMessage}';
        }
      }
      state = state.copyWith(successMessage: message);
      await FinancialAlertService.instance.maybeNotifyBudgetUsage(
        write.result.budgetSnapshot,
      );
      await loadExpenses();
      return message;
    });
  }

  Future<bool> deleteExpense(int id) async {
    final result = await _repository.deleteTransaction(id);
    return result.fold((failure) {
      state = state.copyWith(errorMessage: failure.userFacingMessage);
      return false;
    }, (syncResult) async {
      if (syncResult.deleted) {
        state = state.copyWith(
          successMessage: syncResult.queuedOffline
              ? AppStrings.offlineSavedPendingSync
              : AppStrings.expensesDeletedSuccess,
        );
        await loadExpenses();
      }
      return syncResult.deleted;
    });
  }

  String _resolveAccountName(int accountId) {
    for (final account in state.accounts) {
      if (account['id'] == accountId) {
        return account['name']?.toString() ?? '';
      }
    }
    return '';
  }

  String _resolveCategoryName(int categoryId) {
    for (final category in state.categories) {
      if (category['id'] == categoryId) {
        return category['name']?.toString() ?? '';
      }
    }
    return '';
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

final expensesProvider =
    StateNotifierProvider.autoDispose<ExpensesNotifier, ExpensesState>((ref) {
  return ExpensesNotifier()..initialize();
});
