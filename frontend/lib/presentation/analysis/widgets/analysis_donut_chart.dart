import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/chart_empty_state.dart';
import 'package:mudabbir/presentation/widgets/section_title_text.dart';

/// Donut chart with side legend — expense distribution by category.
class AnalysisDonutChart extends StatefulWidget {
  const AnalysisDonutChart({super.key, required this.expenseByCategory});

  final Map<String, double> expenseByCategory;

  static const _sliceColors = [
    AppColors.navy1,
    AppColors.navy3,
    AppColors.navy4,
    AppColors.gold,
  ];

  @override
  State<AnalysisDonutChart> createState() => _AnalysisDonutChartState();
}

class _AnalysisDonutChartState extends State<AnalysisDonutChart>
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
  void didUpdateWidget(covariant AnalysisDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expenseByCategory != widget.expenseByCategory) {
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

  List<_Slice> _buildSlices() {
    final entries = widget.expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) return const [];

    final top = entries.take(4).toList();
    final topTotal = top.fold<double>(0, (sum, e) => sum + e.value);
    final grandTotal = entries.fold<double>(0, (sum, e) => sum + e.value);
    final other = grandTotal - topTotal;

    final slices = <_Slice>[
      for (var i = 0; i < top.length; i++)
        _Slice(
          label: EntityLocalizations.categoryName(top[i].key),
          value: top[i].value,
          color: AnalysisDonutChart._sliceColors[i],
        ),
    ];

    if (other > 0.01) {
      if (slices.length < 4) {
        slices.add(
          _Slice(
            label: AppStrings.txSheetCatOther,
            value: other,
            color: AnalysisDonutChart._sliceColors[slices.length],
          ),
        );
      } else {
        slices[3] = _Slice(
          label: AppStrings.txSheetCatOther,
          value: slices[3].value + other,
          color: slices[3].color,
        );
      }
    }

    return slices;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.t1Dark : AppColors.t1Light;
    final textSecondary = isDark ? AppColors.t2Dark : AppColors.t2Light;
    final slices = _buildSlices();
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);

    if (slices.isEmpty || total <= 0) {
      return AppCard(
        child: ChartEmptyState(
          icon: Icons.donut_large_rounded,
          message: AppStrings.statsNoCategoriesYet,
          height: 160,
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitleText(
            AppStrings.statsCategoryBreakdownTitle,
            style: AppTypography.titleMedium(AppColors.navy1).copyWith(
              fontWeight: AppFontWeights.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 168,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: AnimatedBuilder(
                    animation: _curve,
                    builder: (context, _) {
                      return PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          sectionsSpace: 2,
                          centerSpaceRadius: 44,
                          sections: [
                            for (final slice in slices)
                              PieChartSectionData(
                                value: slice.value * _curve.value,
                                color: slice.color,
                                radius: 34,
                                showTitle: false,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final slice in slices)
                        _LegendRow(
                          color: slice.color,
                          name: slice.label,
                          percent:
                              total > 0 ? (slice.value / total) * 100 : 0,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Slice {
  const _Slice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.name,
    required this.percent,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color color;
  final String name;
  final double percent;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: AppTypography.bodySmall(textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${percent.toStringAsFixed(0)}%',
            style: AppTypography.labelSmall(textSecondary).copyWith(
              fontWeight: AppFontWeights.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}
