import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/domain/services/financial_date_utils.dart';
import 'package:mudabbir/presentation/analysis/analysis_viewmodel.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/riyal_amount.dart';
import 'package:mudabbir/presentation/widgets/score_ring_widget.dart';
import 'package:mudabbir/presentation/widgets/section_title_text.dart';
import 'package:mudabbir/presentation/statistics/statistics_screen_provider.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

/// Premium statistics dashboard — line chart, donut, KPIs, period selector.
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  Future<void> _refresh() async {
    HapticService.light();
    await ref.read(statisticsScreenProvider.notifier).load(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(statisticsScreenProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = context.colors.background;

    return ColoredBox(
      color: pageBg,
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.navy,
        child: data.isLoading && data.trendPoints.isEmpty
            ? _StatisticsShimmer(isDark: isDark)
            : data.errorMessage != null && data.isEmpty
                ? _ErrorBody(message: data.errorMessage!, onRetry: _refresh)
                : data.isEmpty
                    ? _EmptyBody(onAdd: () => context.push(AppRoutes.expenses))
                    : _StatisticsBody(data: data, isDark: isDark),
      ),
    );
  }
}

class _PeriodIncomeSnapshot {
  const _PeriodIncomeSnapshot({
    required this.income,
    required this.incomeTrend,
    required this.netSavingsTrend,
    required this.savingsRateTrend,
  });

  final double income;
  final StatisticsKpiTrend incomeTrend;
  final StatisticsKpiTrend netSavingsTrend;
  final StatisticsKpiTrend savingsRateTrend;

  double netSavings(double expense) => income - expense;

  double savingsRate(double expense) =>
      income <= 0 ? 0 : ((income - expense) / income) * 100;
}

class _StatisticsBody extends ConsumerStatefulWidget {
  const _StatisticsBody({required this.data, required this.isDark});

  final StatisticsScreenData data;
  final bool isDark;

  @override
  ConsumerState<_StatisticsBody> createState() => _StatisticsBodyState();
}

class _StatisticsBodyState extends ConsumerState<_StatisticsBody> {
  late Future<_PeriodIncomeSnapshot> _incomeFuture;

  @override
  void initState() {
    super.initState();
    _incomeFuture = _loadIncomeSnapshot(widget.data);
  }

  @override
  void didUpdateWidget(covariant _StatisticsBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.period != widget.data.period ||
        oldWidget.data.totalExpense != widget.data.totalExpense) {
      _incomeFuture = _loadIncomeSnapshot(widget.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isDark = widget.isDark;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppLayout.pageGutter,
            12,
            AppLayout.pageGutter,
            AppLayout.bottomNavClearance,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                AppStrings.statsTitle,
                style: AppTypography.heading1(
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.yourStat,
                style: AppTypography.body(
                  isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md + 4),
              _FinancialHealthLinkCard(isDark: isDark),
              const SizedBox(height: AppSpacing.md + 4),
              _PeriodSelector(
                selected: data.period,
                onChanged: (p) {
                  HapticService.selection();
                  ref.read(statisticsScreenProvider.notifier).setPeriod(p);
                },
              ),
              const SizedBox(height: AppSpacing.md + 4),
              FutureBuilder<_PeriodIncomeSnapshot>(
                future: _incomeFuture,
                builder: (context, snapshot) {
                  final incomeData = snapshot.data;
                  return _KpiGrid(
                    data: data,
                    isDark: isDark,
                    income: incomeData?.income ?? 0,
                    incomeTrend: incomeData?.incomeTrend ??
                        const StatisticsKpiTrend(
                          percentChange: 0,
                          isPositiveGood: true,
                        ),
                    netSavingsTrend: incomeData?.netSavingsTrend ??
                        const StatisticsKpiTrend(
                          percentChange: 0,
                          isPositiveGood: true,
                        ),
                    savingsRateTrend: incomeData?.savingsRateTrend ??
                        const StatisticsKpiTrend(
                          percentChange: 0,
                          isPositiveGood: true,
                        ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md + 4),
              _StatsCard(
                isDark: isDark,
                title: AppStrings.statsSpendingTrendTitle,
                child: _ExpenseLineChart(
                  key: ValueKey(data.period),
                  points: data.trendPoints,
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: 16),
              _StatsCard(
                isDark: isDark,
                title: AppStrings.statsCategoryBreakdownTitle,
                child: _CategoryDonutChart(
                  key: ValueKey('pie-${data.period}'),
                  categories: data.expenseByCategory,
                  total: data.totalExpense,
                  isDark: isDark,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _FinancialHealthLinkCard extends ConsumerWidget {
  const _FinancialHealthLinkCard({required this.isDark});

  final bool isDark;

  String _chipLabel(int score) {
    if (score >= 75) return 'ممتاز';
    if (score >= 60) return 'جيد';
    if (score >= 40) return 'متوسط';
    return 'ضعيف';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final analysis = ref.watch(analysisProvider);
    final score = analysis.healthScore.round().clamp(0, 100);
    final chipColor = score >= 60 ? colors.green : colors.gold;
    final chipBg = score >= 60 ? colors.greenSurface : colors.goldSurface;

    return Material(
      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.border, width: 0.5),
      ),
      child: InkWell(
        onTap: () {
          HapticService.light();
          context.push(AppRoutes.financialHealth);
        },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Row(
            children: [
              ScoreRingWidget(
                score: score,
                color: colors.primary,
                size: 50,
                strokeWidth: 5,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitleText(
                      AppStrings.financialHealth,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.isEnglishLocale
                          ? 'Detailed health analysis'
                          : 'عرض تحليل الصحة المالية',
                      textAlign: TextAlign.start,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    if (!analysis.isLoading) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.md,
                          vertical: Spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          _chipLabel(score),
                          style: textTheme.labelMedium?.copyWith(
                            color: chipColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: colors.textTertiary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<_PeriodIncomeSnapshot> _loadIncomeSnapshot(
  StatisticsScreenData data,
) async {
  final db = getIt<DbHelper>();
  final current = _dateRangeForPeriod(data.period, DateTime.now());
  final previous = _previousRangeForPeriod(current, data.period.dayCount);

  final currentIncome = await _sumIncome(db, current.start, current.end);
  final previousIncome = await _sumIncome(db, previous.start, previous.end);
  final currentExpense = data.totalExpense;

  final previousExpenseResult = await db.complexQuery(
    table: 'transactions',
    columns: ['SUM(amount) as total'],
    where: "type = 'expense' AND date(date) BETWEEN date(?) AND date(?)",
    whereArgs: [previous.start, previous.end],
  );
  final previousExpense = previousExpenseResult.fold(
    (_) => 0.0,
    (rows) => (rows.first['total'] as num?)?.toDouble() ?? 0.0,
  );

  final currentNet = currentIncome - currentExpense;
  final previousNet = previousIncome - previousExpense;
  final currentRate =
      currentIncome <= 0 ? 0.0 : (currentNet / currentIncome) * 100;
  final previousRate =
      previousIncome <= 0 ? 0.0 : (previousNet / previousIncome) * 100;

  return _PeriodIncomeSnapshot(
    income: currentIncome,
    incomeTrend: _trendMetric(currentIncome, previousIncome, higherIsBetter: true),
    netSavingsTrend: _trendMetric(currentNet, previousNet, higherIsBetter: true),
    savingsRateTrend:
        _trendMetric(currentRate, previousRate, higherIsBetter: true),
  );
}

StatisticsKpiTrend _trendMetric(
  double current,
  double previous, {
  required bool higherIsBetter,
}) {
  final delta = previous == 0
      ? (current == 0 ? 0.0 : 100.0)
      : ((current - previous) / previous) * 100;
  final improved = higherIsBetter ? delta > 0 : delta < 0;
  return StatisticsKpiTrend(
    percentChange: delta,
    isPositiveGood: improved || delta == 0,
  );
}

Future<double> _sumIncome(DbHelper db, String start, String end) async {
  final result = await db.complexQuery(
    table: 'transactions',
    columns: ['SUM(amount) as total'],
    where: "type = 'income' AND date(date) BETWEEN date(?) AND date(?)",
    whereArgs: [start, end],
  );
  return result.fold(
    (_) => 0.0,
    (rows) => (rows.first['total'] as num?)?.toDouble() ?? 0.0,
  );
}

({String start, String end}) _dateRangeForPeriod(
  StatisticsPeriod period,
  DateTime end,
) {
  final endDate = DateTime(end.year, end.month, end.day);
  final startDate = endDate.subtract(Duration(days: period.dayCount - 1));
  return (
    start: FinancialDateUtils.isoDate(startDate),
    end: FinancialDateUtils.isoDate(endDate),
  );
}

({String start, String end}) _previousRangeForPeriod(
  ({String start, String end}) current,
  int dayCount,
) {
  final currentStart = DateTime.parse(current.start);
  final prevEnd = currentStart.subtract(const Duration(days: 1));
  final prevStart = prevEnd.subtract(Duration(days: dayCount - 1));
  return (
    start: FinancialDateUtils.isoDate(prevStart),
    end: FinancialDateUtils.isoDate(prevEnd),
  );
}

// ---------------------------------------------------------------------------
// Period selector — pill buttons
// ---------------------------------------------------------------------------

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});

  final StatisticsPeriod selected;
  final ValueChanged<StatisticsPeriod> onChanged;

  static const _periods = StatisticsPeriod.values;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _periods.map((period) {
        final isSelected = period == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: period == _periods.first ? 0 : AppSpacing.xs,
              right: period == _periods.last ? 0 : AppSpacing.xs,
            ),
            child: GestureDetector(
              onTap: () => onChanged(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.navy : AppColors.gray100,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                alignment: Alignment.center,
                child: Text(
                  period.label,
                  style: AppTypography.labelMedium(
                    isSelected ? AppColors.onPrimary : AppColors.gray600,
                  ).copyWith(
                    fontWeight: isSelected
                        ? AppFontWeights.medium
                        : AppFontWeights.regular,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// KPI grid 2×2
// ---------------------------------------------------------------------------

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({
    required this.data,
    required this.isDark,
    required this.income,
    required this.incomeTrend,
    required this.netSavingsTrend,
    required this.savingsRateTrend,
  });

  final StatisticsScreenData data;
  final bool isDark;
  final double income;
  final StatisticsKpiTrend incomeTrend;
  final StatisticsKpiTrend netSavingsTrend;
  final StatisticsKpiTrend savingsRateTrend;

  @override
  Widget build(BuildContext context) {
    final net = income - data.totalExpense;
    final rate = income <= 0 ? 0.0 : (net / income) * 100;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                isDark: isDark,
                icon: Icons.arrow_upward_rounded,
                iconColor: AppColors.income,
                label: AppStrings.statsTotalIncomeLabel,
                value: RiyalAmount(
                  income,
                  fontSize: 22,
                  fontWeight: AppFontWeights.bold,
                  symbolBold: true,
                  color: AppColors.navy,
                ),
                trend: incomeTrend,
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: _KpiCard(
                isDark: isDark,
                icon: Icons.arrow_downward_rounded,
                iconColor: AppColors.expense,
                label: AppStrings.statsTotalExpenseLabel,
                value: RiyalAmount(
                  data.totalExpense,
                  fontSize: 22,
                  fontWeight: AppFontWeights.bold,
                  symbolBold: true,
                  color: AppColors.navy,
                ),
                trend: data.totalExpenseTrend,
                invertTrendColors: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                isDark: isDark,
                icon: Icons.savings_outlined,
                iconColor: AppColors.navy,
                label: AppStrings.statsNetSavingsLabel,
                value: RiyalAmount(
                  net,
                  fontSize: 22,
                  fontWeight: AppFontWeights.bold,
                  symbolBold: true,
                  color: AppColors.navy,
                ),
                trend: netSavingsTrend,
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: _KpiCard(
                isDark: isDark,
                icon: Icons.percent_rounded,
                iconColor: AppColors.info,
                label: AppStrings.statsSavingsRateLabel,
                value: Text(
                  '${rate.toStringAsFixed(0)}%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineSmall(AppColors.navy).copyWith(
                    fontSize: 22,
                    fontWeight: AppFontWeights.bold,
                    height: 1.1,
                  ),
                ),
                trend: savingsRateTrend,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.trend,
    this.invertTrendColors = false,
  });

  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget value;
  final StatisticsKpiTrend trend;
  final bool invertTrendColors;

  @override
  Widget build(BuildContext context) {
    final labelColor =
        isDark ? AppColors.textSecondaryDark : AppColors.gray400;

    Color trendColor;
    IconData trendIcon;
    if (trend.isNeutral) {
      trendColor = labelColor;
      trendIcon = Icons.remove_rounded;
    } else {
      final good =
          invertTrendColors ? !trend.isPositiveGood : trend.isPositiveGood;
      trendColor = good ? AppColors.income : AppColors.expense;
      trendIcon = trend.isUp
          ? Icons.north_east_rounded
          : Icons.south_east_rounded;
    }

    return _StatsCard(
      isDark: isDark,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          value,
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption(labelColor).copyWith(fontSize: 11),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(trendIcon, size: 14, color: trendColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${trend.percentChange.abs().toStringAsFixed(0)}%',
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

// ---------------------------------------------------------------------------
// Shared card shell
// ---------------------------------------------------------------------------

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.isDark,
    required this.child,
    this.title,
    this.padding = const EdgeInsets.all(20),
  });

  final bool isDark;
  final Widget child;
  final String? title;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfDark : AppColors.surfLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.gray200,
        ),
        boxShadow: AppShadows.sm(isDark: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: AppTypography.titleMedium(
                isDark ? AppColors.textPrimaryDark : AppColors.navy,
              ).copyWith(fontWeight: AppFontWeights.medium),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Line chart
// ---------------------------------------------------------------------------

class _ExpenseLineChart extends StatelessWidget {
  const _ExpenseLineChart({
    super.key,
    required this.points,
    required this.isDark,
  });

  final List<StatisticsTrendPoint> points;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (points.every((p) => p.amount == 0)) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            AppStrings.statsNoDataForPeriod,
            style: AppTypography.bodyMedium(
              isDark ? AppColors.textSecondaryDark : AppColors.gray600,
            ),
          ),
        ),
      );
    }

    final maxY = points.map((p) => p.amount).fold(0.0, math.max);
    final chartMaxY = maxY <= 0 ? 10.0 : maxY * 1.15;
    final gridColor = isDark
        ? AppColors.borderDark.withValues(alpha: 0.35)
        : AppColors.gray200.withValues(alpha: 0.8);

    return SizedBox(
      height: 240,
      child: LineChart(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        LineChartData(
          minY: 0,
          maxY: chartMaxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: chartMaxY / 3,
            getDrawingHorizontalLine: (_) => FlLine(
              color: gridColor,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      points[i].label,
                      style: AppTypography.caption(AppColors.gray400),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: AppRadius.md,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 4,
                vertical: AppSpacing.sm,
              ),
              getTooltipColor: (_) =>
                  isDark ? AppColors.surfDark : AppColors.surfLight,
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final i = spot.x.toInt();
                  final label =
                      i >= 0 && i < points.length ? points[i].label : '';
                  return LineTooltipItem(
                    '$label\n',
                    AppTypography.labelMedium(AppColors.navy).copyWith(
                      fontWeight: AppFontWeights.medium,
                    ),
                    children: [
                      TextSpan(
                        text: AppCurrency.format(spot.y),
                        style: AppTypography.titleSmall(AppColors.navy)
                            .copyWith(fontWeight: AppFontWeights.bold),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
            getTouchedSpotIndicator: (_, indexes) => indexes
                .map(
                  (_) => TouchedSpotIndicatorData(
                    const FlLine(color: AppColors.transparent),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 5,
                        color: AppColors.surfLight,
                        strokeWidth: 2.5,
                        strokeColor: AppColors.navy,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].amount),
              ],
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.navy,
              barWidth: 4,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.surfLight,
                  strokeWidth: 2,
                  strokeColor: AppColors.navy,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.navy.withValues(alpha: 0.1),
                    AppColors.navy.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Donut pie chart
// ---------------------------------------------------------------------------

class _CategoryDonutChart extends StatelessWidget {
  const _CategoryDonutChart({
    super.key,
    required this.categories,
    required this.total,
    required this.isDark,
  });

  final Map<String, double> categories;
  final double total;
  final bool isDark;

  static const _palette = AppColors.chartPalette;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty || total == 0) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            AppStrings.statsNoCategoriesYet,
            style: AppTypography.bodyMedium(
              isDark ? AppColors.textSecondaryDark : AppColors.gray600,
            ),
          ),
        ),
      );
    }

    final entries = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.first;
    final topPct = total == 0 ? 0.0 : (top.value / total) * 100;
    final topName = EntityLocalizations.categoryName(top.key);

    final sections = entries.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      return PieChartSectionData(
        value: e.value,
        color: _palette[i % _palette.length],
        radius: 52,
        title: '',
        borderSide: const BorderSide(color: AppColors.surfLight, width: 2),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 52,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      topName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSmall(AppColors.navy).copyWith(
                        fontWeight: AppFontWeights.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${topPct.toStringAsFixed(0)}%',
                      style: AppTypography.headlineSmall(AppColors.navy).copyWith(
                        fontWeight: AppFontWeights.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < entries.length; i++)
              _LegendChip(
                color: _palette[i % _palette.length],
                label: EntityLocalizations.categoryName(entries[i].key),
                isDark: isDark,
              ),
          ],
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
    required this.isDark,
  });

  final Color color;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.caption(
            isDark ? AppColors.textPrimaryDark : AppColors.gray900,
          ).copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer loading
// ---------------------------------------------------------------------------

class _StatisticsShimmer extends StatelessWidget {
  const _StatisticsShimmer({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppLayout.pageGutter,
        12,
        AppLayout.pageGutter,
        AppLayout.bottomNavClearance,
      ),
      children: [
        _ShimmerBox(width: 180, height: 32, isDark: isDark),
        const SizedBox(height: 20),
        _ShimmerBox(height: 40, isDark: isDark, radius: 100),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _ShimmerBox(height: 120, isDark: isDark, radius: 20)),
            const SizedBox(width: 12),
            Expanded(child: _ShimmerBox(height: 120, isDark: isDark, radius: 20)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _ShimmerBox(height: 120, isDark: isDark, radius: 20)),
            const SizedBox(width: 12),
            Expanded(child: _ShimmerBox(height: 120, isDark: isDark, radius: 20)),
          ],
        ),
        const SizedBox(height: 20),
        _ShimmerBox(height: 260, isDark: isDark, radius: 20),
        const SizedBox(height: 16),
        _ShimmerBox(height: 260, isDark: isDark, radius: 20),
      ],
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    required this.height,
    required this.isDark,
    this.width,
    this.radius = 8,
  });

  final double height;
  final double? width;
  final bool isDark;
  final double radius;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.isDark
        ? AppColors.surfDark
        : AppColors.gray200.withValues(alpha: 0.5);
    final highlight = widget.isDark
        ? AppColors.borderDark
        : AppColors.surfLight.withValues(alpha: 0.85);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * _controller.value, 0),
              end: Alignment(1 + 2 * _controller.value, 0),
              colors: [base, highlight, base],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Empty + error states
// ---------------------------------------------------------------------------

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.62,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _ChartIllustration(),
              const SizedBox(height: 24),
              Text(
                AppStrings.statsScreenEmptyTitle,
                style: AppTypography.heading2(
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  AppStrings.statsScreenEmptySubtitle,
                  style: AppTypography.body(
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAdd,
                child: Text(AppStrings.expensesAddButton),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 48,
                color: AppColors.expense.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartIllustration extends StatelessWidget {
  const _ChartIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 120,
      child: CustomPaint(
        painter: _ChartIllustrationPainter(),
      ),
    );
  }
}

class _ChartIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final card = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.1,
        size.width * 0.84,
        size.height * 0.8,
      ),
      const Radius.circular(16),
    );
    canvas.drawRRect(card, Paint()..color = AppColors.surfLight);
    canvas.drawRRect(
      card,
      Paint()
        ..color = AppColors.gray200
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final linePath = Path()
      ..moveTo(size.width * 0.18, size.height * 0.68)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.35,
        size.width * 0.55,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.62,
        size.width * 0.82,
        size.height * 0.28,
      );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.navy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    final donutCenter = Offset(size.width * 0.72, size.height * 0.42);
    canvas.drawCircle(donutCenter, 18, Paint()..color = AppColors.chartBlue);
    canvas.drawCircle(
      donutCenter,
      10,
      Paint()..color = AppColors.surfLight,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
