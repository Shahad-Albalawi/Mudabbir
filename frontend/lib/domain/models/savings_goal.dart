import 'package:mudabbir/domain/services/goal_progress_engine.dart';

enum GoalTrackStatus { onTrack, behind, overdue, completed, noData }

/// A single manual contribution toward a savings goal.
class GoalContributionRecord {
  final int id;
  final int goalId;
  final double amount;
  final DateTime contributedAt;
  final String? note;

  const GoalContributionRecord({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.contributedAt,
    this.note,
  });

  factory GoalContributionRecord.fromMap(Map<String, dynamic> map) {
    return GoalContributionRecord(
      id: map['id'] as int,
      goalId: map['goal_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      contributedAt: DateTime.parse(map['contributed_at'] as String),
      note: map['note'] as String?,
    );
  }
}

/// Projected completion and pacing for a savings goal.
class GoalEtaResult {
  final GoalTrackStatus status;
  final DateTime? projectedDate;
  final double? avgMonthlyContribution;
  final double? requiredMonthlyToDeadline;
  final int daysToDeadline;

  const GoalEtaResult({
    required this.status,
    this.projectedDate,
    this.avgMonthlyContribution,
    this.requiredMonthlyToDeadline,
    this.daysToDeadline = 0,
  });
}

/// Domain model for a savings goal with computed progress metadata.
class SavingsGoal {
  final int id;
  final String name;
  final double target;
  final double currentAmount;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String? imagePath;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<GoalContributionRecord> contributions;
  final GoalEtaResult eta;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.target,
    required this.currentAmount,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.imagePath,
    this.isCompleted = false,
    this.completedAt,
    this.contributions = const [],
    required this.eta,
  });

  double get progressPercent =>
      target <= 0 ? 0 : (currentAmount / target * 100).clamp(0, 100);

  double get remainingAmount =>
      (target - currentAmount).clamp(0, double.infinity);

  bool get justReachedTarget => !isCompleted && currentAmount >= target;

  factory SavingsGoal.fromMap(
    Map<String, dynamic> map, {
    List<GoalContributionRecord> contributions = const [],
    GoalEtaResult? eta,
    DateTime? now,
  }) {
    final start = DateTime.parse(map['start_date'] as String);
    final end = DateTime.parse(map['end_date'] as String);
    final current = (map['current_amount'] as num?)?.toDouble() ?? 0;
    final target = (map['target'] as num).toDouble();
    final completed = (map['is_completed'] as int? ?? 0) == 1;
    final completedAtRaw = map['completed_at'] as String?;

    final resolvedEta = eta ??
        GoalProgressEngine.computeEta(
          currentAmount: current,
          targetAmount: target,
          startDate: start,
          endDate: end,
          contributions: contributions,
          isCompleted: completed,
          now: now ?? DateTime.now(),
        );

    return SavingsGoal(
      id: map['id'] as int,
      name: map['name'] as String,
      target: target,
      currentAmount: current,
      type: map['type']?.toString() ?? 'Saving',
      startDate: start,
      endDate: end,
      imagePath: map['image_path'] as String?,
      isCompleted: completed,
      completedAt:
          completedAtRaw != null ? DateTime.tryParse(completedAtRaw) : null,
      contributions: contributions,
      eta: resolvedEta,
    );
  }
}
