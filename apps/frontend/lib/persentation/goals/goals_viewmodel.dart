import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/domain/repository/goals_repository/goals_repository.dart';
import 'package:mudabbir/service/getit_init.dart';

// State class
class GoalState {
  final bool isLoading;
  final List<Map<String, dynamic>> goals; // Fixed typing
  final String? error;
  final isDelete;
  final isAdd;
  final isUpdate;

  GoalState({
    this.isLoading = false,
    this.goals = const [],
    this.error,
    this.isDelete = false,
    this.isAdd = false,
    this.isUpdate = false,
  });

  GoalState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? goals,
    String? error,
    bool? isDelete,
    bool? isAdd,
    bool? isUpdate,
  }) {
    return GoalState(
      isLoading: isLoading ?? this.isLoading,
      goals: goals ?? this.goals,
      error: error,
      isDelete: isDelete,
      isAdd: isAdd,
      isUpdate: isUpdate,
    );
  }
}

// ViewModel as StateNotifier
class GoalViewmodel extends StateNotifier<GoalState> {
  final GoalsRepository _budgetRepository = getIt<GoalsRepository>();

  GoalViewmodel() : super(GoalState());

  // get All Goals
  Future<void> getAllGoals() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _budgetRepository.getGoals();

    result.fold(
      (l) {
        debugPrint(l.message);
        state = state.copyWith(isLoading: false, error: l.message);
      },
      (r) {
        debugPrint(r.toString());
        if (r.isEmpty) {
          state = state.copyWith(isLoading: false, goals: []);
        } else {
          // Ensure proper typing when setting goals
          final typedGoals = r
              .map((goal) => Map<String, dynamic>.from(goal))
              .toList();
          state = state.copyWith(isLoading: false, goals: typedGoals);
        }
      },
    );
  }

  addNewGoal(Map<String, dynamic> data) async {
    await _budgetRepository.addGoal(data);
    state = state.copyWith(isAdd: true, goals: state.goals);
  }

  // delete budget
  deleteGoal(int id) async {
    final result = await _budgetRepository.removeGoal(id);
    if (result == 1) {
      // Remove the budget from the current state immediately
      final updatedGoals = state.goals
          .where((budget) => budget['id'] != id)
          .toList();
      state = state.copyWith(goals: updatedGoals, isDelete: true);
    }
  }

  // New method to update goal amount
  Future<void> updateGoalAmount(int goalId, double amountToAdd) async {
    try {
      // Find the current goal
      final goalIndex = state.goals.indexWhere((goal) => goal['id'] == goalId);
      if (goalIndex == -1) return;

      final currentGoal = state.goals[goalIndex];
      final currentAmount = (currentGoal['current_amount'] ?? 0.0).toDouble();
      final newAmount = currentAmount + amountToAdd;

      // Update in database
      final result = await _budgetRepository.updateGoalAmount(
        goalId,
        newAmount,
      );

      if (result > 0) {
        // Update the goal in the current state with proper typing
        final updatedGoals = List<Map<String, dynamic>>.from(
          state.goals.map((goal) => Map<String, dynamic>.from(goal)),
        );
        updatedGoals[goalIndex] = Map<String, dynamic>.from({
          ...currentGoal,
          'current_amount': newAmount,
        });

        state = state.copyWith(goals: updatedGoals, isUpdate: true);
      }
    } catch (e) {
      state = state.copyWith(error: 'فشل في تحديث الهدف');
      debugPrint('Error updating goal: $e');
    }
  }
}

final goalViewmodelProvider =
    StateNotifierProvider.autoDispose<GoalViewmodel, GoalState>((ref) {
      return GoalViewmodel()..getAllGoals();
    });
