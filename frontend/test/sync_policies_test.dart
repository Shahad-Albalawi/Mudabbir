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
  });
}
