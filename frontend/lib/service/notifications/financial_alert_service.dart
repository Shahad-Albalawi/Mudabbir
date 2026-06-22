import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/presentation/resources/goal_strings.dart';
import 'package:mudabbir/presentation/resources/notification_strings.dart';
import 'package:mudabbir/service/notifications/local_notification_service.dart';

enum BudgetAlertLevel { none, warning, exceeded }

BudgetAlertLevel budgetAlertLevel(BudgetSnapshot? snapshot) {
  if (snapshot == null || snapshot.budgetAmount <= 0) {
    return BudgetAlertLevel.none;
  }
  if (snapshot.isOverBudget) return BudgetAlertLevel.exceeded;
  final ratio = snapshot.spentAmount / snapshot.budgetAmount;
  if (ratio >= 0.8) return BudgetAlertLevel.warning;
  return BudgetAlertLevel.none;
}

/// Shows local notifications for budget thresholds and completed goals.
class FinancialAlertService {
  FinancialAlertService._();
  static final FinancialAlertService instance = FinancialAlertService._();

  Future<void> maybeNotifyBudgetUsage(BudgetSnapshot? snapshot) async {
    final level = budgetAlertLevel(snapshot);
    if (level == BudgetAlertLevel.none || snapshot == null) return;

    final isExceeded = level == BudgetAlertLevel.exceeded;
    await LocalNotificationService.instance.show(
      id: 1000 + (isExceeded ? 1 : 0),
      title: isExceeded
          ? NotificationStrings.budgetExceededTitle
          : NotificationStrings.budgetWarningTitle,
      body: isExceeded
          ? NotificationStrings.budgetExceededBody(
              snapshot.spentAmount,
              snapshot.budgetAmount,
            )
          : NotificationStrings.budgetWarningBody(
              snapshot.spentAmount,
              snapshot.budgetAmount,
            ),
      channelId: LocalNotificationService.budgetChannelId,
    );
  }

  Future<void> notifyGoalCompleted(String goalName) async {
    await LocalNotificationService.instance.show(
      id: 2001,
      title: GoalStrings.completedAlertTitle,
      body: GoalStrings.completedAlertBody(goalName),
      channelId: LocalNotificationService.goalChannelId,
    );
  }
}
