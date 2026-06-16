import 'package:mudabbir/domain/models/savings_goal.dart';

/// Pure logic for savings goal progress and projected completion dates.
class GoalProgressEngine {
  GoalProgressEngine._();

  static GoalEtaResult computeEta({
    required double currentAmount,
    required double targetAmount,
    required DateTime startDate,
    required DateTime endDate,
    required List<GoalContributionRecord> contributions,
    required bool isCompleted,
    required DateTime now,
  }) {
    if (isCompleted || currentAmount >= targetAmount) {
      return const GoalEtaResult(status: GoalTrackStatus.completed);
    }

    final remaining = targetAmount - currentAmount;
    final daysToDeadline = endDate.difference(now).inDays;

    if (daysToDeadline < 0) {
      return GoalEtaResult(
        status: GoalTrackStatus.overdue,
        daysToDeadline: daysToDeadline,
        requiredMonthlyToDeadline: remaining,
      );
    }

    final requiredMonthly = daysToDeadline > 0
        ? remaining / (daysToDeadline / 30.0)
        : remaining;

    if (contributions.isEmpty) {
      return GoalEtaResult(
        status: GoalTrackStatus.noData,
        daysToDeadline: daysToDeadline,
        requiredMonthlyToDeadline: requiredMonthly,
        projectedDate: endDate,
      );
    }

    final totalContributed =
        contributions.fold(0.0, (sum, c) => sum + c.amount);
    final earliest = contributions
        .map((c) => c.contributedAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final daysActive = now.difference(earliest).inDays.clamp(1, 9999);
    final dailyRate = totalContributed / daysActive;
    final avgMonthly = dailyRate * 30;

    DateTime? projected;
    if (dailyRate > 0) {
      projected = now.add(Duration(days: (remaining / dailyRate).ceil()));
    }

    GoalTrackStatus status;
    if (projected == null) {
      status = GoalTrackStatus.noData;
    } else if (!projected.isAfter(endDate)) {
      status = GoalTrackStatus.onTrack;
    } else {
      status = GoalTrackStatus.behind;
    }

    return GoalEtaResult(
      status: status,
      projectedDate: projected ?? endDate,
      avgMonthlyContribution: avgMonthly,
      requiredMonthlyToDeadline: requiredMonthly,
      daysToDeadline: daysToDeadline,
    );
  }
}
