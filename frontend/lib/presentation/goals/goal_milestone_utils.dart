import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Milestone math + motivational copy for the goals journey map.
abstract final class GoalMilestoneUtils {
  GoalMilestoneUtils._();

  static const int defaultMilestoneCount = 4;
  static const List<int> milestonePercents = [25, 50, 75, 100];

  static int completedMilestones(double progressPercent) {
    final p = progressPercent.clamp(0, 100);
    if (p >= 100) return defaultMilestoneCount;
    if (p >= 75) return 3;
    if (p >= 50) return 2;
    if (p >= 25) return 1;
    return 0;
  }

  static bool hasCurrentMilestone(double progressPercent) => progressPercent < 100;

  static double milestoneAmount(double target, int index) {
    if (index < 0 || index >= milestonePercents.length) return target;
    return target * milestonePercents[index] / 100;
  }

  static String milestonePercentLabel(int index) {
    if (index < 0 || index >= milestonePercents.length) return '';
    if (milestonePercents[index] >= 100) {
      return AppStrings.goalMilestoneComplete;
    }
    return '${milestonePercents[index]}%';
  }

  /// Short copy for the detail-screen banner (no emoji — icon is separate).
  static String getMotivationBannerMessage(int percent) {
    final p = percent.clamp(0, 100);
    if (p < 25) return AppStrings.goalMotivationBannerStart;
    if (p < 50) return AppStrings.goalMotivationBannerEarly(p.toString());
    if (p < 75) return AppStrings.goalMotivationBannerHalf;
    if (p < 100) return AppStrings.goalMotivationBannerNear;
    return AppStrings.goalMotivationBannerDone;
  }
}
