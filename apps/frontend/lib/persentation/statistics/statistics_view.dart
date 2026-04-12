import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mudabbir/persentation/analysis/analysis_view.dart';
import 'package:mudabbir/persentation/home/home_viewmodel.dart';
import 'package:mudabbir/persentation/resources/app_theme_extensions.dart';
import 'package:mudabbir/persentation/resources/color_manager.dart';
import 'package:mudabbir/persentation/resources/entity_localizations.dart';
import 'package:mudabbir/persentation/resources/font_manager.dart';
import 'package:mudabbir/persentation/resources/strings_manager.dart';
import 'package:mudabbir/persentation/resources/styles_manager.dart';
import 'package:mudabbir/persentation/widgets/ios_loading_widget.dart';
import 'statistics_viewmodel.dart';

/// Premium chart colors – aligned with ColorManager, soft & elegant.
class _ChartColors {
  static const List<Color> piePalette = [
    Color(0xFF1F7A54),
    Color(0xFF2FA06F),
    Color(0xFF4AB88A),
    Color(0xFF6BC9A0),
    Color(0xFF3D8B6A),
  ];
}

/// Statistics tab - premium, modern, iOS-inspired design.
class StatisticsView extends ConsumerWidget {
  const StatisticsView({super.key});

  static const double _cardRadius = 16;
  static const double _sectionSpacing = 20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statisticsProvider);
    final homeViewModel = ref.read(homeProvider.notifier);
    homeViewModel.reload();

    if (state.isLoading) {
      return const Center(child: IOSLoadingWidget(size: 56));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.statsTitle,
            style: getBoldStyle(
              fontSize: FontSize.s24,
              color: context.appColors.onSurface,
            ),
          ),
          const SizedBox(height: 20),

          _buildAnalysisCard(context),
          const SizedBox(height: _sectionSpacing),

          _buildPremiumChartCard(
            context,
            AppStrings.statsIncomeExpense,
            Icons.bar_chart_rounded,
            _buildBarChart(context, state),
          ),
          const SizedBox(height: _sectionSpacing),

          _buildPremiumChartCard(
            context,
            AppStrings.statsExpenseByCategory,
            Icons.pie_chart_rounded,
            _buildPieChartContent(
              context,
              state.expenseByCategory,
              isExpense: true,
            ),
          ),
          const SizedBox(height: _sectionSpacing),

          _buildPremiumChartCard(
            context,
            AppStrings.statsIncomeByCategory,
            Icons.pie_chart_outline_rounded,
            _buildPieChartContent(
              context,
              state.incomeByCategory,
              isExpense: false,
            ),
          ),
          const SizedBox(height: _sectionSpacing),

          _buildProgressSection(
            context,
            AppStrings.statsGoalsProgress,
            Icons.flag_rounded,
            state.goalsProgress,
          ),
          const SizedBox(height: _sectionSpacing),

          _buildProgressSection(
            context,
            AppStrings.statsBudgetsProgress,
            Icons.account_balance_wallet_rounded,
            state.budgetsProgress,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context) {
    final scheme = context.appColors;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AnalysisView()),
            );
          },
          borderRadius: BorderRadius.circular(_cardRadius),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(_cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.primarySoft(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
                    color: scheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.statsAnalysisTitle,
                        style: getSemiBoldStyle(
                          fontSize: FontSize.s18,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.statsAnalysisSubtitle,
                        style: getRegularStyle(
                          fontSize: FontSize.s14,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: scheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumChartCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget chart,
  ) {
    final scheme = context.appColors;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(_cardRadius),
          boxShadow: context.appCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.primarySoft(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: scheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: getSemiBoldStyle(
                      fontSize: FontSize.s16,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, StatisticsState state) {
    final scheme = context.appColors;
    final maxVal = [
      state.totalIncome,
      state.totalExpense,
      state.currentBalance,
    ].map((e) => e.abs()).fold(0.0, (a, b) => a > b ? a : b);
    final maxY = maxVal > 0 ? maxVal * 1.2 : 10.0;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: state.totalIncome,
                  width: 28,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      ColorManager.success.withValues(alpha: 0.7),
                      ColorManager.success,
                    ],
                  ),
                ),
              ],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: state.totalExpense,
                  width: 28,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      ColorManager.error.withValues(alpha: 0.7),
                      ColorManager.error,
                    ],
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: state.currentBalance,
                  width: 28,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      scheme.primary.withValues(alpha: 0.7),
                      scheme.primary,
                    ],
                  ),
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, m) => Text(
                  v.toInt().toString(),
                  style: getRegularStyle(
                    fontSize: FontSize.s12,
                    color: scheme.onSurfaceVariant,
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
                      i >= 0 && i < labels.length ? labels[i] : "",
                      style: getMediumStyle(
                        fontSize: FontSize.s12,
                        color: scheme.onSurfaceVariant,
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
    Map<String, double> data, {
    required bool isExpense,
  }) {
    final scheme = context.appColors;
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
              style: getRegularStyle(
                fontSize: FontSize.s14,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final total = data.values.fold(0.0, (a, b) => a + b);
    final sections = data.entries.toList().asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final percent = (e.value / (total == 0 ? 1 : total)) * 100;
      final color = _ChartColors.piePalette[i % _ChartColors.piePalette.length];
      return PieChartSectionData(
        value: e.value,
        title: "${percent.toStringAsFixed(0)}%",
        color: color,
        radius: 52,
        titleStyle: getSemiBoldStyle(
          fontSize: FontSize.s12,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 36,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(enabled: true),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.entries.toList().asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                final percent = (e.value / (total == 0 ? 1 : total)) * 100;
                final color =
                    _ChartColors.piePalette[i % _ChartColors.piePalette.length];
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
                          e.key,
                          style: getRegularStyle(
                            fontSize: FontSize.s12,
                            color: scheme.onSurfaceVariant,
                          ),
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "${percent.toStringAsFixed(0)}%",
                        style: getSemiBoldStyle(
                          fontSize: FontSize.s12,
                          color: scheme.onSurface,
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

  /// Progress indicators for goals/budgets - premium card style.
  Widget _buildProgressSection(
    BuildContext context,
    String title,
    IconData icon,
    Map<String, double> data,
  ) {
    final scheme = context.appColors;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(_cardRadius),
          boxShadow: context.appCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.primarySoft(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: scheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: getSemiBoldStyle(
                      fontSize: FontSize.s16,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (data.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_flat_rounded,
                      size: 24,
                      color: scheme.outline.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.chartNoData,
                      style: getRegularStyle(
                        fontSize: FontSize.s14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: data.entries.toList().asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  final color = _ChartColors
                      .piePalette[i % _ChartColors.piePalette.length];
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
                                style: getMediumStyle(
                                  fontSize: FontSize.s14,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                            Text(
                              "${e.value.toStringAsFixed(0)}%",
                              style: getSemiBoldStyle(
                                fontSize: FontSize.s14,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (e.value / 100).clamp(0.0, 1.0),
                            backgroundColor: scheme.outline.withValues(
                              alpha: 0.22,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
