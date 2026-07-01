import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Goal-specific formatting and dropdown helpers (non-l10n logic).
class GoalCopyHelpers {
  GoalCopyHelpers._();

  static List<String> get goalTypeOptions => AppStrings.goalTypeOptions;

  static String resolveGoalTypeForDropdown(String? raw) {
    final types = goalTypeOptions;
    if (raw != null && types.contains(raw)) return raw;
    return types.last;
  }

  static String formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  static String projectedDateText(DateTime? date) {
    if (date == null) return AppStrings.goalNotEnoughData;
    return formatDate(date);
  }

  static String typeLabel(String raw) {
    if (AppStrings.isEnglishLocale) return raw;
    switch (raw) {
      case 'Saving':
        return AppStrings.goalTypeSaving;
      case 'Investment':
        return AppStrings.goalTypeInvestment;
      case 'Debt':
        return AppStrings.goalTypeDebt;
      case 'Other':
        return AppStrings.goalTypeOther;
      default:
        return raw;
    }
  }

  static String statusLabel(GoalTrackStatus status) {
    switch (status) {
      case GoalTrackStatus.onTrack:
        return AppStrings.goalStatusOnTrack;
      case GoalTrackStatus.behind:
        return AppStrings.goalStatusBehind;
      case GoalTrackStatus.overdue:
        return AppStrings.goalStatusOverdue;
      case GoalTrackStatus.completed:
        return AppStrings.goalStatusCompleted;
      case GoalTrackStatus.noData:
        return AppStrings.goalStatusNotStarted;
    }
  }
}
