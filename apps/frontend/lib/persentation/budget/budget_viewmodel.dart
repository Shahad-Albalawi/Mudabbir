import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/domain/repository/budget_repository/budget_repository.dart';
import 'package:mudabbir/service/getit_init.dart';

// State class
class BudgetState {
  final bool isLoading;
  final List<dynamic> budgets; // replace with your Budget model
  final String? error;
  final isDelete;
  final isAdd;

  BudgetState({
    this.isLoading = false,
    this.budgets = const [],
    this.error,
    this.isDelete = false,
    this.isAdd = false,
  });

  BudgetState copyWith({
    bool? isLoading,
    List<dynamic>? budgets,
    String? error,
    bool? isDelete,
    bool? isAdd,
  }) {
    return BudgetState(
      isLoading: isLoading ?? this.isLoading,
      budgets: budgets ?? this.budgets,
      error: error,
      isDelete: isDelete,
      isAdd: isAdd,
    );
  }
}

// ViewModel as StateNotifier
class BudgetViewmodel extends StateNotifier<BudgetState> {
  final BudgetRepository _budgetRepository = getIt<BudgetRepository>();

  BudgetViewmodel() : super(BudgetState());

  // get All Budgets
  Future<void> getAllBudgets() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _budgetRepository.getBudgets();

    result.fold(
      (l) {
        debugPrint(l.message);
        state = state.copyWith(isLoading: false, error: l.message);
      },
      (r) {
        debugPrint('Budgets: $r');
        if (r.isEmpty) {
          state = state.copyWith(isLoading: false, budgets: []);
        } else {
          state = state.copyWith(isLoading: false, budgets: r);
        }
      },
    );
  }

  addNewBudget(Map<String, dynamic> data) async {
    await _budgetRepository.addBudget(data);
    state = state.copyWith(isAdd: true, budgets: state.budgets);
  }

  getAccounts() async {
    return await getIt<DbHelper>().queryAllRows('accounts');
  }

  // delete budget
  deleteBudget(int id) async {
    final result = await _budgetRepository.removeBudget(id);
    if (result == 1) {
      // Remove the budget from the current state immediately
      final updatedBudgets = state.budgets
          .where((budget) => budget['id'] != id)
          .toList();
      state = state.copyWith(budgets: updatedBudgets, isDelete: true);
    }
  }
}

final budgetViewmodelProvider =
    StateNotifierProvider.autoDispose<BudgetViewmodel, BudgetState>((ref) {
      return BudgetViewmodel()..getAllBudgets();
    });
