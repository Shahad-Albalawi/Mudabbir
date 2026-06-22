import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';
import 'package:mudabbir/presentation/resources/analysis_colors.dart';
import 'package:mudabbir/presentation/resources/app_colors.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/expense_strings.dart';
import 'package:mudabbir/presentation/analysis/analysis_viewmodel.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/behavioral_score_card.dart';
import 'package:mudabbir/presentation/widgets/chart_empty_state.dart';
import 'package:mudabbir/presentation/widgets/app_skeleton.dart';
import 'package:mudabbir/presentation/resources/statistics_strings.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/reporting/financial_report_exporter.dart';
import 'statistics_viewmodel.dart';

class StatisticsView extends ConsumerStatefulWidget {
  const StatisticsView({super.key});

  @override
  ConsumerState<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends ConsumerState<StatisticsView> {
  bool _exportingPdf = false;

  Future<void> _refresh() async {
    HapticService.light();
    await ref.read(statisticsProvider.notifier).loadStatistics(force: true);
  }

  Future<void> _exportPdf() async {
    HapticService.medium();
    setState(() => _exportingPdf = true);
    try {
      await FinancialReportExporter().shareMonthlyReport();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.settingsExportPdfSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.settingsExportPdfFail),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsProvider);
    final analysis = ref.watch(analysisProvider);
    final scheme = Theme.of(context).colorScheme;

    if (state.isLoading && !state.hasMeaningfulData) {
      return RefreshIndicator(
        onRefresh: _refresh,
        color: scheme.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppLayout.pageGutter,
            8,
            AppLayout.pageGutter,
            AppLayout.bottomNavClearance,
          ),
          children: const [
            AppSkeletonBox(height: 28, width: 180),
            SizedBox(height: AppLayout.sectionGap),
            AppKpiSkeleton(),
            SizedBox(height: AppLayout.sectionGap),
            AppSkeletonBox(height: 220),
            SizedBox(height: AppLayout.sectionGap),
            AppSkeletonBox(height: 230),
          ],
        ),
      );
    }

    if (!state.isLoading &&
        state.errorMessage != null &&
        !state.hasMeaningfulData) {
      return RefreshIndicator(
        onRefresh: _refresh,
        color: scheme.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 96),
            IOSEmptyState(
              icon: Icons.cloud_off_rounded,
              title: AppStrings.snackErrorTitle,
              subtitle: state.errorMessage!,
              buttonLabel: AppStrings.retry,
              onPressed: _refresh,
            ),
          ],
        ),
      );
    }

    if (!state.isLoading &&
        state.errorMessage == null &&
        !state.hasMeaningfulData) {
      return RefreshIndicator(
        onRefresh: _refresh,
        color: scheme.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 96),
            IOSEmptyState(
              icon: CupertinoIcons.chart_bar,
              title: StatisticsStrings.emptyTitle,
              subtitle: StatisticsStrings.emptySubtitle,
              buttonLabel: ExpenseStrings.addExpense,
              onPressed: () => context.push(AppRoutes.expenses),
            ),
          ],
        ),
      );
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
            if (state.errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AppLayout.sectionGap),
                child: Material(
                  color: scheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    leading: Icon(Icons.error_outline, color: scheme.error),
                    title: Text(
                      state.errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: TextButton(
                      onPressed: _refresh,
                      child: Text(AppStrings.retry),
                    ),
                  ),
                ),
              ),
            ],
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.statsTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface,
                          letterSpacing: AppTypographyScale.headlineTracking,
                        ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: AppStrings.exportPdfReport,
                  child: IconButton(
                    tooltip: AppStrings.exportPdfReport,
                    onPressed: _exportingPdf ? null : _exportPdf,
                    icon: _exportingPdf
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.chromeIcon,
                            ),
                          )
                        : Icon(
                            Icons.picture_as_pdf_rounded,
                            color: scheme.chromeIcon,
                          ),
                  ),
                ),
                IconButton(
                  tooltip: ExpenseStrings.viewAllExpenses,
                  onPressed: () {
                    context.push(AppRoutes.expenses);
                  },
                  icon: Icon(CupertinoIcons.doc_text, color: scheme.chromeIcon),
                ),
                IconButton(
                  tooltip: AppStrings.navBudget,
                  onPressed: () {
                    context.push(AppRoutes.budget);
                  },
                  icon: Icon(CupertinoIcons.creditcard, color: scheme.chromeIcon),
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
                accentColor: AnalysisColors.forScore(
                  scheme,
                  analysis.behavioralScore,
                ),
                compact: true,
                onTap: () {
                  context.push(AppRoutes.analysis);
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
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _KpiTile(
            label: AppStrings.totalIncome,
            value: AppCurrency.format(state.totalIncome),
            valueColor: scheme.incomeAmount,
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _KpiTile(
            label: AppStrings.totalExpense,
            value: AppCurrency.format(state.totalExpense),
            valueColor: scheme.expenseAmount,
            icon: Icons.trending_down_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _KpiTile(
            label: AppStrings.currentBalance,
            value: AppCurrency.format(state.currentBalance),
            valueColor: scheme.incomeAmount,
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
              fontWeight: FontWeight.w500,
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
    if (state.totalIncome == 0 &&
        state.totalExpense == 0 &&
        state.currentBalance == 0) {
      return ChartEmptyState(
        icon: Icons.bar_chart_rounded,
        message: AppStrings.statsEmptyBarChart,
        height: 210,
      );
    }

    final maxVal = [
      state.totalIncome,
      state.totalExpense,
      state.currentBalance,
    ].map((e) => e.abs()).fold(0.0, (a, b) => a > b ? a : b);
    final maxY = maxVal > 0 ? maxVal * 1.2 : 10.0;

    return SizedBox(
      height: 240,
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
                    fontWeight: FontWeight.w500,
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
                  color: FintechPalette.income,
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
                  color: FintechPalette.expense,
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
                  color: FintechPalette.balance,
                ),
              ],
            ),
          ],
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
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
                reservedSize: 34,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final labels = AppStrings.barChartLabels;
                  final i = value.toInt();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        i >= 0 && i < labels.length ? labels[i] : '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.financialLabel,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
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
      return ChartEmptyState(message: AppStrings.chartNoData);
    }

    final total = data.values.fold(0.0, (a, b) => a + b);
    final palette = scheme.chartPalette;
    final sections = data.entries.toList().asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final percent = (e.value / (total == 0 ? 1 : total)) * 100;
      final color = palette[i % palette.length];
      return PieChartSectionData(
        value: e.value,
        title: '${percent.toStringAsFixed(0)}%',
        color: color,
        radius: 52,
        titleStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.95),
        ),
        titlePositionPercentageOffset: 0.62,
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
                centerSpaceRadius: 48,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(enabled: true),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: data.entries.toList().asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                final percent = (e.value / (total == 0 ? 1 : total)) * 100;
                final color = palette[i % palette.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                              ?.copyWith(
                            color: scheme.financialLabel,
                            fontWeight: FontWeight.w500,
                          ),
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 38,
                        child: Text(
                          '${percent.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: scheme.textOnCard,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          textAlign: TextAlign.end,
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
              fontWeight: FontWeight.w500,
              color: scheme.textOnCard,
            ),
          ),
          const SizedBox(height: 12),
          if (data.isEmpty)
            ChartEmptyState(
              message: AppStrings.chartNoData,
              height: 120,
              icon: Icons.trending_flat_rounded,
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
                              fontWeight: FontWeight.w500,
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
                          minHeight: 5,
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
  final Color valueColor;
  final IconData icon;

  const _KpiTile({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '$label: $value',
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: scheme.chromeIconFill,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: scheme.chromeIcon),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.textMuted,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
