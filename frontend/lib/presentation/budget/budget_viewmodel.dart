import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/domain/models/budget_record.dart';
import 'package:mudabbir/domain/repository/budget_repository/budget_repository.dart';
import 'package:mudabbir/domain/repository/synced_budget_repository/synced_budget_repository.dart';
import 'package:mudabbir/data/network/api_exception.dart';
import 'package:mudabbir/presentation/resources/budget_strings.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/utils/dev_log.dart';

const _unsetBudgetError = Object();

class BudgetDisplayItem {
  final BudgetRecord budget;
  final double spent;

  const BudgetDisplayItem({required this.budget, required this.spent});
}

class BudgetState {
  final bool isLoading;
  final List<BudgetDisplayItem> items;
  final String? error;
  final bool isDelete;
  final bool isAdd;
  final bool isOffline;
  final bool isSubmitting;

  BudgetState({
    this.isLoading = false,
    this.items = const [],
    this.error,
    this.isDelete = false,
    this.isAdd = false,
    this.isOffline = false,
    this.isSubmitting = false,
  });

  BudgetState copyWith({
    bool? isLoading,
    List<BudgetDisplayItem>? items,
    Object? error = _unsetBudgetError,
    bool? isDelete,
    bool? isAdd,
    bool? isOffline,
    bool? isSubmitting,
  }) {
    return BudgetState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: identical(error, _unsetBudgetError)
          ? this.error
          : error as String?,
      isDelete: isDelete ?? this.isDelete,
      isAdd: isAdd ?? this.isAdd,
      isOffline: isOffline ?? this.isOffline,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class BudgetViewmodel extends StateNotifier<BudgetState> {
  final SyncedBudgetRepository _synced = getIt<SyncedBudgetRepository>();
  final BudgetRepository _local = getIt<BudgetRepository>();

  BudgetViewmodel() : super(BudgetState());

  Future<void> getAllBudgets() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _synced.getBudgets();
      final items = <BudgetDisplayItem>[];
      for (final budget in result.budgets) {
        final spent = await _local.getSpentForPeriod(
          accountId: budget.accountId,
          startDate: budget.startDate,
          endDate: budget.endDate,
        );
        items.add(BudgetDisplayItem(budget: budget, spent: spent));
      }
      state = state.copyWith(
        isLoading: false,
        items: items,
        isOffline: result.isOffline,
        isDelete: false,
        isAdd: false,
      );
    } on ApiException catch (e) {
      devLog('Budget sync error: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        isOffline: e.isNetworkError,
      );
    } catch (e) {
      devLog('Budget sync error: $e');
      state = state.copyWith(
        isLoading: false,
        error: BudgetStrings.loadFailed,
        isOffline: true,
      );
    }
  }

  Future<void> addNewBudget({
    required double amount,
    required String startDate,
    required String endDate,
    required int accountId,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final result = await _synced.createBudget(
        amount: amount,
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
      );
      result.fold(
        (failure) => state = state.copyWith(error: failure.message),
        (sync) => state = state.copyWith(
          isAdd: true,
          isOffline: sync.queuedOffline || state.isOffline,
        ),
      );
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<dynamic> getAccounts() async {
    return await getIt<DbHelper>().queryAllRows('accounts');
  }

  Future<void> deleteBudget(int id) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final result = await _synced.deleteBudget(id);
      result.fold(
        (failure) => state = state.copyWith(error: failure.message),
        (sync) {
          if (sync.deleted) {
            final updated =
                state.items.where((item) => item.budget.id != id).toList();
            state = state.copyWith(
              items: updated,
              isDelete: true,
              isOffline: sync.queuedOffline || state.isOffline,
            );
          }
        },
      );
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final budgetViewmodelProvider =
    StateNotifierProvider.autoDispose<BudgetViewmodel, BudgetState>((ref) {
      return BudgetViewmodel()..getAllBudgets();
    });
