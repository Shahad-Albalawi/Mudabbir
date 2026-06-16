import 'package:mudabbir/domain/repository/goals_repository/goals_repository.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';

class GoalListSyncResult {
  final List<SavingsGoal> goals;
  final bool fromCache;
  final bool isOffline;

  const GoalListSyncResult({
    required this.goals,
    this.fromCache = false,
    this.isOffline = false,
  });
}

class GoalWriteSyncResult {
  final GoalWriteResult result;
  final bool syncedToServer;
  final bool queuedOffline;

  const GoalWriteSyncResult({
    required this.result,
    this.syncedToServer = true,
    this.queuedOffline = false,
  });
}

class GoalCreateSyncResult {
  final SavingsGoal goal;
  final bool syncedToServer;
  final bool queuedOffline;

  const GoalCreateSyncResult({
    required this.goal,
    this.syncedToServer = true,
    this.queuedOffline = false,
  });
}

class GoalDeleteSyncResult {
  final bool deleted;
  final bool syncedToServer;
  final bool queuedOffline;

  const GoalDeleteSyncResult({
    required this.deleted,
    this.syncedToServer = true,
    this.queuedOffline = false,
  });
}
