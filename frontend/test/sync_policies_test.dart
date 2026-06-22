import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/domain/services/sync_policies.dart';

void main() {
  group('sync_policies', () {
    test('idsToPrune removes synced rows missing on server', () {
      final prune = idsToPrune(
        localIds: [1, 2, 3, 99],
        serverIds: {1, 3},
        protectedIds: {},
      );
      expect(prune, {2, 99});
    });

    test('protectedExpenseIdsFromOps keeps pending create local ids', () {
      final protected = protectedExpenseIdsFromOps([
        {'op': 'create', 'local_id': 99},
        {'op': 'update', 'server_id': 3},
        {'op': 'delete', 'server_id': 7},
      ]);
      expect(protected, {99, 3, 7});
    });

    test('isServerNewer detects stale client timestamp', () {
      expect(
        isServerNewer(
          serverUpdatedAt: '2025-05-10T12:00:00.000000Z',
          clientUpdatedAt: '2025-05-10T11:00:00.000000Z',
        ),
        isTrue,
      );
      expect(
        isServerNewer(
          serverUpdatedAt: '2025-05-10T11:00:00.000000Z',
          clientUpdatedAt: '2025-05-10T12:00:00.000000Z',
        ),
        isFalse,
      );
    });

    test('remapGoalIdInPendingOps rewrites queued contribution goal ids', () {
      final ops = <Map<String, dynamic>>[
        {'op': 'add_contribution', 'goal_id': 5},
        {'op': 'delete_goal', 'goal_id': 5},
      ];
      remapGoalIdInPendingOps(ops, localGoalId: 5, serverGoalId: 42);
      expect(ops[0]['goal_id'], 42);
      expect(ops[1]['goal_id'], 42);
    });
    test('idsToPrune keeps pending offline create ids', () {
      final prune = idsToPrune(
        localIds: [7, 8],
        serverIds: {101},
        protectedIds: {7},
      );
      expect(prune, {8});
    });

    test('protectedGoalIdsFromOps covers create and contribution ops', () {
      final protected = protectedGoalIdsFromOps([
        {'op': 'create_goal', 'local_goal_id': 12},
        {'op': 'add_contribution', 'goal_id': 12},
      ]);
      expect(protected, {12});
    });

    test('protectedBudgetIdsFromOps covers create and delete ops', () {
      final protected = protectedBudgetIdsFromOps([
        {'op': 'create_budget', 'local_budget_id': 9},
        {'op': 'delete_budget', 'budget_id': 3},
      ]);
      expect(protected, {9, 3});
    });

    test('remapBudgetIdInPendingOps rewrites queued delete budget ids', () {
      final ops = <Map<String, dynamic>>[
        {'op': 'delete_budget', 'budget_id': 5},
      ];
      remapBudgetIdInPendingOps(ops, localBudgetId: 5, serverBudgetId: 88);
      expect(ops[0]['budget_id'], 88);
    });

    test('filterCachedExpenseMaps filters by type month and category', () {
      final cached = [
        {
          'id': 1,
          'type': 'expense',
          'date': '2025-06-15',
          'category_id': 2,
          'is_recurring': 0,
        },
        {
          'id': 2,
          'type': 'income',
          'date': '2025-06-20',
          'category_id': 1,
          'is_recurring': 0,
        },
        {
          'id': 3,
          'type': 'expense',
          'date': '2025-07-01',
          'category_id': 2,
          'is_recurring': 1,
        },
      ];

      final juneExpenses = filterCachedExpenseMaps(
        cached,
        type: 'expense',
        monthKey: '2025-06',
      );
      expect(juneExpenses.map((e) => e['id']), [1]);

      final cat2 = filterCachedExpenseMaps(
        cached,
        type: 'expense',
        categoryId: 2,
      );
      expect(cat2.map((e) => e['id']), [1, 3]);

      final recurring = filterCachedExpenseMaps(
        cached,
        type: 'expense',
        recurringOnly: true,
      );
      expect(recurring.map((e) => e['id']), [3]);
    });
  });
}
