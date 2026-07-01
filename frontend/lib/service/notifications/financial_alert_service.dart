import 'package:mudabbir/core/utils/notification_content.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
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

  Future<void> maybeNotifyBudgetUsage(
    BudgetSnapshot? snapshot, {
    String? categoryName,
  }) async {
    final level = budgetAlertLevel(snapshot);
    if (level == BudgetAlertLevel.none || snapshot == null) return;

    final lang = AppStrings.isEnglishLocale ? 'en' : 'ar';
    final isExceeded = level == BudgetAlertLevel.exceeded;
    final pct =
        (snapshot.spentAmount / snapshot.budgetAmount * 100).round().clamp(0, 999);
    final category = categoryName?.trim().isNotEmpty == true
        ? categoryName!.trim()
        : (lang == 'ar' ? 'الميزانية' : 'Budget');

    final Map<String, String> content;
    if (isExceeded) {
      content = {
        'title': AppStrings.notificationBudgetExceededTitle,
        'body': AppStrings.notificationBudgetExceededBody(
          snapshot.spentAmount,
          snapshot.budgetAmount,
        ),
      };
    } else {
      content = NotificationContent.budgetWarning(category, pct, lang);
    }

    await LocalNotificationService.instance.show(
      id: 1000 + (isExceeded ? 1 : 0),
      title: content['title']!,
      body: content['body']!,
      channelId: LocalNotificationService.budgetChannelId,
    );
  }

  Future<void> notifyGoalCompleted(String goalName) async {
    await LocalNotificationService.instance.show(
      id: 2001,
      title: AppStrings.goalCompletedAlertTitle,
      body: AppStrings.goalCompletedAlertBody(goalName),
      channelId: LocalNotificationService.goalChannelId,
    );
  }
}
