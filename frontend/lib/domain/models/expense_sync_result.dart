import 'package:mudabbir/domain/models/expense_transaction.dart';

class ExpenseListSyncResult {
  final List<ExpenseTransaction> expenses;
  final bool fromCache;
  final bool isOffline;

  const ExpenseListSyncResult({
    required this.expenses,
    this.fromCache = false,
    this.isOffline = false,
  });
}

class ExpenseWriteSyncResult {
  final ExpenseWriteResult result;
  final bool syncedToServer;
  final bool queuedOffline;

  const ExpenseWriteSyncResult({
    required this.result,
    this.syncedToServer = true,
    this.queuedOffline = false,
  });
}

class ExpenseDeleteSyncResult {
  final bool deleted;
  final bool queuedOffline;

  const ExpenseDeleteSyncResult({
    required this.deleted,
    this.queuedOffline = false,
  });
}
