import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/domain/repository/synced_expense_repository/synced_expense_repository.dart';
import 'package:mudabbir/presentation/resources/expense_strings.dart';
import 'package:mudabbir/presentation/server_challenges/services/api_exception.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:stacked/stacked.dart';

/// Stacked view model for expense CRUD, filters, and budget feedback.
class ExpensesViewModel extends BaseViewModel {
  final SyncedExpenseRepository _repository = getIt<SyncedExpenseRepository>();

  List<ExpenseTransaction> expenses = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> accounts = [];
  String? errorMessage;
  String? successMessage;
  bool isOffline = false;

  String selectedMonth = _currentMonthKey();
  int? selectedCategoryId;
  bool recurringOnly = false;
  double filteredTotal = 0;

  static String _currentMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// Loads categories, accounts, and filtered expenses.
  Future<void> initialize() async {
    setBusy(true);
    errorMessage = null;
    await _loadMeta();
    await loadExpenses();
    setBusy(false);
  }

  Future<void> _loadMeta() async {
    final cats = await _repository.getExpenseCategories();
    final accs = await _repository.getAccounts();
    cats.fold((_) => categories = [], (data) => categories = data);
    accs.fold((_) => accounts = [], (data) => accounts = data);
  }

  /// Reloads expenses using active filters.
  Future<void> loadExpenses() async {
    setBusy(true);
    errorMessage = null;

    try {
      final result = await _repository.getTransactions(
        type: 'expense',
        monthKey: selectedMonth,
        categoryId: selectedCategoryId,
        recurringOnly: recurringOnly,
      );
      isOffline = result.isOffline;
      expenses = result.expenses;
      filteredTotal = expenses.fold(0.0, (sum, item) => sum + item.amount);
    } on ApiException catch (e) {
      errorMessage = e.message;
      expenses = [];
      filteredTotal = 0;
    } catch (_) {
      errorMessage = ExpenseStrings.loadFailed;
      expenses = [];
      filteredTotal = 0;
    }

    setBusy(false);
    notifyListeners();
  }

  void setMonth(String monthKey) {
    selectedMonth = monthKey;
    loadExpenses();
  }

  void setCategoryFilter(int? categoryId) {
    selectedCategoryId = categoryId;
    loadExpenses();
  }

  void toggleRecurringOnly(bool value) {
    recurringOnly = value;
    loadExpenses();
  }

  /// Creates a new expense and returns budget feedback message if any.
  Future<String?> addExpense({
    required double amount,
    required String date,
    required int accountId,
    required int categoryId,
    String? notes,
    bool isRecurring = false,
    bool allowOverBudget = false,
  }) async {
    final accountName = _resolveAccountName(accountId);
    final categoryName = _resolveCategoryName(categoryId);
    final tx = ExpenseTransaction(
      id: 0,
      amount: amount,
      date: date,
      type: 'expense',
      notes: notes,
      accountId: accountId,
      categoryId: categoryId,
      accountName: accountName,
      categoryName: categoryName,
      isRecurring: isRecurring,
      recurrenceInterval: isRecurring ? 'monthly' : null,
    );

    final result = await _repository.addTransaction(
      tx,
      allowOverBudget: allowOverBudget,
    );
    return result.fold((failure) {
      errorMessage = failure.userFacingMessage;
      notifyListeners();
      return null;
    }, (write) async {
      if (write.queuedOffline) {
        successMessage = ExpenseStrings.savedOffline;
      } else {
        successMessage = ExpenseStrings.savedSuccess;
        if (write.result.budgetMessage != null) {
          successMessage =
              '${ExpenseStrings.savedSuccess}\n${write.result.budgetMessage}';
        }
      }
      await loadExpenses();
      return successMessage;
    });
  }

  /// Updates an existing expense.
  Future<String?> updateExpense(ExpenseTransaction existing, {
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
      errorMessage = failure.userFacingMessage;
      notifyListeners();
      return null;
    }, (write) async {
      if (write.queuedOffline) {
        successMessage = ExpenseStrings.savedOffline;
      } else {
        successMessage = ExpenseStrings.updatedSuccess;
        if (write.result.budgetMessage != null) {
          successMessage =
              '${ExpenseStrings.updatedSuccess}\n${write.result.budgetMessage}';
        }
      }
      await loadExpenses();
      return successMessage;
    });
  }

  /// Deletes expense by id.
  Future<bool> deleteExpense(int id) async {
    final result = await _repository.deleteTransaction(id);
    return result.fold((failure) {
      errorMessage = failure.userFacingMessage;
      notifyListeners();
      return false;
    }, (syncResult) async {
      if (syncResult.deleted) {
        successMessage = syncResult.queuedOffline
            ? ExpenseStrings.savedOffline
            : ExpenseStrings.deletedSuccess;
        await loadExpenses();
      }
      return syncResult.deleted;
    });
  }

  String _resolveAccountName(int accountId) {
    for (final account in accounts) {
      if (account['id'] == accountId) {
        return account['name']?.toString() ?? '';
      }
    }
    return '';
  }

  String _resolveCategoryName(int categoryId) {
    for (final category in categories) {
      if (category['id'] == categoryId) {
        return category['name']?.toString() ?? '';
      }
    }
    return '';
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }
}
