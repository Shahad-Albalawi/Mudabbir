import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mudabbir/domain/models/behavioral_snapshot.dart';
import 'package:mudabbir/presentation/resources/behavioral_strings.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/resources/styles_manager.dart';
import 'package:mudabbir/presentation/resources/values_manager.dart';
import 'package:mudabbir/presentation/widgets/ios_loading_widget.dart';
import 'analysis_viewmodel.dart';

class AnalysisView extends ConsumerWidget {
  const AnalysisView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analysisProvider);
    final scheme = Theme.of(context).colorScheme;

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: scheme.surfaceContainerHighest,
        appBar: AppBar(
          title: Text(AppStrings.statsAnalysisTitle),
          elevation: 0,
          backgroundColor: scheme.surfaceContainerHighest,
          foregroundColor: scheme.onSurface,
        ),
        body: const Center(child: IOSLoadingWidget(size: 56)),
      );
    }

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text(AppStrings.statsAnalysisTitle),
        elevation: 0,
        backgroundColor: scheme.surfaceContainerHighest,
        foregroundColor: scheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBehavioralScoreCard(context, state),
            const SizedBox(height: 20),
            _buildMonthComparisonCard(context, state),
            const SizedBox(height: 20),
            _buildAnomaliesSection(context, state),
            const SizedBox(height: 20),
            _buildHealthScoreCard(context, state),
            const SizedBox(height: 20),
            _buildStatusCard(
              context,
              AppStrings.analysisBalanceTitle,
              state.balanceStatus,
              Icons.account_balance_wallet,
              _getStatusColor(state.balanceStatus),
            ),
            const SizedBox(height: 16),
            _buildStatusCard(
              context,
              AppStrings.analysisSpendingTitle,
              state.spendingAnalysis,
              Icons.shopping_cart,
              _getStatusColor(state.spendingAnalysis),
            ),
            const SizedBox(height: 16),
            _buildStatusCard(
              context,
              AppStrings.analysisSavingsBehaviorTitle,
              state.savingsAnalysis,
              Icons.savings,
              _getStatusColor(state.savingsAnalysis),
            ),
            const SizedBox(height: 20),
            _buildCategoryInsights(context, state),
            const SizedBox(height: 20),
            if (state.weekdayInsight.isNotEmpty)
              _buildWeekdayInsight(context, state),
            if (state.weekdayInsight.isNotEmpty) const SizedBox(height: 20),
            _buildRecommendations(context, state),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBehavioralScoreCard(BuildContext context, AnalysisState state) {
    final scheme = Theme.of(context).colorScheme;
    final color = _getHealthColor(state.behavioralRating);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary.withValues(alpha: 0.12),
            scheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorManager.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            BehavioralStrings.behavioralScoreTitle,
            style: getBoldStyle(
              fontSize: FontSize.s18,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            BehavioralStrings.behavioralScoreSubtitle,
            style: getRegularStyle(
              fontSize: FontSize.s12,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: state.behavioralScore / 100,
                      strokeWidth: 8,
                      backgroundColor: scheme.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                    Text(
                      '${state.behavioralScore}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.behavioralRating,
                      style: getBoldStyle(
                        fontSize: FontSize.s20,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.monthComparisonSummary,
                      style: getRegularStyle(
                        fontSize: FontSize.s12,
                        color: scheme.onSurfaceVariant,
                      ).copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthComparisonCard(BuildContext context, AnalysisState state) {
    if (state.monthlyTrend.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final maxY = state.monthlyTrend
        .map((p) => p.expense)
        .fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            BehavioralStrings.monthComparisonTitle,
            style: getBoldStyle(fontSize: FontSize.s16, color: scheme.onSurface),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY <= 0 ? 100 : maxY * 1.2,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY <= 0 ? 25 : maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: scheme.outline.withValues(alpha: 0.15),
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
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= state.monthlyTrend.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            state.monthlyTrend[index].label,
                            style: getRegularStyle(
                              fontSize: FontSize.s12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < state.monthlyTrend.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: state.monthlyTrend[i].expense,
                          width: 14,
                          color: i == state.monthlyTrend.length - 1
                              ? ColorManager.primary
                              : ColorManager.primary.withValues(alpha: 0.45),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnomaliesSection(BuildContext context, AnalysisState state) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          BehavioralStrings.anomaliesTitle,
          style: getBoldStyle(fontSize: FontSize.s20, color: scheme.onSurface),
        ),
        const SizedBox(height: 12),
        if (state.anomalies.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorManager.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorManager.success.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              BehavioralStrings.noAnomalies,
              style: getRegularStyle(
                fontSize: FontSize.s14,
                color: scheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...state.anomalies.map(
            (anomaly) => _buildAnomalyCard(context, anomaly),
          ),
      ],
    );
  }

  Widget _buildAnomalyCard(BuildContext context, SpendingAnomaly anomaly) {
    final scheme = Theme.of(context).colorScheme;
    final color = _anomalyColor(anomaly.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: ColorManager.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_anomalyIcon(anomaly.type), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  BehavioralStrings.anomalyTitle(anomaly),
                  style: getSemiBoldStyle(
                    fontSize: FontSize.s14,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  BehavioralStrings.anomalyMessage(anomaly),
                  style: getRegularStyle(
                    fontSize: FontSize.s12,
                    color: scheme.onSurfaceVariant,
                  ).copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayInsight(BuildContext context, AnalysisState state) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded, color: ColorManager.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  BehavioralStrings.weekdayPatternTitle,
                  style: getSemiBoldStyle(
                    fontSize: FontSize.s14,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.weekdayInsight,
                  style: getRegularStyle(
                    fontSize: FontSize.s12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _anomalyColor(AnomalySeverity severity) {
    switch (severity) {
      case AnomalySeverity.critical:
        return ColorManager.error;
      case AnomalySeverity.warning:
        return ColorManager.warning;
      case AnomalySeverity.info:
        return ColorManager.primary;
    }
  }

  IconData _anomalyIcon(AnomalyType type) {
    switch (type) {
      case AnomalyType.monthlySpike:
        return Icons.trending_up_rounded;
      case AnomalyType.overspending:
        return Icons.warning_amber_rounded;
      case AnomalyType.categorySpike:
        return Icons.category_rounded;
      case AnomalyType.largeTransaction:
        return Icons.payments_rounded;
      case AnomalyType.weekendSplurge:
        return Icons.weekend_rounded;
      case AnomalyType.spendingBurst:
        return Icons.receipt_long_rounded;
    }
  }

  Widget _buildHealthScoreCard(BuildContext context, AnalysisState state) {
    final scheme = Theme.of(context).colorScheme;
    final color = _getHealthColor(state.financialHealthRating);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.analysisHealthScoreTitle,
                  style: getBoldStyle(
                    fontSize: FontSize.s18,
                    color: scheme.onSurface,
                  ),
                ),
                Icon(
                  _getHealthIcon(state.financialHealthRating),
                  color: color,
                  size: 32,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              width: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: CircularProgressIndicator(
                      value: state.healthScore / 100,
                      strokeWidth: 12,
                      backgroundColor: scheme.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.healthScore.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        state.financialHealthRating,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.analysisSavingsRateLabel,
                    style: getSemiBoldStyle(
                      fontSize: FontSize.s16,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    "${state.savingsRate.toStringAsFixed(1)}%",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getSavingsRateColor(state.savingsRate),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: getBoldStyle(
                      fontSize: FontSize.s16,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                description,
                style: getRegularStyle(
                  fontSize: FontSize.s14,
                  color: scheme.onSurfaceVariant,
                ).copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryInsights(BuildContext context, AnalysisState state) {
    if (state.categoryInsights.isEmpty) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.analysisCategoryInsightsTitle,
          style: getBoldStyle(fontSize: FontSize.s20, color: scheme.onSurface),
        ),
        const SizedBox(height: 12),
        ...state.categoryInsights.entries.map((entry) {
          final color = _getCategoryInsightColor(entry.value);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.category_rounded, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        EntityLocalizations.categoryName(entry.key),
                        style: getSemiBoldStyle(
                          fontSize: FontSize.s14,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value,
                        style: getRegularStyle(
                          fontSize: FontSize.s12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context, AnalysisState state) {
    if (state.recommendations.isEmpty) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          BehavioralStrings.personalizedRecsTitle,
          style: getBoldStyle(fontSize: FontSize.s20, color: scheme.onSurface),
        ),
        const SizedBox(height: 12),
        ...state.recommendations.asMap().entries.map((entry) {
          final index = entry.key;
          final recommendation = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorManager.primaryWithOpacity10,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ColorManager.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${index + 1}",
                    style: getBoldStyle(
                      fontSize: FontSize.s14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    recommendation,
                    style: getRegularStyle(
                      fontSize: FontSize.s14,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  static bool _isAr(String rating, String ar, String en) {
    final l = rating.toLowerCase();
    return l == ar || l == en;
  }

  Color _getHealthColor(String rating) {
    final l = rating.toLowerCase();
    if (_isAr(rating, 'ممتاز', 'excellent')) {
      return ColorManager.success;
    }
    if (_isAr(rating, 'جيد', 'good')) {
      return const Color(0xFF52C41A);
    }
    if (_isAr(rating, 'مقبول', 'fair')) {
      return ColorManager.warning;
    }
    if (_isAr(rating, 'ضعيف', 'weak')) {
      return const Color(0xFFFA8C16);
    }
    if (_isAr(rating, 'يحتاج تحسين', 'needs work')) {
      return ColorManager.warning;
    }
    if (_isAr(rating, 'معرض للخطر', 'at risk')) {
      return ColorManager.error;
    }
    if (l == 'outstanding') return ColorManager.success;
    return ColorManager.grey;
  }

  IconData _getHealthIcon(String rating) {
    final l = rating.toLowerCase();
    if (_isAr(rating, 'ممتاز', 'excellent') || l == 'outstanding') {
      return Icons.sentiment_very_satisfied;
    }
    if (_isAr(rating, 'جيد', 'good')) {
      return Icons.sentiment_satisfied;
    }
    if (_isAr(rating, 'مقبول', 'fair')) {
      return Icons.sentiment_neutral;
    }
    if (_isAr(rating, 'ضعيف', 'weak')) {
      return Icons.sentiment_dissatisfied;
    }
    if (_isAr(rating, 'حرج', 'critical')) {
      return Icons.sentiment_very_dissatisfied;
    }
    return Icons.help_outline;
  }

  Color _getStatusColor(String description) {
    final d = description.toLowerCase();
    if (d.startsWith('حرج') || d.startsWith('critical') || d.startsWith('🚨')) {
      return ColorManager.error;
    }
    if (d.startsWith('تحذير') ||
        d.startsWith('warning') ||
        d.startsWith('⚠️')) {
      return const Color(0xFFFA8C16);
    }
    if (d.startsWith('تنبيه') || d.startsWith('alert')) {
      return ColorManager.warning;
    }
    if (d.startsWith('مقبول') || d.startsWith('fair')) {
      return const Color(0xFFFFA940);
    }
    if (d.startsWith('جيد') || d.startsWith('good')) {
      return const Color(0xFF52C41A);
    }
    if (d.startsWith('ممتاز') ||
        d.startsWith('excellent') ||
        d.startsWith('استثنائي') ||
        d.startsWith('outstanding')) {
      return ColorManager.success;
    }
    if (d.startsWith('weak') || d.startsWith('ضعيف')) {
      return const Color(0xFFFA8C16);
    }
    return ColorManager.primary;
  }

  Color _getCategoryInsightColor(String insight) {
    final i = insight.toLowerCase();
    if (i.startsWith('تنبيه') || i.startsWith('alert')) {
      return ColorManager.error;
    }
    if (i.startsWith('عالي') || i.startsWith('high')) {
      return ColorManager.warning;
    }
    if (i.startsWith('متوسط') || i.startsWith('medium')) {
      return const Color(0xFFFFA940);
    }
    if (i.startsWith('منخفض') || i.startsWith('low')) {
      return const Color(0xFF52C41A);
    }
    if (i.startsWith('قليل جداً') || i.startsWith('very low')) {
      return ColorManager.success;
    }
    return ColorManager.primary;
  }

  Color _getSavingsRateColor(double rate) {
    if (rate < 0) {
      return ColorManager.error;
    } else if (rate < 10) {
      return ColorManager.warning;
    } else if (rate < 20) {
      return const Color(0xFFFFA940);
    } else if (rate < 30) {
      return const Color(0xFF52C41A);
    } else {
      return ColorManager.success;
    }
  }
}
