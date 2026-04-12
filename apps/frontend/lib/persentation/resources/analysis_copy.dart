import 'package:mudabbir/persentation/resources/strings_manager.dart';

/// Localized copy for [AnalysisViewModel] outputs.
class AnalysisCopy {
  AnalysisCopy._();

  static bool get _en => AppStrings.isEnglishLocale;

  static String balanceAnalysis(double balance, double totalIncome) {
    if (_en) {
      if (balance < 0) {
        return 'Critical: You are in debt. Spending exceeds income by ${balance.abs().toStringAsFixed(2)}. Take action now.';
      }
      if (balance == 0) {
        return 'Warning: You break even with no savings buffer. Unexpected expenses are risky.';
      }
      if (balance < totalIncome * 0.1) {
        return 'Alert: Low balance (${balance.toStringAsFixed(2)}). Build an emergency fund.';
      }
      if (balance < totalIncome * 0.3) {
        return 'Fair: You have some savings (${balance.toStringAsFixed(2)}), but room to improve.';
      }
      return 'Great: Healthy balance of ${balance.toStringAsFixed(2)}. Keep it up!';
    }
    if (balance < 0) {
      return 'حرج: أنت في حالة دين! نفقاتك تتجاوز دخلك بمقدار ${balance.abs().toStringAsFixed(2)}. يتطلب إجراء فوري.';
    }
    if (balance == 0) {
      return 'تحذير: أنت تحقق التعادل بدون مدخرات. هذا يجعلك عرضة للنفقات غير المتوقعة.';
    }
    if (balance < totalIncome * 0.1) {
      return 'تنبيه: رصيدك منخفض (${balance.toStringAsFixed(2)}). حاول بناء صندوق طوارئ.';
    }
    if (balance < totalIncome * 0.3) {
      return 'مقبول: لديك بعض المدخرات (${balance.toStringAsFixed(2)})، لكن هناك مجال للتحسين.';
    }
    return 'ممتاز: تحتفظ برصيد صحي بقيمة ${balance.toStringAsFixed(2)}. استمر في العمل الجيد!';
  }

  static String spendingAnalysis(double expenseRatio) {
    if (_en) {
      if (expenseRatio >= 100) {
        return 'Critical: You spend ${expenseRatio.toStringAsFixed(1)}% of income — living beyond your means.';
      }
      if (expenseRatio >= 90) {
        return 'Warning: ${expenseRatio.toStringAsFixed(1)}% of income goes to expenses. Very little margin.';
      }
      if (expenseRatio >= 80) {
        return 'Alert: ${expenseRatio.toStringAsFixed(1)}% of income. Consider cutting non-essentials.';
      }
      if (expenseRatio >= 70) {
        return 'Fair: ${expenseRatio.toStringAsFixed(1)}% of income. Acceptable but improvable.';
      }
      if (expenseRatio >= 50) {
        return 'Good: ${expenseRatio.toStringAsFixed(1)}% of income. Healthy balance.';
      }
      return 'Excellent: Only ${expenseRatio.toStringAsFixed(1)}% of income spent. Very disciplined!';
    }
    if (expenseRatio >= 100) {
      return 'حرج: أنت تنفق ${expenseRatio.toStringAsFixed(1)}% من دخلك! أنت تعيش فوق إمكانياتك وتتراكم عليك الديون.';
    }
    if (expenseRatio >= 90) {
      return 'تحذير: أنت تنفق ${expenseRatio.toStringAsFixed(1)}% من دخلك. لديك مجال ضئيل جداً للادخار أو حالات الطوارئ.';
    }
    if (expenseRatio >= 80) {
      return 'تنبيه: أنت تنفق ${expenseRatio.toStringAsFixed(1)}% من دخلك. فكر في تقليل النفقات غير الأساسية.';
    }
    if (expenseRatio >= 70) {
      return 'مقبول: أنت تنفق ${expenseRatio.toStringAsFixed(1)}% من دخلك. هذا مقبول ولكن يمكن تحسينه.';
    }
    if (expenseRatio >= 50) {
      return 'جيد: أنت تنفق ${expenseRatio.toStringAsFixed(1)}% من دخلك. تحافظ على توازن صحي بين الإنفاق والادخار.';
    }
    return 'ممتاز: أنت تنفق ${expenseRatio.toStringAsFixed(1)}% فقط من دخلك. أنت منضبط جداً في شؤونك المالية!';
  }

  static String savingsAnalysis(double savingsRate) {
    if (_en) {
      if (savingsRate < 0) {
        return 'Critical: Negative savings (${savingsRate.toStringAsFixed(1)}%). You spend more than you earn.';
      }
      if (savingsRate < 5) {
        return 'Weak: ${savingsRate.toStringAsFixed(1)}% saved. Aim for at least 10–20%.';
      }
      if (savingsRate < 10) {
        return 'Fair: ${savingsRate.toStringAsFixed(1)}% saved. Try to reach 10–20%.';
      }
      if (savingsRate < 20) {
        return 'Good: ${savingsRate.toStringAsFixed(1)}% saved. On the right track toward 20%.';
      }
      if (savingsRate < 30) {
        return 'Excellent: ${savingsRate.toStringAsFixed(1)}% saved. Great discipline!';
      }
      return 'Outstanding: ${savingsRate.toStringAsFixed(1)}% saved. You are a savings champion!';
    }
    if (savingsRate < 0) {
      return 'حرج: لديك معدل ادخار سلبي (${savingsRate.toStringAsFixed(1)}%). أنت تنفق أكثر مما تكسب.';
    }
    if (savingsRate < 5) {
      return 'ضعيف: معدل ادخارك هو ${savingsRate.toStringAsFixed(1)}%. ينصح الخبراء الماليون بادخار 10-20% على الأقل من الدخل.';
    }
    if (savingsRate < 10) {
      return 'مقبول: معدل ادخارك هو ${savingsRate.toStringAsFixed(1)}%. أنت تدخر شيئاً، لكن اهدف إلى 10-20% على الأقل.';
    }
    if (savingsRate < 20) {
      return 'جيد: معدل ادخارك هو ${savingsRate.toStringAsFixed(1)}%. أنت على الطريق الصحيح! حاول الوصول إلى 20% إن أمكن.';
    }
    if (savingsRate < 30) {
      return 'ممتاز: معدل ادخارك هو ${savingsRate.toStringAsFixed(1)}%. أنت تقوم بعمل رائع بانضباطك المالي!';
    }
    return 'استثنائي: معدل ادخارك هو ${savingsRate.toStringAsFixed(1)}%. أنت بطل في الادخار! هذا سيؤمن مستقبلك المالي.';
  }

  static String categoryInsight(double percentage) {
    if (_en) {
      if (percentage >= 40) {
        return 'Alert: ${percentage.toStringAsFixed(1)}% — this category dominates spending. Consider alternatives or a budget.';
      }
      if (percentage >= 30) {
        return 'High: ${percentage.toStringAsFixed(1)}% — a large share. Monitor closely.';
      }
      if (percentage >= 20) {
        return 'Medium: ${percentage.toStringAsFixed(1)}% — reasonable level.';
      }
      if (percentage >= 10) {
        return 'Low: ${percentage.toStringAsFixed(1)}% — well controlled.';
      }
      return 'Very low: ${percentage.toStringAsFixed(1)}% — very disciplined here.';
    }
    if (percentage >= 40) {
      return 'تنبيه: ${percentage.toStringAsFixed(1)}% - هذه الفئة تهيمن على إنفاقك! فكر في البدائل أو وضع ميزانية.';
    }
    if (percentage >= 30) {
      return 'عالي: ${percentage.toStringAsFixed(1)}% - جزء كبير من ميزانيتك. راقب هذا عن كثب.';
    }
    if (percentage >= 20) {
      return 'متوسط: ${percentage.toStringAsFixed(1)}% - مستوى إنفاق معقول.';
    }
    if (percentage >= 10) {
      return 'منخفض: ${percentage.toStringAsFixed(1)}% - إنفاق جيد التحكم.';
    }
    return 'قليل جداً: ${percentage.toStringAsFixed(1)}% - منضبط جداً في هذا المجال.';
  }

  static String healthRating(double score) {
    if (_en) {
      if (score >= 90) return 'Excellent';
      if (score >= 75) return 'Good';
      if (score >= 60) return 'Fair';
      if (score >= 40) return 'Weak';
      return 'Critical';
    }
    if (score >= 90) return 'ممتاز';
    if (score >= 75) return 'جيد';
    if (score >= 60) return 'مقبول';
    if (score >= 40) return 'ضعيف';
    return 'حرج';
  }

  static List<String> recommendations({
    required double savingsRate,
    required double healthScore,
    required List<String> highSpendingCategoryLabels,
    required bool singleIncomeSource,
    required bool noGoals,
    required List<String> lowProgressGoalLabels,
    required bool noBudgets,
    required bool negativeBalance,
    required bool lowBalanceVsIncome,
  }) {
    final r = <String>[];
    if (_en) {
      if (savingsRate < 0) {
        r.add('🚨 Urgent: Build an emergency budget. Cut all non-essential spending now.');
        r.add('💡 Consider extra income sources to cover the gap.');
      } else if (savingsRate < 10) {
        r.add('📊 Increase savings by trimming discretionary spending.');
        r.add('💰 Aim to save at least 10–20% of income.');
      } else if (savingsRate < 20) {
        r.add('✨ You save well! Try pushing toward 20% for optimal financial health.');
      }
      if (negativeBalance) {
        r.add('⚠️ Make a debt payoff plan. Clear debt before other money goals.');
      } else if (lowBalanceVsIncome) {
        r.add('🎯 Build an emergency fund covering 3–6 months of expenses.');
      }
      if (highSpendingCategoryLabels.isNotEmpty) {
        r.add(
          '📉 Review spending in: ${highSpendingCategoryLabels.join(', ')}. Set category budgets.',
        );
      }
      if (singleIncomeSource) {
        r.add('💼 Diversify income sources for more stability.');
      }
      if (noGoals) {
        r.add('🎯 Set financial goals to stay motivated and track progress.');
      } else if (lowProgressGoalLabels.isNotEmpty) {
        r.add('📈 Increase contributions toward: ${lowProgressGoalLabels.join(', ')}.');
      }
      if (noBudgets) {
        r.add('📝 Create budgets per category to control spending better.');
      }
      if (healthScore >= 75) {
        r.add('🌟 Great job managing your money. Keep it up!');
      }
      if (r.isEmpty) {
        r.add('💡 Keep tracking expenses and stick to your savings plan.');
        r.add('📚 Read about investing strategies to grow wealth further.');
      }
      return r;
    }
    if (savingsRate < 0) {
      r.add('🚨 عاجل: أنشئ خطة ميزانية طوارئ. قلل جميع النفقات غير الأساسية فوراً.');
      r.add('💡 فكر في مصادر دخل إضافية أو عمل بدوام جزئي لتغطية العجز.');
    } else if (savingsRate < 10) {
      r.add('📊 زد معدل ادخارك من خلال تقليل الإنفاق التقديري.');
      r.add('💰 اهدف لادخار 10-20% على الأقل من دخلك للأمان المالي.');
    } else if (savingsRate < 20) {
      r.add('✨ أنت تدخر بشكل جيد! حاول دفع معدل ادخارك إلى 20% للصحة المالية المثلى.');
    }
    if (negativeBalance) {
      r.add('⚠️ أنشئ خطة لسداد الديون. ركز على إلغاء الديون قبل الأهداف المالية الأخرى.');
    } else if (lowBalanceVsIncome) {
      r.add('🎯 ابنِ صندوق طوارئ يغطي 3-6 أشهر من النفقات.');
    }
    if (highSpendingCategoryLabels.isNotEmpty) {
      r.add(
        '📉 راجع الإنفاق في: ${highSpendingCategoryLabels.join('، ')}. فكر في وضع ميزانيات للفئات.',
      );
    }
    if (singleIncomeSource) {
      r.add('💼 فكر في تنويع مصادر دخلك لاستقرار مالي أفضل.');
    }
    if (noGoals) {
      r.add('🎯 ضع أهدافاً مالية لتبقى متحفزاً وتتابع تقدمك.');
    } else if (lowProgressGoalLabels.isNotEmpty) {
      r.add('📈 زد المساهمات في: ${lowProgressGoalLabels.join('، ')}.');
    }
    if (noBudgets) {
      r.add('📝 أنشئ ميزانيات للفئات للتحكم بشكل أفضل في إنفاقك.');
    }
    if (healthScore >= 75) {
      r.add('🌟 عمل رائع! أنت تدير أموالك بشكل جيد. استمر في العمل الممتاز!');
    }
    if (r.isEmpty) {
      r.add('💡 استمر في مراقبة نفقاتك والتزم بخطة ادخارك.');
      r.add('📚 فكر في القراءة عن استراتيجيات الاستثمار لتنمية ثروتك أكثر.');
    }
    return r;
  }
}
