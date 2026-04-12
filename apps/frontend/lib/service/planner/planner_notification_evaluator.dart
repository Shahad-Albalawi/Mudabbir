import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/domain/repository/goals_repository/goals_repository.dart';
import 'package:mudabbir/domain/repository/planner_repository/planner_repository.dart';
import 'package:mudabbir/persentation/resources/planner_strings.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/planner/planner_local_notification_service.dart';

/// Fires deduped local notifications after financial summary load.
class PlannerNotificationEvaluator {
  PlannerNotificationEvaluator._();

  static Future<void> run({
    required double monthlyExpense,
    required double previousMonthExpense,
  }) async {
    await PlannerLocalNotificationService.instance.initialize();

    final hive = getIt<HiveService>();
    final now = DateTime.now();
    final ym = '${now.year}_${now.month.toString().padLeft(2, '0')}';

    // Spending higher than last month (≥25%) — once per month
    if (previousMonthExpense > 0) {
      final growth =
          (monthlyExpense - previousMonthExpense) / previousMonthExpense;
      if (growth >= 0.25) {
        final key = 'planner_notif_spike_$ym';
        if (hive.getValue(key) != true) {
          await hive.setValue(key, true);
          await PlannerLocalNotificationService.instance.show(
            id: 91001,
            title: PlannerStrings.notifSpendingHigh,
            body: '',
          );
        }
      }
    }

    // Category budgets ≥80% — one notif per category per month
    final planner = getIt<PlannerRepository>();
    final lines = await planner.categoryBudgetAlertLines(now, 80);
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final key = 'planner_notif_cat80_${line.hashCode}_$ym';
      if (hive.getValue(key) == true) continue;
      await hive.setValue(key, true);
      await PlannerLocalNotificationService.instance.show(
        id: 92000 + i,
        title: PlannerStrings.notifBudgetHigh(line),
        body: '',
      );
    }

    // Savings goal near completion (≥80% of target)
    final goalsEither = await getIt<GoalsRepository>().getGoals();
    await goalsEither.fold<Future<void>>(
      (_) async {},
      (rows) async {
        var idx = 0;
        for (final g in rows) {
          final target = (g['target'] as num?)?.toDouble() ?? 0;
          final current = (g['current_amount'] as num?)?.toDouble() ?? 0;
          final name = g['name']?.toString() ?? '';
          if (target <= 0) continue;
          final ratio = current / target;
          if (ratio >= 0.8 && ratio < 1.0) {
            final id = g['id'];
            final key = 'planner_notif_goal_near_${id}_$ym';
            if (hive.getValue(key) == true) continue;
            await hive.setValue(key, true);
            await PlannerLocalNotificationService.instance.show(
              id: 93000 + idx,
              title: PlannerStrings.notifNearGoal(name),
              body: '',
            );
          }
          idx++;
        }
      },
    );

    // Weekly impulse nudge (approx. week bucket)
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final weekKey = 'planner_impulse_${now.year}_w${dayOfYear ~/ 7}';
    if (hive.getValue(weekKey) != true && monthlyExpense > 0) {
      await hive.setValue(weekKey, true);
      await PlannerLocalNotificationService.instance.show(
        id: 94001,
        title: PlannerStrings.notifImpulse,
        body: '',
      );
    }
  }
}
