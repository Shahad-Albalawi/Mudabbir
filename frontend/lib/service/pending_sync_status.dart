import 'package:mudabbir/data/local/budget_hive_cache.dart';
import 'package:mudabbir/data/local/expense_hive_cache.dart';
import 'package:mudabbir/data/local/goal_hive_cache.dart';
import 'package:mudabbir/service/getit_init.dart';

/// Counts queued offline operations across expense, goal, and budget caches.
int pendingSyncOperationCount() {
  var count = 0;
  count += getIt<ExpenseHiveCache>().getPendingOps().length;
  count += getIt<GoalHiveCache>().getPendingOps().length;
  count += getIt<BudgetHiveCache>().getPendingOps().length;
  return count;
}
