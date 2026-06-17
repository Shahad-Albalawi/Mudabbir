import 'package:mudabbir/domain/models/behavioral_snapshot.dart';
import 'package:mudabbir/presentation/resources/expense_strings.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Bilingual strings for behavioral analysis (Feature C).
class BehavioralStrings {
  BehavioralStrings._();

  static bool get _en => AppStrings.isEnglishLocale;

  static String get behavioralScoreTitle =>
      _en ? 'Behavioral score' : 'النقاط السلوكية';

  static String get behavioralScoreSubtitle => _en
      ? 'Based on this month\'s spending patterns'
      : 'مبني على أنماط إنفاقك هذا الشهر';

  static String get viewDetailsLabel =>
      _en ? 'View full analysis' : 'عرض التحليل الكامل';

  static String get monthComparisonTitle =>
      _en ? 'Month-over-month comparison' : 'مقارنة بالأشهر السابقة';

  static String get anomaliesTitle =>
      _en ? 'Unusual spending patterns' : 'أنماط إنفاق غير طبيعية';

  static String get noAnomalies => _en
      ? 'No unusual patterns detected this month. Keep it up!'
      : 'لم نكتشف أنماطاً غير طبيعية هذا الشهر. استمر!';

  static String get weekdayPatternTitle =>
      _en ? 'Spending by day' : 'الإنفاق حسب اليوم';

  static String get personalizedRecsTitle =>
      _en ? 'Personalized tips' : 'توصيات مخصصة لك';

  static String get currentMonthLabel => _en ? 'This month' : 'هذا الشهر';

  static String get previousMonthLabel => _en ? 'Last month' : 'الشهر الماضي';

  static String get trailingAvgLabel =>
      _en ? '3-month avg' : 'متوسط 3 أشهر';

  static String get noWeekdayData => _en
      ? 'Not enough data to analyze daily patterns yet.'
      : 'لا توجد بيانات كافية لتحليل الإنفاق اليومي بعد.';

  static String ratingForScore(int score) {
    if (_en) {
      if (score >= 85) return 'Excellent';
      if (score >= 70) return 'Good';
      if (score >= 55) return 'Fair';
      if (score >= 40) return 'Needs work';
      return 'At risk';
    }
    if (score >= 85) return 'ممتاز';
    if (score >= 70) return 'جيد';
    if (score >= 55) return 'مقبول';
    if (score >= 40) return 'يحتاج تحسين';
    return 'معرض للخطر';
  }

  static String monthComparisonSummary({
    required double currentExpense,
    required double previousExpense,
    required double trailingAvg,
  }) {
    if (_en) {
      if (previousExpense <= 0 && trailingAvg <= 0) {
        return 'This month: ${formatAmount(currentExpense)}. Add more history for comparisons.';
      }
      if (previousExpense > 0) {
        final change = ((currentExpense / previousExpense) - 1) * 100;
        if (change > 10) {
          return 'You spent ${change.toStringAsFixed(0)}% more than last month (${formatAmount(currentExpense)} vs ${formatAmount(previousExpense)}).';
        }
        if (change < -10) {
          return 'You spent ${change.abs().toStringAsFixed(0)}% less than last month. Great discipline!';
        }
        return 'Spending is stable vs last month (${formatAmount(currentExpense)} vs ${formatAmount(previousExpense)}).';
      }
      return 'This month: ${formatAmount(currentExpense)} vs 3-month avg ${formatAmount(trailingAvg)}.';
    }

    if (previousExpense <= 0 && trailingAvg <= 0) {
      return 'إنفاق هذا الشهر: ${formatAmount(currentExpense)}. أضف المزيد من السجل للمقارنة.';
    }
    if (previousExpense > 0) {
      final change = ((currentExpense / previousExpense) - 1) * 100;
      if (change > 10) {
        return 'أنفقت أكثر بنسبة ${change.toStringAsFixed(0)}% من الشهر الماضي (${formatAmount(currentExpense)} مقابل ${formatAmount(previousExpense)}).';
      }
      if (change < -10) {
        return 'أنفقت أقل بنسبة ${change.abs().toStringAsFixed(0)}% من الشهر الماضي. انضباط ممتاز!';
      }
      return 'إنفاقك مستقر مقارنة بالشهر الماضي (${formatAmount(currentExpense)} مقابل ${formatAmount(previousExpense)}).';
    }
    return 'هذا الشهر: ${formatAmount(currentExpense)} مقابل متوسط 3 أشهر ${formatAmount(trailingAvg)}.';
  }

  static String weekdayInsight({required String dayName, required double amount}) {
    if (_en) {
      return 'You spend most on $dayName (${formatAmount(amount)} this month).';
    }
    return 'أكثر إنفاقك في $dayName (${formatAmount(amount)} هذا الشهر).';
  }

  static String weekdayName(int weekday) {
    // DateTime.weekday: 1=Mon … 7=Sun
    if (_en) {
      const names = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return names[(weekday - 1).clamp(0, 6)];
    }
    const names = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return names[(weekday - 1).clamp(0, 6)];
  }

  static String formatAmount(double value) => ExpenseStrings.formatAmount(value);

  static String anomalyTitle(SpendingAnomaly anomaly) {
    switch (anomaly.titleKey) {
      case 'monthlySpikeTitle':
        return _en ? 'Monthly spending spike' : 'قفزة في الإنفاق الشهري';
      case 'overspendingTitle':
        return _en ? 'Spending exceeds income' : 'الإنفاق يتجاوز الدخل';
      case 'categorySpikeTitle':
        return _en ? 'Category surge' : 'ارتفاع في فئة';
      case 'largeTransactionTitle':
        return _en ? 'Large transaction' : 'معاملة كبيرة';
      case 'weekendSplurgeTitle':
        return _en ? 'Weekend spending' : 'إنفاق نهاية الأسبوع';
      case 'spendingBurstTitle':
        return _en ? 'High transaction frequency' : 'تكرار معاملات مرتفع';
      default:
        return _en ? 'Unusual pattern' : 'نمط غير عادي';
    }
  }

  static String anomalyMessage(SpendingAnomaly anomaly) {
    final p = anomaly.params;
    switch (anomaly.messageKey) {
      case 'monthlySpikeMessage':
        return _en
            ? 'This month is ${p['pct']}% above your 3-month average (${formatAmount(double.tryParse(p['amount'] ?? '0') ?? 0)}).'
            : 'هذا الشهر أعلى بنسبة ${p['pct']}% من متوسط 3 أشهر (${formatAmount(double.tryParse(p['amount'] ?? '0') ?? 0)}).';
      case 'overspendingMessage':
        return _en
            ? 'You overspent by ${formatAmount(double.tryParse(p['gap'] ?? '0') ?? 0)} this month.'
            : 'تجاوزت دخلك بمقدار ${formatAmount(double.tryParse(p['gap'] ?? '0') ?? 0)} هذا الشهر.';
      case 'categorySpikeMessage':
        return _en
            ? '${p['category']} rose ${p['pct']}% vs last month.'
            : 'فئة ${p['category']} ارتفعت ${p['pct']}% عن الشهر الماضي.';
      case 'largeTransactionMessage':
        return _en
            ? 'A single expense of ${formatAmount(double.tryParse(p['amount'] ?? '0') ?? 0)} stands out.'
            : 'معاملة بقيمة ${formatAmount(double.tryParse(p['amount'] ?? '0') ?? 0)} تبرز هذا الشهر.';
      case 'weekendSplurgeMessage':
        return _en
            ? '${p['pct']}% of spending happens on weekends.'
            : '${p['pct']}% من إنفاقك في عطلة نهاية الأسبوع.';
      case 'spendingBurstMessage':
        return _en
            ? '${p['count']} expense transactions this month — review small daily purchases.'
            : '${p['count']} معاملة مصروف هذا الشهر — راجع المشتريات اليومية الصغيرة.';
      default:
        return _en ? 'Review this pattern.' : 'راجع هذا النمط.';
    }
  }

  static String anomalyRecommendation(SpendingAnomaly anomaly) {
    switch (anomaly.type) {
      case AnomalyType.monthlySpike:
        return _en
            ? '📉 Set a weekly spending cap to bring this month back in line.'
            : '📉 ضع سقفاً أسبوعياً للإنفاق لإعادة هذا الشهر للمسار.';
      case AnomalyType.overspending:
        return _en
            ? '🚨 Pause non-essential purchases until income covers expenses.'
            : '🚨 أوقف المشتريات غير الضرورية حتى يغطي الدخل المصروفات.';
      case AnomalyType.categorySpike:
        return _en
            ? '🎯 Create a category budget for ${anomaly.params['category'] ?? 'this area'}.'
            : '🎯 أنشئ ميزانية لفئة ${anomaly.params['category'] ?? 'هذه الفئة'}.';
      case AnomalyType.largeTransaction:
        return _en
            ? '🔍 Confirm large purchases were planned; split future ones if possible.'
            : '🔍 تأكد أن المصروفات الكبيرة مخططة؛ قسّمها مستقبلاً إن أمكن.';
      case AnomalyType.weekendSplurge:
        return _en
            ? '📅 Plan weekend activities with a fixed budget beforehand.'
            : '📅 خطط لأنشطة نهاية الأسبوع بميزانية محددة مسبقاً.';
      case AnomalyType.spendingBurst:
        return _en
            ? '☕ Track small daily expenses — they add up quickly.'
            : '☕ تتبع المصروفات اليومية الصغيرة — تتراكم بسرعة.';
    }
  }

  static String get recReduceVsLastMonth => _en
      ? '📊 Spending rose vs last month — review subscriptions and dining out.'
      : '📊 الإنفاق ارتفع عن الشهر الماضي — راجع الاشتراكات والمطاعم.';

  static String get recKeepDiscipline => _en
      ? '✨ You are below your 3-month average. Maintain this pace!'
      : '✨ إنفاقك أقل من متوسط 3 أشهر. حافظ على هذا الإيقاع!';

  static String get recIncreaseSavings => _en
      ? '💰 Try saving at least 10% of income this month.'
      : '💰 حاول ادخار 10% على الأقل من دخلك هذا الشهر.';

  static String get recSetGoals => _en
      ? '🎯 Set a savings goal to stay motivated.'
      : '🎯 ضع هدف ادخار للبقاء متحفزاً.';

  static String get recCreateBudget => _en
      ? '📝 Add category budgets to control spending.'
      : '📝 أضف ميزانيات للفئات للتحكم في الإنفاق.';

  static String get recGreatScore => _en
      ? '🌟 Strong financial behavior this month!'
      : '🌟 سلوك مالي قوي هذا الشهر!';

  static String get recDefault => _en
      ? '💡 Keep logging expenses to sharpen your insights.'
      : '💡 استمر بتسجيل المصروفات لتحسين التحليل.';
}
