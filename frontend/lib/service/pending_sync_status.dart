import 'package:mudabbir/core/providers/app_providers.dart';
import 'package:mudabbir/core/providers/provider_reader.dart';

/// Counts queued offline operations across expense, goal, and budget caches.
int pendingSyncOperationCount() {
  var count = 0;
  count += readApp(expenseHiveCacheProvider).getPendingOps().length;
  count += readApp(goalHiveCacheProvider).getPendingOps().length;
  count += readApp(budgetHiveCacheProvider).getPendingOps().length;
  return count;
}
