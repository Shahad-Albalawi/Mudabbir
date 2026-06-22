// Pure sync helpers for offline-first repositories (pruning + LWW timestamps).

/// Returns local row ids that should be removed after a server pull.
Set<int> idsToPrune({
  required Iterable<int> localIds,
  required Set<int> serverIds,
  required Set<int> protectedIds,
}) {
  final prune = <int>{};
  for (final id in localIds) {
    if (protectedIds.contains(id)) continue;
    if (!serverIds.contains(id)) {
      prune.add(id);
    }
  }
  return prune;
}

/// Collects ids that must not be pruned while a pending op is queued.
Set<int> protectedExpenseIdsFromOps(List<Map<String, dynamic>> ops) {
  final protected = <int>{};
  for (final op in ops) {
    final type = op['op'] as String?;
    if (type == 'create') {
      final localId = op['local_id'];
      if (localId is int) protected.add(localId);
    } else if (type == 'update' || type == 'delete') {
      final serverId = op['server_id'];
      if (serverId is int) protected.add(serverId);
    }
  }
  return protected;
}

Set<int> protectedGoalIdsFromOps(List<Map<String, dynamic>> ops) {
  final protected = <int>{};
  for (final op in ops) {
    final type = op['op'] as String?;
    if (type == 'create_goal') {
      final localId = op['local_goal_id'];
      if (localId is int) protected.add(localId);
    } else if (type == 'add_contribution' || type == 'delete_goal' || type == 'update_goal') {
      final goalId = op['goal_id'];
      if (goalId is int) protected.add(goalId);
    }
  }
  return protected;
}

Set<int> protectedBudgetIdsFromOps(List<Map<String, dynamic>> ops) {
  final protected = <int>{};
  for (final op in ops) {
    final type = op['op'] as String?;
    if (type == 'create_budget') {
      final localId = op['local_budget_id'];
      if (localId is int) protected.add(localId);
    } else if (type == 'delete_budget') {
      final budgetId = op['budget_id'];
      if (budgetId is int) protected.add(budgetId);
    }
  }
  return protected;
}

/// True when [serverUpdatedAt] is strictly newer than [clientUpdatedAt].
bool isServerNewer({
  required String? serverUpdatedAt,
  required String? clientUpdatedAt,
}) {
  if (clientUpdatedAt == null || clientUpdatedAt.isEmpty) {
    return false;
  }
  final server = DateTime.tryParse(serverUpdatedAt ?? '');
  final client = DateTime.tryParse(clientUpdatedAt);
  if (server == null || client == null) {
    return false;
  }
  return server.isAfter(client);
}

/// Rewrites queued goal ops that still reference a provisional local goal id.
void remapGoalIdInPendingOps(
  List<Map<String, dynamic>> ops, {
  required int localGoalId,
  required int serverGoalId,
}) {
  for (final op in ops) {
    if (op['goal_id'] == localGoalId) {
      op['goal_id'] = serverGoalId;
    }
    if (op['local_goal_id'] == localGoalId) {
      op['local_goal_id'] = serverGoalId;
    }
  }
}

void remapBudgetIdInPendingOps(
  List<Map<String, dynamic>> ops, {
  required int localBudgetId,
  required int serverBudgetId,
}) {
  for (final op in ops) {
    if (op['budget_id'] == localBudgetId) {
      op['budget_id'] = serverBudgetId;
    }
    if (op['local_budget_id'] == localBudgetId) {
      op['local_budget_id'] = serverBudgetId;
    }
  }
}

/// Filters cached expense rows (Hive/API JSON) for list queries while offline.
List<Map<String, dynamic>> filterCachedExpenseMaps(
  List<Map<String, dynamic>> cached, {
  required String type,
  String? monthKey,
  int? categoryId,
  bool recurringOnly = false,
}) {
  return cached.where((row) {
    if (row['type'] != type) return false;
    final date = row['date']?.toString() ?? '';
    if (monthKey != null &&
        monthKey.isNotEmpty &&
        !date.startsWith(monthKey)) {
      return false;
    }
    if (categoryId != null && row['category_id'] != categoryId) return false;
    if (recurringOnly) {
      final recurring = row['is_recurring'];
      if (recurring != 1 && recurring != true) return false;
    }
    return true;
  }).toList();
}
