import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/analysis/analysis_trend_utils.dart';
import 'package:mudabbir/presentation/analysis/analysis_viewmodel.dart';
import 'package:mudabbir/presentation/analysis/widgets/analysis_bar_chart.dart';
import 'package:mudabbir/presentation/analysis/widgets/analysis_behavior_sections.dart';
import 'package:mudabbir/presentation/analysis/widgets/analysis_donut_chart.dart';
import 'package:mudabbir/presentation/analysis/widgets/analysis_kpi_grid.dart';
import 'package:mudabbir/presentation/analysis/widgets/analysis_pdf_exporter.dart';
import 'package:mudabbir/presentation/analysis/widgets/health_gauge.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/analysis/behavioral_copy_helpers.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/statistics/statistics_viewmodel.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/widgets/app_skeleton.dart';
import 'package:mudabbir/presentation/widgets/section_title_text.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';

const _sectionGap = AppSpacing.lg;

/// Unified analysis dashboard — health score, KPIs, charts, insights, PDF.
class AnalysisView extends ConsumerStatefulWidget {
  const AnalysisView({super.key, this.financialHealthFocus = false});

  /// When true, opened from الإحصائيات → الصحة المالية (narrower title).
  final bool financialHealthFocus;

  @override
  ConsumerState<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends ConsumerState<AnalysisView> {
  bool _exporting = false;

  String get _pageTitle {
    if (widget.financialHealthFocus) {
      return AppStrings.financialHealth;
    }
    return AppStrings.isEnglishLocale
        ? 'Statistics & financial health'
        : 'الإحصائيات وصحة مالك';
  }

  Future<void> _exportPdf() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final analysis = ref.read(analysisProvider);
      final stats = ref.read(statisticsProvider);
      await AnalysisPdfExporter.exportPDF(
        analysis: analysis,
        statistics: stats,
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analysisProvider);
    final stats = ref.watch(statisticsProvider);
    final colors = context.colors;
    final pageBg = colors.background;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.isLoading || stats.isLoading) {
      return _scaffold(
        pageBg: pageBg,
        body: ListView(
          padding: _pagePadding,
          children: const [
            AppSkeletonBox(
              height: 200,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
            ),
            SizedBox(height: _sectionGap),
            AppSkeletonBox(
              height: 200,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
            ),
            SizedBox(height: _sectionGap),
            AppSkeletonBox(
              height: 280,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
            ),
          ],
        ),
      );
    }

    if (state.error != null && state.error!.isNotEmpty) {
      return _scaffold(
        pageBg: pageBg,
        body: Center(
          child: IOSEmptyState(
            icon: Icons.cloud_off_rounded,
            title: AppStrings.snackErrorTitle,
            subtitle: state.error!,
            buttonLabel: AppStrings.retry,
            onPressed: () => ref.read(analysisProvider.notifier).retry(),
          ),
        ),
      );
    }

    final netSavings = stats.totalIncome - stats.totalExpense;
    final healthRating = state.financialHealthRating.isNotEmpty
        ? state.financialHealthRating
        : BehavioralCopyHelpers.ratingForScore(state.healthScore.round());
    final trends = AnalysisDashboardTrends.fromMonthlyTrend(
      state.monthlyTrend,
      state.savingsRate,
    );

    return _scaffold(
      pageBg: pageBg,
      body: RefreshIndicator(
        onRefresh: () => ref.read(analysisProvider.notifier).retry(),
        color: colors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: _pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionTitleText(
                _pageTitle,
                style: AppTypography.headlineSmall(
                  colors.primary,
                ).copyWith(fontWeight: AppFontWeights.bold),
              ),
              const SizedBox(height: _sectionGap),
              _HealthGaugeCard(
                score: state.healthScore.round(),
                rating: healthRating,
                savingsRate: state.savingsRate,
                isDark: isDark,
              ),
              const SizedBox(height: _sectionGap),
              AnalysisKpiGrid(
                totalIncome: stats.totalIncome,
                totalExpense: stats.totalExpense,
                netSavings: netSavings,
                savingsRate: state.savingsRate,
                trends: trends,
                isDark: isDark,
              ),
              const SizedBox(height: _sectionGap),
              AnalysisBarChart(points: state.monthlyTrend),
              const SizedBox(height: _sectionGap),
              AnalysisDonutChart(
                expenseByCategory: stats.expenseByCategory,
              ),
              const SizedBox(height: _sectionGap),
              AnalysisBehaviorSections(
                analysis: state,
                statistics: stats,
                isDark: isDark,
              ),
              const SizedBox(height: _sectionGap),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _exporting ? null : _exportPdf,
                  icon: _exporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(AppStrings.exportPdfReport),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy1,
                    foregroundColor: AppColors.textInverse,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scaffold({required Color pageBg, required Widget body}) {
    return AppGroupedScaffold(
      largeTitle: true,
      titleText: _pageTitle,
      actions: [
        IconButton(
          tooltip: AppStrings.exportPdfReport,
          onPressed: _exporting ? null : _exportPdf,
          icon: const Icon(CupertinoIcons.doc_text),
        ),
      ],
      body: ColoredBox(color: pageBg, child: body),
    );
  }

  static const _pagePadding = EdgeInsets.fromLTRB(
    AppLayout.pageGutter,
    AppSpacing.sm,
    AppLayout.pageGutter,
    AppLayout.bottomNavClearance,
  );
}

class _HealthGaugeCard extends StatelessWidget {
  const _HealthGaugeCard({
    required this.score,
    required this.rating,
    required this.savingsRate,
    required this.isDark,
  });

  final int score;
  final String rating;
  final double savingsRate;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textSecondary = isDark ? AppColors.t2Dark : AppColors.t2Light;
    final chipBg = AppColors.greenS;
    final chipColor = AppColors.green;

    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          HealthGauge(score: score),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: chipBg.withValues(alpha: isDark ? 0.35 : 1),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              '$rating · ${savingsRate.toStringAsFixed(1)}%',
              style: AppTypography.labelMedium(chipColor).copyWith(
                fontWeight: AppFontWeights.semiBold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.statsSavingsRateLabel,
            style: AppTypography.bodySmall(textSecondary),
          ),
        ],
      ),
    );
  }
}
