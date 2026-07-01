import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' hide TextDirection;
import 'package:mudabbir/features/analysis/data/pdf_content.dart';
import 'package:mudabbir/presentation/analysis/analysis_trend_utils.dart';
import 'package:mudabbir/presentation/analysis/analysis_viewmodel.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/saudi_riyal_font.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/statistics/statistics_viewmodel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Analysis dashboard PDF — Navy + Gold brand, all dashboard sections.
class AnalysisPdfExporter {
  AnalysisPdfExporter._();

  static const _navy = '#0F2878';
  static const _gold = '#C9A227';
  static const _muted = '#64748B';
  static const _pageBg = '#F8FAFF';

  static Future<void> exportPDF({
    required AnalysisState analysis,
    required StatisticsState statistics,
  }) async {
    pw.Font? regular;
    pw.Font? bold;
    pw.Font? riyalFont;

    try {
      regular = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Eight/Eight-Regular.ttf'),
      );
      bold = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Eight/Eight-Bold.ttf'),
      );
      riyalFont = pw.Font.ttf(
        await rootBundle.load(SaudiRiyalFont.regularAsset),
      );
    } catch (_) {
      regular = null;
      bold = null;
      riyalFont = null;
    }

    String formatPdfAmount(double value) {
      final number = AppCurrency.formatNumber(value);
      if (riyalFont != null && SaudiRiyalFont.isAvailable) {
        return '$number ${SaudiRiyalFont.symbol}';
      }
      return '$number ريال';
    }

    pw.TextStyle titleStyle({double size = 14}) => pw.TextStyle(
          font: bold,
          fontSize: size,
          color: PdfColor.fromHex(_navy),
        );

    pw.TextStyle bodyStyle({double size = 10}) => pw.TextStyle(
          font: regular,
          fontSize: size,
          color: PdfColor.fromHex(_muted),
          fontFallback: riyalFont != null ? [riyalFont] : const [],
        );

    pw.TextStyle valueStyle() => pw.TextStyle(
          font: bold,
          fontSize: 11,
          color: PdfColor.fromHex(_navy),
          fontFallback: riyalFont != null ? [riyalFont] : const [],
        );

    final pdf = pw.Document();
    final month = DateFormat('yyyy-MM').format(DateTime.now());
    final isEn = AppStrings.isEnglishLocale;
    final lang = isEn ? 'en' : 'ar';
    final labels = PDFContent.labels(lang);
    final netSavings = statistics.totalIncome - statistics.totalExpense;
    final trends = AnalysisDashboardTrends.fromMonthlyTrend(
      analysis.monthlyTrend,
      analysis.savingsRate,
    );

    final sectionTitle = labels['reportTitle']!;

    final categories = statistics.expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final categoryTotal =
        categories.fold<double>(0, (sum, e) => sum + e.value);
    final topCategoryName = categories.isEmpty
        ? (isEn ? 'spending' : 'الإنفاق')
        : EntityLocalizations.categoryName(categories.first.key);
    final topCategoryPct = categories.isEmpty || categoryTotal <= 0
        ? 0
        : (categories.first.value / categoryTotal * 100).round();
    final smartRecommendation = PDFContent.recommendation(
      savingsRate: analysis.savingsRate,
      topCategory: topCategoryName,
      pct: topCategoryPct,
      lang: lang,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex(_navy),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          isEn ? 'Mudabbir' : 'مدبّر',
                          style: pw.TextStyle(
                            font: bold,
                            fontSize: 22,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          sectionTitle,
                          style: pw.TextStyle(
                            font: regular,
                            fontSize: 12,
                            color: PdfColor.fromHex(_gold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Text(
                    month,
                    style: pw.TextStyle(
                      font: regular,
                      fontSize: 11,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              labels['healthScore']!,
              style: titleStyle(),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex(_pageBg),
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(
                  color: PdfColor.fromHex('#E2E8F0'),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${analysis.healthScore.round()} / 100',
                    style: pw.TextStyle(
                      font: bold,
                      fontSize: 28,
                      color: PdfColor.fromHex(_navy),
                    ),
                  ),
                  pw.Text(
                    '${analysis.financialHealthRating} · ${analysis.savingsRate.toStringAsFixed(1)}%',
                    style: valueStyle(),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              isEn ? 'Key indicators' : 'المؤشرات الرئيسية',
              style: titleStyle(),
            ),
            pw.SizedBox(height: 8),
            _kpiRow(
              AppStrings.statsTotalIncomeLabel,
              formatPdfAmount(statistics.totalIncome),
              '${trends.income.percentChange.abs().toStringAsFixed(1)}%',
              valueStyle: valueStyle(),
              bodyStyle: bodyStyle(),
            ),
            _kpiRow(
              AppStrings.statsTotalExpenseLabel,
              formatPdfAmount(statistics.totalExpense),
              '${trends.expense.percentChange.abs().toStringAsFixed(1)}%',
              valueStyle: valueStyle(),
              bodyStyle: bodyStyle(),
            ),
            _kpiRow(
              AppStrings.statsNetSavingsLabel,
              formatPdfAmount(netSavings),
              '${trends.netSavings.percentChange.abs().toStringAsFixed(1)}%',
              valueStyle: valueStyle(),
              bodyStyle: bodyStyle(),
            ),
            _kpiRow(
              labels['savingsRate']!,
              '${analysis.savingsRate.toStringAsFixed(1)}%',
              '${trends.savingsRate.percentChange.abs().toStringAsFixed(1)}%',
              valueStyle: valueStyle(),
              bodyStyle: bodyStyle(),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              isEn ? '6-month trend' : 'اتجاه آخر 6 أشهر',
              style: titleStyle(),
            ),
            pw.SizedBox(height: 6),
            ...analysis.monthlyTrend.take(6).map(
                  (p) => _kpiRow(
                    p.label,
                    '${formatPdfAmount(p.income)} / ${formatPdfAmount(p.expense)}',
                    '',
                    valueStyle: valueStyle(),
                    bodyStyle: bodyStyle(size: 9),
                  ),
                ),
          ],
        ),
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              labels['expenseBreakdown']!,
              style: titleStyle(size: 16),
            ),
            pw.SizedBox(height: 10),
            if (categories.isEmpty)
              pw.Text(
                isEn ? 'No category data yet.' : 'لا توجد بيانات فئات بعد.',
                style: bodyStyle(),
              )
            else
              ...categories.take(8).map((entry) {
                final pct = categoryTotal > 0
                    ? (entry.value / categoryTotal * 100).toStringAsFixed(0)
                    : '0';
                return _kpiRow(
                  EntityLocalizations.categoryName(entry.key),
                  formatPdfAmount(entry.value),
                  '$pct%',
                  valueStyle: valueStyle(),
                  bodyStyle: bodyStyle(),
                );
              }),
            pw.SizedBox(height: 20),
            pw.Text(
              labels['behavior']!,
              style: titleStyle(size: 16),
            ),
            pw.SizedBox(height: 8),
            if (analysis.savingsAnalysis.isNotEmpty)
              pw.Text(analysis.savingsAnalysis, style: bodyStyle()),
            if (analysis.monthComparisonSummary.isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Text(analysis.monthComparisonSummary, style: bodyStyle()),
            ],
            pw.SizedBox(height: 16),
            pw.Text(
              isEn ? 'Balance status' : 'حالة الرصيد',
              style: titleStyle(size: 16),
            ),
            pw.SizedBox(height: 8),
            pw.Text(analysis.balanceStatus, style: bodyStyle()),
            _kpiRow(
              AppStrings.statsTotalIncomeLabel,
              formatPdfAmount(statistics.totalIncome),
              '',
              valueStyle: valueStyle(),
              bodyStyle: bodyStyle(),
            ),
            _kpiRow(
              AppStrings.statsTotalExpenseLabel,
              formatPdfAmount(statistics.totalExpense),
              '',
              valueStyle: valueStyle(),
              bodyStyle: bodyStyle(),
            ),
            _kpiRow(
              AppStrings.statsNetSavingsLabel,
              formatPdfAmount(netSavings),
              '',
              valueStyle: valueStyle(),
              bodyStyle: bodyStyle(),
            ),
          ],
        ),
      ),
    );

    final goals = statistics.goalsProgress.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              labels['forecast']!,
              style: titleStyle(size: 16),
            ),
            pw.SizedBox(height: 8),
            if (analysis.weekdayInsight.isNotEmpty)
              pw.Text(analysis.weekdayInsight, style: bodyStyle()),
            if (analysis.spendingAnalysis.isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Text(analysis.spendingAnalysis, style: bodyStyle()),
            ],
            pw.SizedBox(height: 8),
            _kpiRow(
              isEn ? 'Projected savings' : 'التوفير المتوقع',
              formatPdfAmount(
                statistics.totalIncome * (analysis.savingsRate / 100),
              ),
              '',
              valueStyle: valueStyle(),
              bodyStyle: bodyStyle(),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              isEn ? 'Goals progress' : 'تقدّم الأهداف',
              style: titleStyle(size: 16),
            ),
            pw.SizedBox(height: 8),
            if (goals.isEmpty)
              pw.Text(
                isEn ? 'No active goals yet.' : 'لا توجد أهداف نشطة بعد.',
                style: bodyStyle(),
              )
            else
              ...goals.map(
                (g) => _kpiRow(
                  g.key,
                  '${g.value.toStringAsFixed(0)}%',
                  '',
                  valueStyle: valueStyle(),
                  bodyStyle: bodyStyle(),
                ),
              ),
            pw.SizedBox(height: 20),
            pw.Text(
              labels['aiRecommendation']!,
              style: titleStyle(size: 14),
            ),
            pw.SizedBox(height: 8),
            pw.Text(smartRecommendation, style: bodyStyle()),
            if (analysis.personalizedRecommendations.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              ...analysis.personalizedRecommendations
                  .take(5)
                  .map((r) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Text('• $r', style: bodyStyle()),
                      )),
            ],
            pw.Spacer(),
            pw.Divider(color: PdfColor.fromHex(_gold)),
            pw.SizedBox(height: 6),
            pw.Text(
              labels['generatedBy']!,
              textAlign: pw.TextAlign.center,
              style: bodyStyle(size: 9),
            ),
          ],
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'mudabbir_analysis_$month.pdf',
    );
  }

  static pw.Widget _kpiRow(
    String label,
    String value,
    String delta, {
    required pw.TextStyle valueStyle,
    required pw.TextStyle bodyStyle,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Text(label, style: bodyStyle),
          ),
          pw.Expanded(
            flex: 4,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.end,
              style: valueStyle,
            ),
          ),
          if (delta.isNotEmpty)
            pw.SizedBox(
              width: 48,
              child: pw.Text(
                delta,
                textAlign: pw.TextAlign.end,
                style: bodyStyle.copyWith(fontSize: 9),
              ),
            ),
        ],
      ),
    );
  }
}
