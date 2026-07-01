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
    final requiredMonthly = requiredMonthlySavings(
      remaining: remaining,
      now: now,
      endDate: endDate,
    );

    if (daysToDeadline < 0) {
      return GoalEtaResult(
        status: GoalTrackStatus.overdue,
        daysToDeadline: daysToDeadline,
        requiredMonthlyToDeadline: requiredMonthly,
      );
    }

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

  /// Calendar months from [from] until [to] (minimum 1 when [to] is still ahead).
  static int monthsRemainingUntil(DateTime from, DateTime to) {
    if (!to.isAfter(from)) return 0;
    var months = (to.year - from.year) * 12 + (to.month - from.month);
    if (to.day < from.day) months--;
    return months < 1 ? 1 : months;
  }

  /// (remaining amount) ÷ (months left until deadline).
  static double requiredMonthlySavings({
    required double remaining,
    required DateTime now,
    required DateTime endDate,
  }) {
    if (remaining <= 0) return 0;
    final months = monthsRemainingUntil(now, endDate);
    if (months <= 0) return remaining;
    return remaining / months;
  }
}
