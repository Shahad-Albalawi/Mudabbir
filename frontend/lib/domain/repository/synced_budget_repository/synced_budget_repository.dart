import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/local/budget_hive_cache.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/data/remote/budget_api_service.dart';
import 'package:mudabbir/domain/models/budget_record.dart';
import 'package:mudabbir/domain/models/budget_sync_result.dart';
import 'package:mudabbir/domain/repository/budget_repository/budget_repository.dart';
import 'package:mudabbir/domain/services/sync_policies.dart';
import 'package:mudabbir/domain/services/sync_flush_lock.dart';
import 'package:mudabbir/domain/services/repository_guard.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/data/network/api_exception.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/utils/api_session.dart';

/// Offline-first sync between Laravel budgets API, Hive cache, and SQLite.
class SyncedBudgetRepository {
  final BudgetRepository _local;
  final BudgetApiService _remote;
  final BudgetHiveCache _cache;

  SyncedBudgetRepository({
    BudgetRepository? local,
    BudgetApiService? remote,
    BudgetHiveCache? cache,
  })  : _local = local ?? getIt<BudgetRepository>(),
        _remote = remote ?? getIt<BudgetApiService>(),
        _cache = cache ?? getIt<BudgetHiveCache>();

  Future<BudgetListSyncResult> getBudgets() {
    return guardSyncedOperation(() async {
      final cached = _cache.getBudgetsList();

      if (!await hasApiSession()) {
        final local = await _local.getBudgets();
        if (cached != null && cached.isNotEmpty) {
          return BudgetListSyncResult(
            budgets: cached.map(BudgetRecord.fromMap).toList(),
          );
        }
        return BudgetListSyncResult(
          budgets: local
              .getOrElse(() => [])
              .map((m) => BudgetRecord.fromMap(m))
              .toList(),
        );
      }

      try {
        await flushPendingOps();
        final remote = await _remote.getBudgets();
        await _pruneFromServerSnapshot(remote);
        await _local.mergeServerBudgets(remote);
        await _cache.saveBudgetsList(remote.map((b) => b.toJson()).toList());

        final local = await _local.getBudgets();
        return BudgetListSyncResult(
          budgets: local
              .getOrElse(() => [])
              .map((m) => BudgetRecord.fromMap(m))
              .toList(),
        );
      } on ApiException catch (e) {
        if (e.isNetworkError) {
          if (cached != null) {
            return BudgetListSyncResult(
              budgets: cached.map(BudgetRecord.fromMap).toList(),
              fromCache: true,
              isOffline: true,
            );
          }

          final local = await _local.getBudgets();
          return local.fold(
            (_) => const BudgetListSyncResult(budgets: [], isOffline: true),
            (data) => BudgetListSyncResult(
              budgets: data.map(BudgetRecord.fromMap).toList(),
              fromCache: true,
              isOffline: true,
            ),
          );
        }
        rethrow;
      }
    }, fallbackMessage: AppStrings.budgetLoadFailed);
  }

  Future<Either<Failure, BudgetCreateSyncResult>> createBudget({
    required double amount,
    required String startDate,
    required String endDate,
    required int accountId,
  }) {
    return guardRepository(() async {
      final payload = {
        'amount': amount,
        'start_date': startDate,
        'end_date': endDate,
        'account_id': accountId,
      };

      if (!await hasApiSession()) {
        final localId = await _local.addBudget(payload);
        final localBudget = BudgetRecord(
          id: localId,
          amount: amount,
          startDate: startDate,
          endDate: endDate,
          accountId: accountId,
          updatedAt: DateTime.now().toIso8601String(),
        );
        await _cache.upsertBudget(localBudget.toJson());
        return BudgetCreateSyncResult(
          budget: localBudget,
          syncedToServer: false,
          queuedOffline: true,
        );
      }

      try {
        final remote = await _remote.createBudget(payload);
        await _cache.upsertBudget(remote.toJson());
        await _local.mergeServerBudgets([remote]);
        return BudgetCreateSyncResult(budget: remote);
      } on ApiException catch (e) {
        if (!e.isNetworkError) throw RepositoryException(e.userMessage);

        final localId = await _local.addBudget(payload);
        final localBudget = BudgetRecord(
          id: localId,
          amount: amount,
          startDate: startDate,
          endDate: endDate,
          accountId: accountId,
          updatedAt: DateTime.now().toIso8601String(),
        );
        await _cache.upsertBudget(localBudget.toJson());
        await _cache.queueOp({
          'op': 'create_budget',
          'local_budget_id': localId,
          'payload': payload,
          'queued_at': DateTime.now().toIso8601String(),
        });
        return BudgetCreateSyncResult(
          budget: localBudget,
          syncedToServer: false,
          queuedOffline: true,
        );
      }
    }, fallbackMessage: AppStrings.budgetSyncFailed);
  }

  Future<Either<Failure, BudgetDeleteSyncResult>> deleteBudget(int id) {
    return guardRepository(() async {
      try {
        await _remote.deleteBudget(id);
        await _cache.removeBudget(id);
        final local = await _local.removeBudget(id);
        return BudgetDeleteSyncResult(deleted: local == 1);
      } on ApiException catch (e) {
        if (!e.isNetworkError) throw RepositoryException(e.userMessage);

        final affected = await _local.removeBudget(id);
        if (affected == 1) {
          await _cache.removeBudget(id);
          await _cache.queueOp({
            'op': 'delete_budget',
            'budget_id': id,
            'queued_at': DateTime.now().toIso8601String(),
          });
        }
        return BudgetDeleteSyncResult(
          deleted: affected == 1,
          syncedToServer: false,
          queuedOffline: affected == 1,
        );
      }
    }, fallbackMessage: AppStrings.budgetSyncFailed);
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
          if (type == 'create_budget') {
          final payload = Map<String, dynamic>.from(op['payload'] as Map);
          final remote = await _remote.createBudget(payload);
          await _cache.upsertBudget(remote.toJson());
          final localId = op['local_budget_id'] as int?;
          if (localId != null) {
            await _local.replaceLocalBudgetId(localId, remote);
            await _cache.removeBudget(localId);
            await _cache.upsertBudget(remote.toJson());
            final tail = ops.sublist(i + 1)..addAll(remaining);
            remapBudgetIdInPendingOps(
              tail,
              localBudgetId: localId,
              serverBudgetId: remote.id,
            );
          } else {
            await _local.mergeServerBudgets([remote]);
          }
        } else if (type == 'delete_budget') {
          final budgetId = op['budget_id'] as int;
          await _remote.deleteBudget(budgetId);
          await _cache.removeBudget(budgetId);
          await _local.removeBudget(budgetId);
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

  Future<void> _pruneFromServerSnapshot(List<BudgetRecord> remote) async {
    final serverIds = remote.map((b) => b.id).toSet();
    final protected = protectedBudgetIdsFromOps(_cache.getPendingOps());
    await _local.pruneExceptServerIds(serverIds, protected);
  }
}
