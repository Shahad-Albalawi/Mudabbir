import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/analysis/analysis_viewmodel.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/statistics/statistics_viewmodel.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/section_title_text.dart';
import 'package:mudabbir/presentation/widgets/riyal_amount.dart';

/// Three insight cards — behavior, balance snapshot, next-month outlook.
class AnalysisBehaviorSections extends StatelessWidget {
  const AnalysisBehaviorSections({
    super.key,
    required this.analysis,
    required this.statistics,
    required this.isDark,
  });

  final AnalysisState analysis;
  final StatisticsState statistics;
  final bool isDark;

  static bool get _en => AppStrings.isEnglishLocale;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.t1Dark : AppColors.t1Light;
    final textSecondary = isDark ? AppColors.t2Dark : AppColors.t2Light;
    final net = statistics.totalIncome - statistics.totalExpense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InsightCard(
          title: _en ? 'User behavior analysis' : 'تحليل سلوك المستخدم',
          icon: CupertinoIcons.person_crop_circle_badge_checkmark,
          accent: AppColors.navy1,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          children: [
            _MetricRow(
              label: _en ? 'Savings regularity' : 'انتظام الادخار',
              value: '${analysis.savingsRate.toStringAsFixed(1)}%',
              subtitle: analysis.savingsAnalysis,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            _MetricRow(
              label: _en ? 'Spending pace' : 'وتيرة المصاريف',
              value: analysis.monthComparisonSummary.isNotEmpty
                  ? analysis.monthComparisonSummary.split('.').first
                  : analysis.spendingAnalysis.split('.').first,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            _MetricRow(
              label: _en ? 'Goal commitment' : 'الالتزام بالأهداف',
              value: _avgGoalProgress(statistics),
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _InsightCard(
          title: _en ? 'Balance status' : 'حالة الرصيد',
          icon: CupertinoIcons.money_dollar_circle,
          accent: AppColors.green,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          children: [
            _AmountMetricRow(
              label: AppStrings.statsTotalIncomeLabel,
              amount: statistics.totalIncome,
              color: AppColors.green,
              textSecondary: textSecondary,
            ),
            _AmountMetricRow(
              label: AppStrings.statsTotalExpenseLabel,
              amount: statistics.totalExpense,
              color: AppColors.red,
              textSecondary: textSecondary,
            ),
            _AmountMetricRow(
              label: AppStrings.statsNetSavingsLabel,
              amount: net,
              color: net >= 0 ? AppColors.navy1 : AppColors.red,
              textSecondary: textSecondary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _InsightCard(
          title: _en ? 'Next month outlook' : 'توقعات الشهر القادم',
          icon: Icons.trending_up_rounded,
          accent: AppColors.gold,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          children: [
            _MetricRow(
              label: _en ? 'Expected savings' : 'التوفير المتوقع',
              valueWidget: RiyalAmount(
                _projectedSavings(statistics, analysis.savingsRate),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                symbolBold: false,
                color: textPrimary,
              ),
              subtitle: _en
                  ? 'Based on current savings rate'
                  : 'بناءً على معدل الادخار الحالي',
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            _MetricRow(
              label: _en ? 'Goals progress' : 'تقدّم الأهداف',
              value: _goalsProgressSummary(statistics),
              subtitle: analysis.personalizedRecommendations.isNotEmpty
                  ? analysis.personalizedRecommendations.first
                  : null,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ],
        ),
      ],
    );
  }

  static String _avgGoalProgress(StatisticsState statistics) {
    if (statistics.goalsProgress.isEmpty) {
      return _en ? 'No active goals' : 'لا أهداف نشطة';
    }
    final avg = statistics.goalsProgress.values.fold<double>(0, (a, b) => a + b) /
        statistics.goalsProgress.length;
    return '${avg.toStringAsFixed(0)}%';
  }

  static String _goalsProgressSummary(StatisticsState statistics) {
    if (statistics.goalsProgress.isEmpty) {
      return _en ? 'Set a goal to track progress' : 'أنشئ هدفاً لتتبع التقدّم';
    }
    final sorted = statistics.goalsProgress.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    return '${top.key}: ${top.value.toStringAsFixed(0)}%';
  }

  static double _projectedSavings(
    StatisticsState statistics,
    double savingsRate,
  ) {
    if (statistics.totalIncome <= 0) return 0;
    return statistics.totalIncome * (savingsRate / 100);
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: AppSpacing.sm + 4),
              Expanded(
                child: SectionTitleText(
                  title,
                  style: AppTypography.titleSmall(textPrimary).copyWith(
                    fontWeight: AppFontWeights.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.textPrimary,
    required this.textSecondary,
    this.value,
    this.valueWidget,
    this.subtitle,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final String? subtitle;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodySmall(textSecondary),
                ),
              ),
              if (valueWidget != null)
                valueWidget!
              else if (value != null)
                Flexible(
                  child: Text(
                    value!,
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLarge(textPrimary).copyWith(
                      fontWeight: AppFontWeights.semiBold,
                    ),
                  ),
                ),
            ],
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.start,
              style: AppTypography.caption(textSecondary).copyWith(height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _AmountMetricRow extends StatelessWidget {
  const _AmountMetricRow({
    required this.label,
    required this.amount,
    required this.color,
    required this.textSecondary,
  });

  final String label;
  final double amount;
  final Color color;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall(textSecondary),
            ),
          ),
          RiyalAmount(
            amount,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }
}
