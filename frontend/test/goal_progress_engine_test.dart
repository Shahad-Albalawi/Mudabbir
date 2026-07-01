import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/domain/services/goal_progress_engine.dart';

void main() {
  group('GoalProgressEngine', () {
    final now = DateTime(2026, 5, 15);
    final start = DateTime(2026, 1, 1);
    final end = DateTime(2026, 12, 31);

    test('marks completed goals', () {
      final eta = GoalProgressEngine.computeEta(
        currentAmount: 10000,
        targetAmount: 10000,
        startDate: start,
        endDate: end,
        contributions: const [],
        isCompleted: true,
        now: now,
      );
      expect(eta.status, GoalTrackStatus.completed);
    });

    test('projects date from contribution pace', () {
      final eta = GoalProgressEngine.computeEta(
        currentAmount: 3000,
        targetAmount: 12000,
        startDate: start,
        endDate: end,
        contributions: [
          GoalContributionRecord(
            id: 1,
            goalId: 1,
            amount: 3000,
            contributedAt: DateTime(2026, 2, 1),
          ),
        ],
        isCompleted: false,
        now: now,
      );

      expect(eta.status, isIn([GoalTrackStatus.onTrack, GoalTrackStatus.behind]));
      expect(eta.projectedDate, isNotNull);
      expect(eta.avgMonthlyContribution, greaterThan(0));
    });

    test('flags overdue goals past deadline', () {
      final eta = GoalProgressEngine.computeEta(
        currentAmount: 2000,
        targetAmount: 10000,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 6, 1),
        contributions: const [],
        isCompleted: false,
        now: now,
      );

      expect(eta.status, GoalTrackStatus.overdue);
      expect(eta.daysToDeadline, lessThan(0));
    });

    test('required monthly uses remaining divided by calendar months left', () {
      final months = GoalProgressEngine.monthsRemainingUntil(
        DateTime(2026, 5, 15),
        DateTime(2026, 12, 31),
      );
      expect(months, 7);

      final monthly = GoalProgressEngine.requiredMonthlySavings(
        remaining: 7000,
        now: DateTime(2026, 5, 15),
        endDate: DateTime(2026, 12, 31),
      );
      expect(monthly, closeTo(1000, 0.01));

      final eta = GoalProgressEngine.computeEta(
        currentAmount: 3000,
        targetAmount: 10000,
        startDate: start,
        endDate: end,
        contributions: const [],
        isCompleted: false,
        now: now,
      );
      expect(eta.requiredMonthlyToDeadline, closeTo(7000 / 7, 0.01));
    });
  });
}
