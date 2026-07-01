import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/local/goal_hive_cache.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/data/remote/goal_api_service.dart';
import 'package:mudabbir/domain/models/goal_sync_result.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/domain/repository/goals_repository/goals_repository.dart';
import 'package:mudabbir/domain/services/sync_policies.dart';
import 'package:mudabbir/domain/services/sync_flush_lock.dart';
import 'package:mudabbir/domain/services/repository_guard.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/data/network/api_exception.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/utils/api_session.dart';

/// Offline-first sync between Laravel goals API, Hive cache, and SQLite.
class SyncedGoalsRepository {
  final GoalsRepository _local;
  final GoalApiService _remote;
  final GoalHiveCache _cache;

  SyncedGoalsRepository({
    GoalsRepository? local,
    GoalApiService? remote,
    GoalHiveCache? cache,
  })  : _local = local ?? getIt<GoalsRepository>(),
        _remote = remote ?? getIt<GoalApiService>(),
        _cache = cache ?? getIt<GoalHiveCache>();

  Future<GoalListSyncResult> getGoals() {
    return guardSyncedOperation(() async {
      final cached = _cache.getGoalsList();

      if (!await hasApiSession()) {
        final local = await _local.getGoals();
        return local.fold(
          (_) => GoalListSyncResult(
            goals: cached?.map(_goalFromCacheMap).toList() ?? const [],
          ),
          (data) => GoalListSyncResult(goals: data),
        );
      }

      try {
        await flushPendingOps();
        final remote = await _remote.getGoals();
        await _pruneFromServerSnapshot(remote);
        await _local.mergeServerGoals(remote);
        await _cache.saveGoalsList(
          remote.map((g) => _goalToCacheMap(g)).toList(),
        );

        final local = await _local.getGoals();
        return GoalListSyncResult(goals: local.getOrElse(() => []));
      } on ApiException catch (e) {
        if (e.isNetworkError || e.statusCode == 401) {
          if (cached != null) {
            return GoalListSyncResult(
              goals: cached.map(_goalFromCacheMap).toList(),
              fromCache: true,
              isOffline: true,
            );
          }

          final local = await _local.getGoals();
          return local.fold(
            (_) => const GoalListSyncResult(goals: [], isOffline: true),
            (data) => GoalListSyncResult(
              goals: data,
              fromCache: true,
              isOffline: true,
            ),
          );
        }
        rethrow;
      }
    }, fallbackMessage: AppStrings.goalLoadFailed);
  }

  Future<Either<Failure, GoalCreateSyncResult>> createGoal({
    required String name,
    required double target,
    required double currentAmount,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    String? imageSourcePath,
  }) {
    return guardRepository(() async {
      try {
        final remote = await _remote.createGoal({
          'name': name.trim(),
          'target': target,
          'current_amount': currentAmount,
          'type': type,
          'start_date': _isoDate(startDate),
          'end_date': _isoDate(endDate),
        });
        await _cache.upsertGoal(_goalToCacheMap(remote));
        await _local.mergeServerGoals([remote]);

        return GoalCreateSyncResult(goal: remote);
      } on ApiException catch (e) {
        if (!e.isNetworkError) throw RepositoryException(e.userMessage);

        final localResult = await _local.createGoal(
          name: name,
          target: target,
          currentAmount: currentAmount,
          type: type,
          startDate: startDate,
          endDate: endDate,
          imageSourcePath: imageSourcePath,
        );

        return localResult.fold(
          (failure) => throw RepositoryException(failure.userFacingMessage),
          (goal) async {
            await _cache.upsertGoal(_goalToCacheMap(goal));
            await _cache.queueOp({
              'op': 'create_goal',
              'local_goal_id': goal.id,
              'payload': {
                'name': name.trim(),
                'target': target,
                'current_amount': currentAmount,
                'type': type,
                'start_date': _isoDate(startDate),
                'end_date': _isoDate(endDate),
              },
              'queued_at': DateTime.now().toIso8601String(),
            });
            return GoalCreateSyncResult(
              goal: goal,
              syncedToServer: false,
              queuedOffline: true,
            );
          },
        );
      }
    }, fallbackMessage: AppStrings.goalSyncFailed);
  }

  Future<Either<Failure, GoalUpdateSyncResult>> updateGoal({
    required int goalId,
    required String name,
    required double target,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    String? imageSourcePath,
    String? updatedAt,
  }) {
    final payload = {
      'name': name.trim(),
      'target': target,
      'type': type,
      'start_date': _isoDate(startDate),
      'end_date': _isoDate(endDate),
      if (updatedAt != null) 'updated_at': updatedAt,
    };

    return guardRepository(() async {
      try {
        final remote = await _remote.updateGoal(goalId, payload);
        await _cache.upsertGoal(_goalToCacheMap(remote));
        await _local.mergeServerGoals([remote]);
        return GoalUpdateSyncResult(goal: remote);
      } on ApiException catch (e) {
        if (e.isConflict && e.conflictData is Map) {
          final server = _goalFromCacheMap(
            Map<String, dynamic>.from(e.conflictData as Map),
          );
          await _cache.upsertGoal(_goalToCacheMap(server));
          await _local.mergeServerGoals([server]);
          return GoalUpdateSyncResult(goal: server, syncedToServer: false);
        }
        if (!e.isNetworkError) throw RepositoryException(e.userMessage);

        final localResult = await _local.updateGoal(
          goalId: goalId,
          name: name,
          target: target,
          type: type,
          startDate: startDate,
          endDate: endDate,
          imageSourcePath: imageSourcePath,
        );

        return localResult.fold(
          (failure) => throw RepositoryException(failure.userFacingMessage),
          (goal) async {
            await _cache.upsertGoal(_goalToCacheMap(goal));
            await _cache.queueOp({
              'op': 'update_goal',
              'goal_id': goalId,
              'payload': payload,
              'queued_at': DateTime.now().toIso8601String(),
            });
            return GoalUpdateSyncResult(
              goal: goal,
              syncedToServer: false,
              queuedOffline: true,
            );
          },
        );
      }
    }, fallbackMessage: AppStrings.goalSyncFailed);
  }

  Future<Either<Failure, GoalWriteSyncResult>> addContribution({
    required int goalId,
    required double amount,
    String? note,
  }) {
    return guardRepository(() async {
      try {
        final remote = await _remote.addContribution(
          goalId: goalId,
          amount: amount,
          note: note,
        );
        await _cache.upsertGoal(_goalToCacheMap(remote));
        await _local.mergeServerGoals([remote]);

        final previous = await _local.getGoalById(goalId);
        final newlyCompleted = previous.fold(
          (_) => false,
          (g) => remote.isCompleted && !g.isCompleted,
        );

        return GoalWriteSyncResult(
          result: GoalWriteResult(
            goal: remote,
            newlyCompleted: newlyCompleted,
          ),
        );
      } on ApiException catch (e) {
        if (!e.isNetworkError) throw RepositoryException(e.userMessage);

        final localResult = await _local.addContribution(
          goalId: goalId,
          amount: amount,
          note: note,
        );

        return localResult.fold(
          (failure) => throw RepositoryException(failure.userFacingMessage),
          (write) async {
            await _cache.upsertGoal(_goalToCacheMap(write.goal));
            await _cache.queueOp({
              'op': 'add_contribution',
              'goal_id': goalId,
              'payload': {
                'amount': amount,
                if (note != null) 'note': note,
              },
              'queued_at': DateTime.now().toIso8601String(),
            });
            return GoalWriteSyncResult(
              result: write,
              syncedToServer: false,
              queuedOffline: true,
            );
          },
        );
      }
    }, fallbackMessage: AppStrings.goalSyncFailed);
  }

  Future<Either<Failure, GoalDeleteSyncResult>> deleteGoal(int id) {
    return guardRepository(() async {
      try {
        await _remote.deleteGoal(id);
        await _cache.removeGoal(id);
        final local = await _local.deleteGoal(id);
        return local.fold(
          (failure) => throw RepositoryException(failure.userFacingMessage),
          (ok) => GoalDeleteSyncResult(deleted: ok),
        );
      } on ApiException catch (e) {
        if (!e.isNetworkError) throw RepositoryException(e.userMessage);

        final local = await _local.deleteGoal(id);
        return local.fold(
          (failure) => throw RepositoryException(failure.userFacingMessage),
          (ok) async {
            if (ok) {
              await _cache.removeGoal(id);
              await _cache.queueOp({
                'op': 'delete_goal',
                'goal_id': id,
                'queued_at': DateTime.now().toIso8601String(),
              });
            }
            return GoalDeleteSyncResult(
              deleted: ok,
              syncedToServer: false,
              queuedOffline: ok,
            );
          },
        );
      }
    }, fallbackMessage: AppStrings.goalSyncFailed);
  }

  Future<void> flushPendingOps() async {
    await SyncFlushLock.run(() async {
      final ops = _cache.getPendingOps();
      if (ops.isEmpty) return;

      final remaining = <Map<String, dynamic>>[];
      for (var i = 0; i < ops.length; i++) {
        final op = ops[i];
        try {
          final type = op['op'] as String?;
          if (type == 'create_goal') {
          final payload = Map<String, dynamic>.from(op['payload'] as Map);
          final remote = await _remote.createGoal(payload);
          await _cache.upsertGoal(_goalToCacheMap(remote));
          final localId = op['local_goal_id'] as int?;
          if (localId != null) {
            await _local.replaceLocalGoalId(localId, remote);
            await _cache.removeGoal(localId);
            await _cache.upsertGoal(_goalToCacheMap(remote));
            final tail = ops.sublist(i + 1)..addAll(remaining);
            remapGoalIdInPendingOps(
              tail,
              localGoalId: localId,
              serverGoalId: remote.id,
            );
          } else {
            await _local.mergeServerGoals([remote]);
          }
        } else if (type == 'add_contribution') {
          final goalId = op['goal_id'] as int;
          final payload = Map<String, dynamic>.from(op['payload'] as Map);
          final remote = await _remote.addContribution(
            goalId: goalId,
            amount: (payload['amount'] as num).toDouble(),
            note: payload['note'] as String?,
          );
          await _cache.upsertGoal(_goalToCacheMap(remote));
          await _local.mergeServerGoals([remote]);
        } else if (type == 'update_goal') {
          final goalId = op['goal_id'] as int;
          final payload = Map<String, dynamic>.from(op['payload'] as Map);
          final remote = await _remote.updateGoal(goalId, payload);
          await _cache.upsertGoal(_goalToCacheMap(remote));
          await _local.mergeServerGoals([remote]);
        } else if (type == 'delete_goal') {
          final goalId = op['goal_id'] as int;
          await _remote.deleteGoal(goalId);
          await _cache.removeGoal(goalId);
          await _local.deleteGoal(goalId);
        }
        } on ApiException catch (e) {
          if (shouldRetainPendingOp(error: e, opType: op['op'] as String?)) {
            remaining.add(op);
          }
        } catch (_) {
          remaining.add(op);
        }
      }
      await _cache.setPendingOps(remaining);
    });
  }

  Future<void> _pruneFromServerSnapshot(List<SavingsGoal> remote) async {
    final serverIds = remote.map((g) => g.id).toSet();
    final protected = protectedGoalIdsFromOps(_cache.getPendingOps());
    await _local.pruneExceptServerIds(serverIds, protected);
  }

  Map<String, dynamic> _goalToCacheMap(SavingsGoal goal) {
    return {
      'id': goal.id,
      'name': goal.name,
      'target': goal.target,
      'current_amount': goal.currentAmount,
      'type': goal.type,
      'start_date': _isoDate(goal.startDate),
      'end_date': _isoDate(goal.endDate),
      'image_path': goal.imagePath,
      'is_completed': goal.isCompleted,
      'completed_at': goal.completedAt?.toIso8601String(),
      'contributions': goal.contributions
          .map(
            (c) => {
              'id': c.id,
              'goal_id': c.goalId,
              'amount': c.amount,
              'contributed_at': c.contributedAt.toIso8601String(),
              'note': c.note,
            },
          )
          .toList(),
    };
  }

  SavingsGoal _goalFromCacheMap(Map<String, dynamic> map) {
    final contributions = <GoalContributionRecord>[];
    final raw = map['contributions'];
    if (raw is List) {
      for (final item in raw) {
        if (item is! Map) continue;
        final c = Map<String, dynamic>.from(item);
        contributions.add(
          GoalContributionRecord(
            id: (c['id'] as num).toInt(),
            goalId: (c['goal_id'] as num).toInt(),
            amount: (c['amount'] as num).toDouble(),
            contributedAt: DateTime.parse(c['contributed_at'] as String),
            note: c['note'] as String?,
          ),
        );
      }
    }

    final normalized = Map<String, dynamic>.from(map);
    normalized['is_completed'] =
        map['is_completed'] == true ? 1 : (map['is_completed'] as int? ?? 0);

    return SavingsGoal.fromMap(normalized, contributions: contributions);
  }

  String _isoDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

