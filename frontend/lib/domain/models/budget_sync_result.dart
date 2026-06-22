import 'package:mudabbir/domain/models/budget_record.dart';

class BudgetListSyncResult {
  final List<BudgetRecord> budgets;
  final bool fromCache;
  final bool isOffline;

  const BudgetListSyncResult({
    required this.budgets,
    this.fromCache = false,
    this.isOffline = false,
  });
}

class BudgetCreateSyncResult {
  final BudgetRecord budget;
  final bool syncedToServer;
  final bool queuedOffline;

  const BudgetCreateSyncResult({
    required this.budget,
    this.syncedToServer = true,
    this.queuedOffline = false,
  });
}

class BudgetDeleteSyncResult {
  final bool deleted;
  final bool syncedToServer;
  final bool queuedOffline;

  const BudgetDeleteSyncResult({
    required this.deleted,
    this.syncedToServer = true,
    this.queuedOffline = false,
  });
}
