import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mudabbir/presentation/analysis/analysis_view.dart';
import 'package:mudabbir/presentation/analysis/analysis_viewmodel.dart';
import 'package:mudabbir/presentation/expenses/expenses_view.dart';
import 'package:mudabbir/presentation/resources/analysis_colors.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/expense_strings.dart';
import 'package:mudabbir/presentation/budget/budget_view.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/behavioral_score_card.dart';
import 'package:mudabbir/presentation/widgets/ios_loading_widget.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'statistics_viewmodel.dart';

class StatisticsView extends ConsumerStatefulWidget {
  const StatisticsView({super.key});

  @override
  ConsumerState<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends ConsumerState<StatisticsView> {
  Future<void> _refresh() async {
    HapticService.light();
    await ref.read(statisticsProvider.notifier).loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsProvider);
    final analysis = ref.watch(analysisProvider);
    final scheme = Theme.of(context).colorScheme;

    if (state.isLoading && state.totalIncome == 0 && state.totalExpense == 0) {
      return const Center(child: IOSLoadingWidget(size: 56));
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: scheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppLayout.pageGutter,
          8,
          AppLayout.pageGutter,
          AppLayout.bottomNavClearance,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.statsTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.textOnCard,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: ExpenseStrings.viewAllExpenses,
                  onPressed: () {
                    getIt<NavigationService>().navigate(const ExpensesView());
                  },
                  icon: Icon(CupertinoIcons.doc_text, color: scheme.homeGreen),
                ),
                IconButton(
                  tooltip: AppStrings.navBudget,
                  onPressed: () {
                    getIt<NavigationService>().navigate(BudgetView());
                  },
                  icon: Icon(CupertinoIcons.creditcard, color: scheme.homeGreen),
                ),
              ],
            ),
            const SizedBox(height: AppLayout.sectionGap),

            _buildKpiRow(context, state),
            const SizedBox(height: AppLayout.sectionGap),

            if (!analysis.isLoading && analysis.behavioralScore > 0)
              BehavioralScoreCard(
                score: analysis.behavioralScore,
                rating: analysis.behavioralRating,
                summary: analysis.monthComparisonSummary,
                accentColor: AnalysisColors.health(
                  scheme,
                  analysis.behavioralRating,
                ),
                compact: true,
                onTap: () {
                  getIt<NavigationService>().navigate(const AnalysisView());
                },
              ),
            if (!analysis.isLoading && analysis.behavioralScore > 0)
              const SizedBox(height: AppLayout.sectionGap),

            _buildChartCard(
              context,
              AppStrings.statsIncomeExpense,
              _buildBarChart(context, state),
            ),
            const SizedBox(height: AppLayout.sectionGap),

            _buildChartCard(
              context,
              AppStrings.statsExpenseByCategory,
              _buildPieChartContent(
                context,
                state.expenseByCategory,
              ),
            ),
            const SizedBox(height: AppLayout.sectionGap),

            _buildChartCard(
              context,
              AppStrings.statsIncomeByCategory,
              _buildPieChartContent(
                context,
                state.incomeByCategory,
              ),
            ),
            const SizedBox(height: AppLayout.sectionGap),

            _buildProgressSection(
              context,
              AppStrings.statsGoalsProgress,
              state.goalsProgress,
            ),
            const SizedBox(height: AppLayout.sectionGap),

            _buildProgressSection(
              context,
              AppStrings.statsBudgetsProgress,
              state.budgetsProgress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiRow(BuildContext context, StatisticsState state) {
    return Row(
      children: [
        Expanded(
          child: _KpiTile(
            label: AppStrings.totalIncome,
            value: AppCurrency.format(state.totalIncome),
            color: Theme.of(context).colorScheme.success,
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _KpiTile(
            label: AppStrings.totalExpense,
            value: AppCurrency.format(state.totalExpense),
            color: Theme.of(context).colorScheme.error,
            icon: Icons.trending_down_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _KpiTile(
            label: AppStrings.currentBalance,
            value: AppCurrency.format(state.currentBalance),
            color: Theme.of(context).colorScheme.homeGreen,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(BuildContext context, String title, Widget chart) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.textOnCard,
            ),
          ),
          const SizedBox(height: 12),
          chart,
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, StatisticsState state) {
    final scheme = Theme.of(context).colorScheme;
    final maxVal = [
      state.totalIncome,
      state.totalExpense,
      state.currentBalance,
    ].map((e) => e.abs()).fold(0.0, (a, b) => a > b ? a : b);
    final maxY = maxVal > 0 ? maxVal * 1.2 : 10.0;

    return SizedBox(
      height: 210,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => scheme.surfaceContainerHighest,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final labels = AppStrings.barChartLabels;
                return BarTooltipItem(
                  '${labels[group.x.toInt()]}\n${rod.toY.toStringAsFixed(0)}',
                  TextStyle(
                    color: scheme.textOnCard,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: state.totalIncome,
                  width: 32,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  color: scheme.success,
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: state.totalExpense,
                  width: 32,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  color: scheme.error,
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: state.currentBalance,
                  width: 32,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  color: scheme.homeGreen,
                ),
              ],
            ),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (v) => FlLine(
              color: scheme.outline.withValues(alpha: 0.12),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (v, m) => Text(
                  v.toInt().toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.textMuted,
                  ),
                ),
              ),
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
                getTitlesWidget: (double value, TitleMeta meta) {
                  final labels = AppStrings.barChartLabels;
                  final i = value.toInt();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      i >= 0 && i < labels.length ? labels[i] : '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChartContent(
    BuildContext context,
    Map<String, double> data,
  ) {
    final scheme = Theme.of(context).colorScheme;
    if (data.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 48,
              color: scheme.outline.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.chartNoData,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    final total = data.values.fold(0.0, (a, b) => a + b);
    final palette = scheme.chartPalette;
    final labelColor = scheme.textOnCard;
    final sections = data.entries.toList().asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final percent = (e.value / (total == 0 ? 1 : total)) * 100;
      final color = palette[i % palette.length];
      return PieChartSectionData(
        value: e.value,
        title: '${percent.toStringAsFixed(0)}%',
        color: color,
        radius: 58,
        titleStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: labelColor,
        ),
        titlePositionPercentageOffset: 0.58,
      );
    }).toList();

    return SizedBox(
      height: 230,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 42,
                sectionsSpace: 3,
                pieTouchData: PieTouchData(enabled: true),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.entries.toList().asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                final percent = (e.value / (total == 0 ? 1 : total)) * 100;
                final color = palette[i % palette.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          EntityLocalizations.categoryName(e.key),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.textMuted),
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${percent.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.textOnCard,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    String title,
    Map<String, double> data,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final palette = scheme.chartPalette;
    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.textOnCard,
            ),
          ),
          const SizedBox(height: 12),
          if (data.isEmpty)
            Text(
              AppStrings.chartNoData,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.textMuted,
              ),
            )
          else
            Column(
              children: data.entries.toList().asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                final color = palette[i % palette.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              EntityLocalizations.categoryName(e.key),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: scheme.textOnCard),
                            ),
                          ),
                          Text(
                            '${e.value.toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (e.value / 100).clamp(0.0, 1.0),
                          backgroundColor:
                              scheme.outline.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _KpiTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      color: color.withValues(alpha: scheme.brightness == Brightness.dark ? 0.12 : 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.textOnCard,
            ),
          ),
        ],
      ),
    );
  }
}
