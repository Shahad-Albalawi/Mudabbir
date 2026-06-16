import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/domain/repository/goals_repository/goals_repository.dart';
import 'package:mudabbir/domain/repository/synced_goals_repository/synced_goals_repository.dart';
import 'package:mudabbir/presentation/resources/goal_strings.dart';
import 'package:mudabbir/presentation/server_challenges/services/api_exception.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/utils/dev_log.dart';

const _unsetGoalError = Object();

class GoalState {
  final bool isLoading;
  final List<SavingsGoal> goals;
  final String? error;
  final bool isDelete;
  final bool isAdd;
  final bool isOffline;
  final GoalWriteResult? lastContribution;

  GoalState({
    this.isLoading = false,
    this.goals = const [],
    this.error,
    this.isDelete = false,
    this.isAdd = false,
    this.isOffline = false,
    this.lastContribution,
  });

  GoalState copyWith({
    bool? isLoading,
    List<SavingsGoal>? goals,
    Object? error = _unsetGoalError,
    bool? isDelete,
    bool? isAdd,
    bool? isOffline,
    GoalWriteResult? lastContribution,
    bool clearContribution = false,
  }) {
    return GoalState(
      isLoading: isLoading ?? this.isLoading,
      goals: goals ?? this.goals,
      error: identical(error, _unsetGoalError) ? this.error : error as String?,
      isDelete: isDelete ?? this.isDelete,
      isAdd: isAdd ?? this.isAdd,
      isOffline: isOffline ?? this.isOffline,
      lastContribution:
          clearContribution ? null : (lastContribution ?? this.lastContribution),
    );
  }
}

class GoalViewmodel extends StateNotifier<GoalState> {
  final SyncedGoalsRepository _repository = getIt<SyncedGoalsRepository>();

  GoalViewmodel() : super(GoalState());

  Future<void> getAllGoals() async {
    state = state.copyWith(isLoading: true, error: null, clearContribution: true);

    try {
      final result = await _repository.getGoals();
      state = state.copyWith(
        isLoading: false,
        goals: result.goals,
        isOffline: result.isOffline,
      );
    } on ApiException catch (e) {
      devLog(e.message);
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      devLog(e.toString());
      state = state.copyWith(
        isLoading: false,
        error: GoalStrings.updateFailed,
      );
    }
  }

  Future<void> addNewGoal({
    required String name,
    required double target,
    required double currentAmount,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    String? imageSourcePath,
  }) async {
    final result = await _repository.createGoal(
      name: name,
      target: target,
      currentAmount: currentAmount,
      type: type,
      startDate: startDate,
      endDate: endDate,
      imageSourcePath: imageSourcePath,
    );

    result.fold(
      (failure) => state = state.copyWith(error: failure.userFacingMessage),
      (sync) => state = state.copyWith(
        isAdd: true,
        error: sync.queuedOffline ? GoalStrings.savedOffline : null,
      ),
    );
  }

  Future<void> deleteGoal(int id) async {
    final result = await _repository.deleteGoal(id);
    result.fold(
      (_) {},
      (sync) {
        if (sync.deleted) {
          final updated = state.goals.where((g) => g.id != id).toList();
          state = state.copyWith(goals: updated, isDelete: true);
        }
      },
    );
  }

  Future<GoalWriteResult?> addContribution({
    required int goalId,
    required double amount,
    String? note,
  }) async {
    final result = await _repository.addContribution(
      goalId: goalId,
      amount: amount,
      note: note,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.userFacingMessage);
        return null;
      },
      (sync) {
        final writeResult = sync.result;
        final updated = state.goals
            .map(
              (g) => g.id == goalId ? writeResult.goal : g,
            )
            .toList();
        state = state.copyWith(
          goals: updated,
          lastContribution: writeResult,
          error: sync.queuedOffline ? GoalStrings.savedOffline : null,
        );
        return writeResult;
      },
    );
  }
}

final goalViewmodelProvider =
    StateNotifierProvider.autoDispose<GoalViewmodel, GoalState>((ref) {
  return GoalViewmodel()..getAllGoals();
});
