/// Push and local notification copy (AR / EN).
abstract final class NotificationContent {
  NotificationContent._();

  /// Budget 80% reached.
  static Map<String, String> budgetWarning(String cat, int pct, String lang) =>
      {
        'title': lang == 'ar' ? 'تنبيه ميزانية ⚠️' : 'Budget Alert ⚠️',
        'body': lang == 'ar'
            ? 'وصلت $pct% من ميزانية $cat هذا الشهر'
            : 'You\'ve used $pct% of your $cat budget this month',
      };

  /// Monthly review (day 25).
  static Map<String, String> monthlyReview(String lang) => {
        'title': lang == 'ar' ? 'مراجعة شهرية 📊' : 'Monthly Review 📊',
        'body': lang == 'ar'
            ? 'آخر 5 أيام من الشهر — كيف سير إنفاقك؟'
            : 'Last 5 days of the month — how\'s your spending?',
      };

  /// Goal approaching.
  static Map<String, String> goalApproaching(
    String name,
    int days,
    String lang,
  ) =>
      {
        'title': lang == 'ar' ? 'هدفك قريب! 🎯' : 'Goal approaching! 🎯',
        'body': lang == 'ar'
            ? 'هدف "$name" بعد $days أيام — هل أنت على المسار؟'
            : '"$name" goal is $days days away — are you on track?',
      };

  /// Daily reminder.
  static Map<String, String> dailyReminder(String name, String lang) => {
        'title': lang == 'ar' ? 'مدبّر يذكّرك 📝' : 'Mudabbir reminder 📝',
        'body': lang == 'ar'
            ? 'لا تنسى تسجيل مصاريف اليوم يا $name'
            : 'Don\'t forget to log today\'s expenses, $name',
      };

  /// Streak milestone.
  static Map<String, String> streakMilestone(int days, String lang) => {
        'title': lang == 'ar' ? 'إنجاز! 🏆' : 'Achievement! 🏆',
        'body': lang == 'ar'
            ? 'أكملت $days أيام متتالية في التحدي! مذهل'
            : 'You completed $days days in a row! Incredible',
      };

  /// Saving rate improved.
  static Map<String, String> savingUp(int pct, String lang) => {
        'title': lang == 'ar' ? 'أداء رائع! 📈' : 'Great performance! 📈',
        'body': lang == 'ar'
            ? 'معدل ادخارك ارتفع $pct% هذا الشهر 🎉'
            : 'Your savings rate increased by $pct% this month 🎉',
      };
}
