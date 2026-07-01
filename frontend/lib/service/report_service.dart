import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/domain/services/financial_aggregator.dart';
import 'package:mudabbir/domain/services/financial_date_utils.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/saudi_riyal_font.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/utils/user_display_name.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class MonthlyReportTrendPoint {
  const MonthlyReportTrendPoint({required this.label, required this.amount});

  final String label;
  final double amount;
}

class MonthlyReportTransaction {
  const MonthlyReportTransaction({
    required this.date,
    required this.description,
    required this.category,
    required this.amount,
  });

  final String date;
  final String description;
  final String category;
  final double amount;
}

class MonthlyReportGoal {
  const MonthlyReportGoal({
    required this.name,
    required this.target,
    required this.current,
    required this.progressPercent,
  });

  final String name;
  final double target;
  final double current;
  final double progressPercent;

  double get remaining => (target - current).clamp(0, double.infinity);
}

class MonthlyReportData {
  const MonthlyReportData({
    required this.userName,
    required this.period,
    required this.generatedAt,
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRatePercent,
    required this.spendingTrend,
    required this.expenseByCategory,
    required this.transactions,
    required this.activeGoals,
  });

  final String userName;
  final DateTime period;
  final DateTime generatedAt;
  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final double savingsRatePercent;
  final List<MonthlyReportTrendPoint> spendingTrend;
  final Map<String, double> expenseByCategory;
  final List<MonthlyReportTransaction> transactions;
  final List<MonthlyReportGoal> activeGoals;

  double get categoryExpenseTotal =>
      expenseByCategory.values.fold(0.0, (a, b) => a + b);
}

// ---------------------------------------------------------------------------
// Report service
// ---------------------------------------------------------------------------

/// Premium monthly PDF report for مدبّر — A4 RTL Arabic layout with charts.
class ReportService {
  ReportService({
    DbHelper? db,
    FinancialAggregator? aggregator,
  })  : _db = db ?? getIt<DbHelper>(),
        _aggregator = aggregator ?? FinancialAggregator();

  static const _navy = '#112E81';
  static const _navySoft = '#E8EDF8';
  static const _pageBg = '#F8FAFF';
  static const _rowAlt = '#F8FAFF';
  static const _muted = '#64748B';

  final DbHelper _db;
  final FinancialAggregator _aggregator;

  pw.Font? _regular;
  pw.Font? _medium;
  pw.Font? _bold;
  pw.Font? _riyal;
  pw.MemoryImage? _logo;
  pw.MemoryImage? _logoLight;

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Loads current-month financial data from SQLite.
  Future<MonthlyReportData> loadMonthlyData({
    DateTime? period,
    String? userName,
  }) async {
    final month = period ?? DateTime.now();
    final anchor = DateTime(month.year, month.month, 1);
    final range = FinancialDateUtils.monthRange(anchor);

    final totals = await _aggregator.incomeAndExpenseTotals(
      startDate: range.start,
      endDate: range.end,
    );
    final net = totals.income - totals.expense;
    final savingsRate =
        totals.income <= 0 ? 0.0 : ((net / totals.income) * 100).clamp(-999, 999);

    final daily = await _loadDailyExpenseTotals(range.start, range.end);
    final trend = _monthlySpendingTrend(range.start, range.end, daily);
    final categories = await _loadCategoryTotals(range.start, range.end);
    final transactions = await _loadTransactions(range.start, range.end);
    final goals = await _loadActiveGoals();

    final resolvedName = userName ??
        UserDisplayName.fromSavedUserInfo(
          getIt<HiveService>().getValue(HiveConstants.savedUserInfo),
        );

    return MonthlyReportData(
      userName: resolvedName.trim(),
      period: anchor,
      generatedAt: DateTime.now(),
      totalIncome: totals.income,
      totalExpense: totals.expense,
      netSavings: net,
      savingsRatePercent: savingsRate.toDouble(),
      spendingTrend: trend,
      expenseByCategory: categories,
      transactions: transactions,
      activeGoals: goals,
    );
  }

  /// Builds a multi-page A4 PDF: cover → executive summary → expenses → goals.
  Future<pw.Document> buildMonthlyReport(MonthlyReportData data) async {
    await _ensureAssets();

    final linePng = await _captureSpendingLineChart(
      data.spendingTrend,
      compact: true,
    );

    final goalBars = <Uint8List>[];
    for (final goal in data.activeGoals.take(8)) {
      goalBars.add(await _captureGoalProgressBar(goal.progressPercent));
    }

    final pdf = pw.Document(
      title: 'التقرير المالي الشهري',
      author: 'مُدَبِّر',
    );

    pdf.addPage(_coverPage(data));
    pdf.addPage(
      _contentPage(
        pageNumber: 2,
        generatedAt: data.generatedAt,
        child: _executiveSummaryPage(data, linePng),
      ),
    );
    pdf.addPage(
      _contentPage(
        pageNumber: 3,
        generatedAt: data.generatedAt,
        child: _expensesPage(data),
      ),
    );
    pdf.addPage(
      _contentPage(
        pageNumber: 4,
        generatedAt: data.generatedAt,
        child: _goalsPage(data.activeGoals, goalBars),
      ),
    );

    return pdf;
  }

  /// Generates the monthly report and opens the native share sheet.
  Future<void> generateAndShareMonthlyReport({
    DateTime? period,
    String? userName,
  }) async {
    await initializeDateFormatting('ar');
    final data = await loadMonthlyData(period: period, userName: userName);
    final doc = await buildMonthlyReport(data);
    final periodKey =
        '${data.period.year}-${data.period.month.toString().padLeft(2, '0')}';
    await shareReport(doc, fileName: 'mudabbir-monthly-$periodKey.pdf');
  }

  /// Opens iOS/Android share sheet (Files, WhatsApp, Email, …).
  Future<void> shareReport(
    pw.Document doc, {
    String fileName = 'mudabbir-report.pdf',
  }) async {
    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: fileName,
      subject: 'التقرير الشهري — مدبّر',
    );
  }

  // -------------------------------------------------------------------------
  // PDF layout — 4 pages
  // -------------------------------------------------------------------------

  /// Page 1 — full-bleed navy cover.
  pw.Page _coverPage(MonthlyReportData data) {
    final monthName = DateFormat('MMMM', 'ar').format(data.period);
    final year = data.period.year.toString();
    final userLine = data.userName.isNotEmpty ? data.userName : 'مستخدم مدبّر';

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      theme: pw.ThemeData.withFont(
        base: _regular!,
        bold: _bold!,
        italic: _regular!,
        boldItalic: _bold!,
      ),
      textDirection: pw.TextDirection.rtl,
      build: (context) {
        return pw.Container(
          color: PdfColor.fromHex(_navy),
          child: pw.Stack(
            children: [
              pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    if (_logoLight != null)
                      pw.Container(
                        width: 88,
                        height: 88,
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(20),
                        ),
                        child: pw.Image(_logoLight!, fit: pw.BoxFit.contain),
                      )
                    else if (_logo != null)
                      pw.Image(_logo!, width: 72, height: 72),
                    pw.SizedBox(height: 28),
                    pw.Text(
                      'التقرير المالي الشهري',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: _bold,
                        fontSize: 26,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      userLine,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: _medium,
                        fontSize: 16,
                        color: PdfColor.fromHex('#CBD5E1'),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '$monthName $year',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: _regular,
                        fontSize: 14,
                        color: PdfColor.fromHex('#94A3B8'),
                      ),
                    ),
                  ],
                ),
              ),
              pw.Positioned(
                left: 36,
                right: 36,
                bottom: 28,
                child: _pageFooter(
                  pageNumber: 1,
                  generatedAt: data.generatedAt,
                  onDark: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  pw.Page _contentPage({
    required int pageNumber,
    required DateTime generatedAt,
    required pw.Widget child,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 28, 36, 48),
      theme: pw.ThemeData.withFont(
        base: _regular!,
        bold: _bold!,
        italic: _regular!,
        boldItalic: _bold!,
      ),
      textDirection: pw.TextDirection.rtl,
      build: (context) {
        return pw.Container(
          color: PdfColor.fromHex(_pageBg),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Expanded(child: child),
              pw.SizedBox(height: 12),
              _pageFooter(
                pageNumber: pageNumber,
                generatedAt: generatedAt,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Page 2 — executive summary: 2×2 KPIs + compact trend chart.
  pw.Widget _executiveSummaryPage(
    MonthlyReportData data,
    Uint8List linePng,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _sectionHeading('ملخص تنفيذي'),
        pw.SizedBox(height: 16),
        _kpiGrid(data),
        pw.SizedBox(height: 10),
        _kpiGridRow2(data),
        pw.SizedBox(height: 20),
        _sectionHeading('اتجاه الإنفاق'),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(12),
            border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
          ),
          child: pw.Column(
            children: [
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(linePng),
                  width: 420,
                  fit: pw.BoxFit.contain,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'مصاريف الأسبوع خلال الشهر',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  font: _regular,
                  fontSize: 9,
                  color: PdfColor.fromHex(_muted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Page 3 — expense transactions table.
  pw.Widget _expensesPage(MonthlyReportData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _sectionHeading('تفاصيل المصروفات'),
        pw.SizedBox(height: 10),
        _transactionsTable(data),
      ],
    );
  }

  /// Page 4 — savings goals with progress bars.
  pw.Widget _goalsPage(
    List<MonthlyReportGoal> goals,
    List<Uint8List> progressBars,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _sectionHeading('الأهداف'),
        pw.SizedBox(height: 12),
        _goalsSection(goals, progressBars),
      ],
    );
  }

  pw.Widget _kpiGrid(MonthlyReportData data) {
    return pw.Row(
      children: [
        pw.Expanded(child: _kpiCard('إجمالي الدخل', _formatAmount(data.totalIncome))),
        pw.SizedBox(width: 10),
        pw.Expanded(child: _kpiCard('إجمالي المصاريف', _formatAmount(data.totalExpense))),
      ],
    );
  }

  pw.Widget _kpiGridRow2(MonthlyReportData data) {
    return pw.Row(
      children: [
        pw.Expanded(child: _kpiCard('صافي التوفير', _formatAmount(data.netSavings))),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _kpiCard(
            'نسبة التوفير',
            '${data.savingsRatePercent.toStringAsFixed(0)}%',
          ),
        ),
      ],
    );
  }

  pw.Widget _kpiCard(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: _regular,
              fontSize: 9,
              color: PdfColor.fromHex(_muted),
            ),
            textAlign: pw.TextAlign.right,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: _bold,
              fontSize: 16,
              color: PdfColor.fromHex(_navy),
              fontFallback: _riyal != null ? [_riyal!] : const [],
            ),
            textAlign: pw.TextAlign.right,
          ),
        ],
      ),
    );
  }

  pw.Widget _sectionHeading(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 4,
              height: 18,
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex(_navy),
                borderRadius: pw.BorderRadius.circular(2),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              title,
              style: pw.TextStyle(
                font: _bold,
                fontSize: 14,
                color: PdfColor.fromHex(_navy),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Container(height: 1, color: PdfColor.fromHex('#E2E8F0')),
      ],
    );
  }

  pw.Widget _transactionsTable(MonthlyReportData data) {
    if (data.transactions.isEmpty) {
      return _emptyBox('لا توجد معاملات مسجّلة لهذا الشهر.');
    }

    final total = data.transactions.fold<double>(0, (s, t) => s + t.amount);
    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColor.fromHex(_navy)),
        children: [
          _th('التاريخ'),
          _th('الفئة'),
          _th('الوصف'),
          _th('المبلغ'),
        ],
      ),
      ...data.transactions.asMap().entries.map((entry) {
        final i = entry.key;
        final t = entry.value;
        final bg = i.isEven ? PdfColors.white : PdfColor.fromHex(_rowAlt);
        return pw.TableRow(
          decoration: pw.BoxDecoration(color: bg),
          children: [
            _td(_formatShortDate(t.date)),
            _td(t.category),
            _td(t.description),
            _td(_formatAmount(t.amount), bold: true),
          ],
        );
      }),
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColor.fromHex(_navySoft)),
        children: [
          _td('الإجمالي', bold: true),
          _td(''),
          _td(''),
          _td(_formatAmount(total), bold: true),
        ],
      ),
    ];

    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColor.fromHex('#E2E8F0'),
        width: 0.5,
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.0),
        1: const pw.FlexColumnWidth(1.3),
        2: const pw.FlexColumnWidth(2.3),
        3: const pw.FlexColumnWidth(1.2),
      },
      children: rows,
    );
  }

  pw.Widget _goalsSection(
    List<MonthlyReportGoal> goals,
    List<Uint8List> progressBars,
  ) {
    if (goals.isEmpty) {
      return _emptyBox('لا توجد أهداف نشطة حاليًا.');
    }

    return pw.Column(
      children: [
        for (var i = 0; i < goals.length && i < progressBars.length; i++)
          _goalCard(goals[i], progressBars[i]),
      ],
    );
  }

  pw.Widget _goalCard(MonthlyReportGoal goal, Uint8List barPng) {
    final pctLabel = '${goal.progressPercent.toStringAsFixed(0)}%';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  goal.name,
                  style: pw.TextStyle(
                    font: _bold,
                    fontSize: 12,
                    color: PdfColor.fromHex(_navy),
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                pctLabel,
                style: pw.TextStyle(
                  font: _bold,
                  fontSize: 13,
                  color: PdfColor.fromHex(_navy),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Image(pw.MemoryImage(barPng), width: double.infinity, height: 10),
          pw.SizedBox(height: 6),
          pw.Text(
            '${_formatAmount(goal.current)} من ${_formatAmount(goal.target)}',
            style: pw.TextStyle(
              font: _regular,
              fontSize: 9,
              color: PdfColor.fromHex(_muted),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pageFooter({
    required int pageNumber,
    required DateTime generatedAt,
    bool onDark = false,
  }) {
    final dateStr = DateFormat('d/M/yyyy', 'ar').format(generatedAt);
    final color = onDark
        ? PdfColor.fromHex('#CBD5E1')
        : PdfColor.fromHex(_muted);

    pw.Widget sep() => pw.Text(
          ' | ',
          style: pw.TextStyle(font: _regular, fontSize: 8, color: color),
        );

    pw.Widget item(String text, {bool bold = false}) => pw.Text(
          text,
          style: pw.TextStyle(
            font: bold ? _medium : _regular,
            fontSize: 8,
            color: color,
          ),
        );

    return pw.Column(
      children: [
        if (!onDark)
          pw.Container(height: 1, color: PdfColor.fromHex('#E2E8F0')),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            item('مُدَبِّر', bold: true),
            sep(),
            item(dateStr),
            sep(),
            item('$pageNumber'),
          ],
        ),
      ],
    );
  }

  pw.Widget _th(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.right,
        style: pw.TextStyle(
          font: _bold,
          fontSize: 9,
          color: PdfColors.white,
        ),
      ),
    );
  }

  pw.Widget _td(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.right,
        maxLines: 2,
        style: _amountStyle(bold: bold),
      ),
    );
  }

  pw.Widget _emptyBox(String message) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex(_pageBg),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
      ),
      child: pw.Text(
        message,
        style: pw.TextStyle(
          font: _regular,
          fontSize: 10,
          color: PdfColor.fromHex(_muted),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Chart capture (fl_chart → PNG via RepaintBoundary)
  // -------------------------------------------------------------------------

  Future<Uint8List> _captureSpendingLineChart(
    List<MonthlyReportTrendPoint> points, {
    bool compact = false,
  }) async {
    return _widgetToPng(
      _ReportLineChart(points: points, compact: compact),
      size: compact ? const Size(420, 160) : const Size(520, 220),
    );
  }

  Future<Uint8List> _captureGoalProgressBar(double percent) async {
    return _widgetToPng(
      _ReportProgressBar(percent: percent.clamp(0, 100)),
      size: const Size(440, 10),
    );
  }

  Future<Uint8List> _widgetToPng(
    Widget widget, {
    required Size size,
    double pixelRatio = 2.5,
  }) async {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    await binding.endOfFrame;

    final view = binding.platformDispatcher.views.first;
    final repaintBoundary = RenderRepaintBoundary();

    final renderView = RenderView(
      view: view,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        physicalConstraints: BoxConstraints.tight(size * pixelRatio),
        logicalConstraints: BoxConstraints.tight(size),
        devicePixelRatio: pixelRatio,
      ),
    );

    final pipelineOwner = PipelineOwner();
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final buildOwner = BuildOwner(focusManager: FocusManager());
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: MediaQuery(
          data: MediaQueryData(size: size),
          child: Material(
            color: Colors.white,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: widget,
            ),
          ),
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();
    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // -------------------------------------------------------------------------
  // SQLite loaders
  // -------------------------------------------------------------------------

  Future<Map<String, double>> _loadDailyExpenseTotals(
    String start,
    String end,
  ) async {
    final result = await _db.complexQuery(
      table: 'transactions',
      columns: ['date(date) as day', 'SUM(amount) as total'],
      where: "type = 'expense' AND date(date) BETWEEN date(?) AND date(?)",
      whereArgs: [start, end],
      groupBy: 'day',
      orderBy: 'day ASC',
    );

    return result.fold(
      (_) => <String, double>{},
      (rows) => {
        for (final r in rows)
          r['day'] as String: (r['total'] as num).toDouble(),
      },
    );
  }

  List<MonthlyReportTrendPoint> _monthlySpendingTrend(
    String startIso,
    String endIso,
    Map<String, double> daily,
  ) {
    final start = DateTime.parse(startIso);
    final end = DateTime.parse(endIso);
    const weekLabels = ['1', '2', '3', '4', '5'];

    return List.generate(5, (i) {
      final bucketStart = start.add(Duration(days: i * 6));
      var total = 0.0;
      for (var d = 0; d < 6; d++) {
        final date = bucketStart.add(Duration(days: d));
        if (date.isAfter(end)) break;
        total += daily[FinancialDateUtils.isoDate(date)] ?? 0;
      }
      return MonthlyReportTrendPoint(label: weekLabels[i], amount: total);
    });
  }

  Future<Map<String, double>> _loadCategoryTotals(String start, String end) async {
    final result = await _db.complexQuery(
      table: 'transactions t',
      columns: [
        "COALESCE(c.name, 'أخرى') as category",
        'SUM(t.amount) as total',
      ],
      joinClause: 'LEFT JOIN categories c ON t.category_id = c.id',
      where: "t.type = 'expense' AND date(t.date) BETWEEN date(?) AND date(?)",
      whereArgs: [start, end],
      groupBy: 'category',
      orderBy: 'total DESC',
    );

    return result.fold(
      (_) => <String, double>{},
      (rows) => {
        for (final r in rows)
          r['category'] as String: (r['total'] as num).toDouble(),
      },
    );
  }

  Future<List<MonthlyReportTransaction>> _loadTransactions(
    String start,
    String end,
  ) async {
    final result = await _db.complexQuery(
      table: 'transactions t',
      columns: [
        't.date as date',
        "COALESCE(c.name, 'أخرى') as category",
        't.amount as amount',
        't.notes as notes',
      ],
      joinClause: 'LEFT JOIN categories c ON t.category_id = c.id',
      where: "t.type = 'expense' AND date(t.date) BETWEEN date(?) AND date(?)",
      whereArgs: [start, end],
      orderBy: 't.date DESC',
      limit: 40,
    );

    return result.fold((_) => <MonthlyReportTransaction>[], (rows) {
      return rows
          .map(
            (r) => MonthlyReportTransaction(
              date: r['date'] as String,
              description: _transactionDescription(r),
              category: r['category'] as String,
              amount: (r['amount'] as num).toDouble(),
            ),
          )
          .toList();
    });
  }

  String _transactionDescription(Map<String, dynamic> row) {
    final notes = (row['notes'] as String?)?.trim() ?? '';
    if (notes.isNotEmpty) return notes;
    return row['category'] as String? ?? 'معاملة';
  }

  Future<List<MonthlyReportGoal>> _loadActiveGoals() async {
    final result = await _db.complexQuery(
      table: 'goals',
      columns: ['name', 'target', 'current_amount', 'is_completed'],
      where: 'is_completed = 0',
      orderBy: 'end_date ASC',
      limit: 8,
    );

    return result.fold((_) => <MonthlyReportGoal>[], (rows) {
      return rows.map((r) {
        final target = (r['target'] as num?)?.toDouble() ?? 0;
        final current = (r['current_amount'] as num?)?.toDouble() ?? 0;
        final pct = target <= 0 ? 0.0 : ((current / target) * 100).clamp(0, 100);
        return MonthlyReportGoal(
          name: (r['name'] as String?) ?? 'هدف',
          target: target,
          current: current,
          progressPercent: pct.toDouble(),
        );
      }).toList();
    });
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Future<void> _ensureAssets() async {
    if (_regular != null) return;
    _regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Eight/Eight-Regular.ttf'),
    );
    _medium = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Eight/Eight-Medium.ttf'),
    );
    _bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Eight/Eight-Bold.ttf'),
    );
    try {
      _riyal = pw.Font.ttf(
        await rootBundle.load('assets/fonts/saudi_riyal/SaudiRiyal-Regular.ttf'),
      );
    } catch (_) {
      _riyal = null;
    }
    final logoBytes =
        await rootBundle.load('assets/icons/logo_dark.png');
    _logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    try {
      final lightBytes =
          await rootBundle.load('assets/icons/logo_light.png');
      _logoLight = pw.MemoryImage(lightBytes.buffer.asUint8List());
    } catch (_) {
      _logoLight = _logo;
    }
  }

  String _formatAmount(double value) {
    final number = AppCurrency.formatNumber(value);
    if (_riyal != null && SaudiRiyalFont.isAvailable) {
      return '$number ${SaudiRiyalFont.symbol}';
    }
    return '$number ريال';
  }

  pw.TextStyle _amountStyle({bool bold = false}) => pw.TextStyle(
        font: bold ? _bold : _regular,
        fontSize: 9,
        color: PdfColor.fromHex(_navy),
        fontFallback: _riyal != null ? [_riyal!] : const [],
      );

  String _formatShortDate(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat('d/M', 'ar').format(parsed);
  }
}

// ---------------------------------------------------------------------------
// Off-screen fl_chart widgets for PNG export
// ---------------------------------------------------------------------------

class _ReportLineChart extends StatelessWidget {
  const _ReportLineChart({
    required this.points,
    this.compact = false,
  });

  final List<MonthlyReportTrendPoint> points;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (points.every((p) => p.amount == 0)) {
      return const Center(
        child: Text(
          'لا توجد بيانات',
          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
      );
    }

    final maxY = points.map((p) => p.amount).fold(0.0, math.max);
    final chartMaxY = maxY <= 0 ? 10.0 : maxY * 1.15;

    return LineChart(
      duration: Duration.zero,
      LineChartData(
        minY: 0,
        maxY: chartMaxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: compact ? 20 : 24,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= points.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  points[i].label,
                  style: TextStyle(
                    fontSize: compact ? 9 : 10,
                    color: const Color(0xFF94A3B8),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].amount),
            ],
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.primaryGreen,
            barWidth: compact ? 1.8 : 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryGreen.withValues(alpha: 0.12),
                  AppColors.primaryGreen.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportProgressBar extends StatelessWidget {
  const _ReportProgressBar({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final ratio = (percent / 100).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Row(
        children: [
          Expanded(
            flex: (ratio * 1000).round().clamp(0, 1000),
            child: Container(color: const Color(0xFF112E81)),
          ),
          Expanded(
            flex: ((1 - ratio) * 1000).round().clamp(0, 1000),
            child: Container(color: const Color(0xFFE8EDF8)),
          ),
        ],
      ),
    );
  }
}
