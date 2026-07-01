import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/domain/models/behavioral_snapshot.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/chart_empty_state.dart';
import 'package:mudabbir/presentation/widgets/section_title_text.dart';

/// Dual bar chart — Navy income + navy2-opacity expense, 6 months, animated.
class AnalysisBarChart extends StatefulWidget {
  const AnalysisBarChart({super.key, required this.points});

  final List<MonthlySpendingPoint> points;

  @override
  State<AnalysisBarChart> createState() => _AnalysisBarChartState();
}

class _AnalysisBarChartState extends State<AnalysisBarChart>
    with SingleTickerProviderStateMixin {
  static const _animDuration = Duration(milliseconds: 1500);

  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _animDuration);
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnalysisBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _title => AppStrings.isEnglishLocale
      ? 'Last 6 months — income & spending'
      : 'آخر 6 أشهر — الدخل والمصروف';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.t2Dark : AppColors.t2Light;
    final gridColor =
        isDark ? AppColors.bdDark : AppColors.bdLight;

    final data = widget.points.length > 6
        ? widget.points.sublist(widget.points.length - 6)
        : widget.points;

    if (data.isEmpty) {
      return AppCard(
        child: ChartEmptyState(
          icon: Icons.bar_chart_rounded,
          message: AppStrings.statsNoDataForPeriod,
          height: 160,
        ),
      );
    }

    final maxY = data
        .map((p) => p.income > p.expense ? p.income : p.expense)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final chartMaxY = maxY <= 0 ? 100.0 : maxY * 1.15;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitleText(
            _title,
            style: AppTypography.titleMedium(
              isDark ? AppColors.t1Dark : AppColors.navy1,
            ).copyWith(fontWeight: AppFontWeights.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _LegendDot(
                color: AppColors.navy1,
                label: AppStrings.statsTotalIncomeLabel,
                textColor: textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              _LegendDot(
                color: AppColors.navy2.withValues(alpha: 0.55),
                label: AppStrings.statsTotalExpenseLabel,
                textColor: textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 220,
            child: AnimatedBuilder(
              animation: _curve,
              builder: (context, _) {
                final factor = _curve.value;
                return BarChart(
                  BarChartData(
                    maxY: chartMaxY,
                    minY: 0,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: chartMaxY / 4,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: gridColor.withValues(alpha: 0.5),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          getTitlesWidget: (value, _) {
                            if (value <= 0 || value > chartMaxY) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              AppCurrency.formatCompact(value),
                              style: AppTypography.labelSmall(textSecondary),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= data.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                data[index].label,
                                style: AppTypography.labelSmall(textSecondary),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < data.length; i++)
                        BarChartGroupData(
                          x: i,
                          barsSpace: 4,
                          barRods: [
                            BarChartRodData(
                              toY: data[i].income * factor,
                              width: 10,
                              color: AppColors.navy1,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            BarChartRodData(
                              toY: data[i].expense * factor,
                              width: 10,
                              color: AppColors.navy2.withValues(alpha: 0.55),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.textColor,
  });

  final Color color;
  final String label;
  final Color textColor;

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
        Text(label, style: AppTypography.labelSmall(textColor)),
      ],
    );
  }
}
