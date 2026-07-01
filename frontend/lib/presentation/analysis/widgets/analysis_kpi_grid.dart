import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/analysis/analysis_trend_utils.dart';
import 'package:mudabbir/presentation/analysis/widgets/net_savings_icon.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/statistics/statistics_screen_provider.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/riyal_amount.dart';

/// 2×2 white KPI cards with colored icon badges and month-over-month deltas.
class AnalysisKpiGrid extends StatelessWidget {
  const AnalysisKpiGrid({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRate,
    required this.trends,
    required this.isDark,
  });

  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final double savingsRate;
  final AnalysisDashboardTrends trends;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.t1Dark : AppColors.t1Light;
    final textSecondary = isDark ? AppColors.t2Dark : AppColors.t2Light;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm + 4,
      crossAxisSpacing: AppSpacing.sm + 4,
      childAspectRatio: 1.35,
      children: [
        _KpiCard(
          isDark: isDark,
          icon: Icons.arrow_downward_rounded,
          iconColor: AppColors.green,
          iconBg: AppColors.greenS,
          label: AppStrings.statsTotalIncomeLabel,
          value: RiyalAmount(
            totalIncome,
            fontSize: 20,
            fontWeight: AppFontWeights.bold,
            symbolBold: true,
            color: textPrimary,
          ),
          trend: trends.income,
          textSecondary: textSecondary,
        ),
        _KpiCard(
          isDark: isDark,
          icon: Icons.arrow_upward_rounded,
          iconColor: AppColors.red,
          iconBg: AppColors.redS,
          label: AppStrings.statsTotalExpenseLabel,
          value: RiyalAmount(
            totalExpense,
            fontSize: 20,
            fontWeight: AppFontWeights.bold,
            symbolBold: true,
            color: textPrimary,
          ),
          trend: trends.expense,
          invertTrendColors: true,
          textSecondary: textSecondary,
        ),
        _KpiCard(
          isDark: isDark,
          iconWidget: NetSavingsIcon(size: 18, color: AppColors.navy1),
          iconColor: AppColors.navy1,
          iconBg: AppColors.navySurface,
          label: AppStrings.statsNetSavingsLabel,
          value: RiyalAmount(
            netSavings,
            fontSize: 20,
            fontWeight: AppFontWeights.bold,
            symbolBold: true,
            color: textPrimary,
          ),
          trend: trends.netSavings,
          textSecondary: textSecondary,
        ),
        _KpiCard(
          isDark: isDark,
          icon: Icons.percent_rounded,
          iconColor: AppColors.gold,
          iconBg: AppColors.goldS,
          label: AppStrings.statsSavingsRateLabel,
          value: Text(
            '${savingsRate.toStringAsFixed(1)}%',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleLarge(textPrimary).copyWith(
              fontWeight: AppFontWeights.bold,
              fontSize: 20,
            ),
          ),
          trend: trends.savingsRate,
          textSecondary: textSecondary,
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.isDark,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.trend,
    required this.textSecondary,
    this.icon,
    this.iconWidget,
    this.invertTrendColors = false,
  });

  final bool isDark;
  final IconData? icon;
  final Widget? iconWidget;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final Widget value;
  final StatisticsKpiTrend trend;
  final Color textSecondary;
  final bool invertTrendColors;

  @override
  Widget build(BuildContext context) {
    Color trendColor;
    IconData trendIcon;
    if (trend.isNeutral) {
      trendColor = textSecondary;
      trendIcon = Icons.remove_rounded;
    } else {
      final good = invertTrendColors
          ? !trend.isPositiveGood
          : trend.isPositiveGood;
      trendColor = good ? AppColors.green : AppColors.red;
      trendIcon =
          trend.isUp ? Icons.north_east_rounded : Icons.south_east_rounded;
    }

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: isDark ? 0.35 : 1),
              shape: BoxShape.circle,
            ),
            child: iconWidget ??
                Icon(icon, size: 18, color: iconColor),
          ),
          const Spacer(),
          value,
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption(textSecondary).copyWith(fontSize: 11),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(trendIcon, size: 14, color: trendColor),
              const SizedBox(width: 4),
              Text(
                '${trend.percentChange.abs().toStringAsFixed(1)}%',
                style: AppTypography.caption(trendColor).copyWith(
                  fontWeight: AppFontWeights.medium,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
