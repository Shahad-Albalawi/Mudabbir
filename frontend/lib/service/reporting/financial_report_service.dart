import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'financial_report_data.dart';
import 'financial_report_strings.dart';

/// Generates branded monthly PDF reports aligned with Mudabbir light theme.
class FinancialReportService {
  static const _primary = '#2D6A4F';
  static const _primarySoft = '#E8EDEA';
  static const _background = '#F7F7F5';
  static const _card = '#FFFFFF';
  static const _border = '#D8DED9';
  static const _text = '#1A1A1A';
  static const _muted = '#6B6B6B';
  static const _accent = '#8B7355';
  static const _danger = '#C45C4A';
  static const _success = '#3D7A5C';

  Future<void> shareMonthlyReport(FinancialReportData data) async {
    await initializeDateFormatting('ar');
    await initializeDateFormatting('en');

    final regular = await _loadFont('assets/fonts/thmanyah/thmanyahsans-Regular.otf');
    final bold = await _loadFont('assets/fonts/thmanyah/thmanyahsans-Bold.otf');
    final medium = await _loadFont('assets/fonts/thmanyah/thmanyahsans-Medium.otf');

    final isRtl = !AppStrings.isEnglishLocale;
    final pdf = pw.Document(
      title: FinancialReportStrings.reportTitle,
      author: FinancialReportStrings.appName,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 28, 36, 40),
        theme: pw.ThemeData.withFont(
          base: regular,
          bold: bold,
          italic: regular,
          boldItalic: bold,
        ),
        textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        header: (context) => _pageHeader(data, medium, bold, isRtl),
        footer: (context) => _pageFooter(context, medium),
        build: (context) => [
          _heroMeta(data, medium),
          pw.SizedBox(height: 18),
          _sectionTitle(FinancialReportStrings.executiveSummary, bold),
          pw.SizedBox(height: 10),
          _summaryGrid(data, bold, medium),
          pw.SizedBox(height: 18),
          _sectionTitle(FinancialReportStrings.categoryBreakdown, bold),
          pw.SizedBox(height: 10),
          _categorySection(data, medium),
          pw.SizedBox(height: 18),
          _sectionTitle(FinancialReportStrings.goalsSection, bold),
          pw.SizedBox(height: 10),
          _goalsSection(data, medium, bold),
          pw.SizedBox(height: 18),
          _sectionTitle(FinancialReportStrings.budgetSection, bold),
          pw.SizedBox(height: 10),
          _budgetSection(data, medium, bold),
          pw.SizedBox(height: 18),
          _sectionTitle(FinancialReportStrings.subscriptionsSection, bold),
          pw.SizedBox(height: 10),
          _subscriptionsSection(data, medium),
          pw.SizedBox(height: 18),
          _sectionTitle(FinancialReportStrings.transactionsSection, bold),
          pw.SizedBox(height: 10),
          _transactionsTable(data, medium, bold),
          pw.SizedBox(height: 18),
          _sectionTitle(FinancialReportStrings.alertsSection, bold),
          pw.SizedBox(height: 10),
          _alertsSection(data, medium),
          pw.SizedBox(height: 14),
          _sectionTitle(FinancialReportStrings.recommendationsSection, bold),
          pw.SizedBox(height: 8),
          _recommendationsCard(data, medium),
        ],
      ),
    );

    final periodKey =
        '${data.period.year}-${data.period.month.toString().padLeft(2, '0')}';
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/mudabbir-report-$periodKey.pdf');
    await file.writeAsBytes(await pdf.save());

    final periodLabel = FinancialReportStrings.formatPeriod(data.period);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: FinancialReportStrings.shareBody(periodLabel),
      subject: '${FinancialReportStrings.shareSubject} ($periodLabel)',
    );
  }

  Future<pw.Font> _loadFont(String asset) async {
    final data = await rootBundle.load(asset);
    return pw.Font.ttf(data);
  }

  pw.Widget _pageHeader(
    FinancialReportData data,
    pw.Font medium,
    pw.Font bold,
    bool isRtl,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex(_primary),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Column(
            crossAxisAlignment: isRtl
                ? pw.CrossAxisAlignment.end
                : pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                FinancialReportStrings.appName,
                style: pw.TextStyle(
                  font: bold,
                  fontSize: 20,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                FinancialReportStrings.reportTitle,
                style: pw.TextStyle(
                  font: medium,
                  fontSize: 11,
                  color: PdfColor.fromHex('#D4E8DC'),
                ),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#3D7A5C'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              FinancialReportStrings.formatPeriod(data.period),
              style: pw.TextStyle(
                font: medium,
                fontSize: 10,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pageFooter(pw.Context context, pw.Font medium) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            FinancialReportStrings.footer,
            style: pw.TextStyle(
              font: medium,
              fontSize: 8,
              color: PdfColor.fromHex(_muted),
            ),
          ),
          pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: pw.TextStyle(
              font: medium,
              fontSize: 8,
              color: PdfColor.fromHex(_muted),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _heroMeta(FinancialReportData data, pw.Font medium) {
    final lines = <String>[
      '${FinancialReportStrings.generatedOn}: ${FinancialReportStrings.formatDate(data.generatedAt)}',
    ];
    if (data.userName.isNotEmpty) {
      lines.insert(0, '${FinancialReportStrings.preparedFor} ${data.userName}');
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex(_background),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromHex(_border)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: lines
            .map(
              (line) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Text(
                  line,
                  style: pw.TextStyle(
                    font: medium,
                    fontSize: 10,
                    color: PdfColor.fromHex(_muted),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  pw.Widget _sectionTitle(String title, pw.Font bold) {
    return pw.Row(
      children: [
        pw.Container(
          width: 4,
          height: 16,
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex(_primary),
            borderRadius: pw.BorderRadius.circular(2),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          title,
          style: pw.TextStyle(
            font: bold,
            fontSize: 13,
            color: PdfColor.fromHex(_text),
          ),
        ),
      ],
    );
  }

  pw.Widget _summaryGrid(
    FinancialReportData data,
    pw.Font bold,
    pw.Font medium,
  ) {
    return pw.Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _metricCard(FinancialReportStrings.income, FinancialReportStrings.formatAmount(data.income), _success, bold, medium),
        _metricCard(FinancialReportStrings.expense, FinancialReportStrings.formatAmount(data.expense), _accent, bold, medium),
        _metricCard(
          FinancialReportStrings.balance,
          FinancialReportStrings.formatAmount(data.balance),
          data.balance >= 0 ? _primary : _danger,
          bold,
          medium,
        ),
        _metricCard(
          FinancialReportStrings.healthScore,
          '${data.healthScore}/100',
          _primary,
          bold,
          medium,
          subtitle: FinancialReportStrings.healthStatus(data.healthScore),
        ),
        _metricCard(
          FinancialReportStrings.savingsRate,
          FinancialReportStrings.formatPercent(data.savingsRate * 100),
          _primary,
          bold,
          medium,
        ),
        _metricCard(
          FinancialReportStrings.accountBalance,
          FinancialReportStrings.formatAmount(data.totalAccountBalance),
          _primary,
          bold,
          medium,
        ),
      ],
    );
  }

  pw.Widget _metricCard(
    String label,
    String value,
    String accentHex,
    pw.Font bold,
    pw.Font medium, {
    String? subtitle,
  }) {
    return pw.Container(
      width: 158,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex(_card),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromHex(_border)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: medium,
              fontSize: 9,
              color: PdfColor.fromHex(_muted),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: bold,
              fontSize: 14,
              color: PdfColor.fromHex(accentHex),
            ),
          ),
          if (subtitle != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              subtitle,
              style: pw.TextStyle(
                font: medium,
                fontSize: 8,
                color: PdfColor.fromHex(_muted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _categorySection(
    FinancialReportData data,
    pw.Font medium,
  ) {
    if (data.categoryBreakdown.isEmpty) {
      return _emptyCard(FinancialReportStrings.noCategoryData, medium);
    }

    final total = data.categoryBreakdown.values.fold<double>(0, (a, b) => a + b);
    final sorted = data.categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex(_card),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromHex(_border)),
      ),
      child: pw.Column(
        children: sorted.take(8).map((entry) {
          final ratio = total <= 0 ? 0.0 : (entry.value / total).clamp(0.0, 1.0);
          final percent = (ratio * 100).toStringAsFixed(0);
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        entry.key,
                        style: pw.TextStyle(
                          font: medium,
                          fontSize: 10,
                          color: PdfColor.fromHex(_text),
                        ),
                      ),
                    ),
                    pw.Text(
                      '${FinancialReportStrings.formatAmount(entry.value)} · $percent%',
                      style: pw.TextStyle(
                        font: medium,
                        fontSize: 9,
                        color: PdfColor.fromHex(_muted),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Container(
                  height: 7,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex(_primarySoft),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Container(
                      height: 7,
                      width: 480 * ratio,
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex(_primary),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _goalsSection(
    FinancialReportData data,
    pw.Font medium,
    pw.Font bold,
  ) {
    if (data.goals.isEmpty) return _emptyCard(FinancialReportStrings.noGoals, medium);

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex(_border), width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.2),
        1: const pw.FlexColumnWidth(1.2),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1.2),
      },
      children: [
        _tableHeaderRow(
          [
            FinancialReportStrings.goalName,
            FinancialReportStrings.goalTarget,
            FinancialReportStrings.goalCurrent,
            FinancialReportStrings.goalProgress,
            FinancialReportStrings.goalDeadline,
          ],
          bold,
        ),
        ...data.goals.take(8).map((g) {
          return pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.white),
            children: [
              _tableCell(g.name, medium),
              _tableCell(FinancialReportStrings.formatAmount(g.target), medium),
              _tableCell(FinancialReportStrings.formatAmount(g.current), medium),
              _tableCell(FinancialReportStrings.formatPercent(g.progressPercent), medium, accent: _primary),
              _tableCell(
                g.endDate == null ? '—' : FinancialReportStrings.formatShortDate(g.endDate!),
                medium,
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _budgetSection(
    FinancialReportData data,
    pw.Font medium,
    pw.Font bold,
  ) {
    final budget = data.monthlyBudget;
    if (budget == null || budget <= 0) {
      return _emptyCard(FinancialReportStrings.noBudget, medium);
    }

    final spent = data.expense;
    final remaining = (budget - spent).clamp(0, double.infinity);
    final used = data.budgetUsedPercent.clamp(0, 100);

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex(_card),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromHex(_border)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _budgetStat(FinancialReportStrings.budgetLimit, FinancialReportStrings.formatAmount(budget), medium, bold),
              _budgetStat(FinancialReportStrings.budgetSpent, FinancialReportStrings.formatAmount(spent), medium, bold),
              _budgetStat(
                FinancialReportStrings.budgetRemaining,
                FinancialReportStrings.formatAmount(remaining.toDouble()),
                medium,
                bold,
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            '${FinancialReportStrings.formatPercent(used.toDouble())} ${FinancialReportStrings.budgetSpent.toLowerCase()}',
            style: pw.TextStyle(
              font: medium,
              fontSize: 9,
              color: PdfColor.fromHex(_muted),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Container(
            height: 8,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex(_primarySoft),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Container(
                height: 8,
                width: 480 * (used / 100),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex(
                    used > 100 ? _danger : _primary,
                  ),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _budgetStat(
    String label,
    String value,
    pw.Font medium,
    pw.Font bold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: medium,
            fontSize: 9,
            color: PdfColor.fromHex(_muted),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: bold,
            fontSize: 12,
            color: PdfColor.fromHex(_text),
          ),
        ),
      ],
    );
  }

  pw.Widget _subscriptionsSection(
    FinancialReportData data,
    pw.Font medium,
  ) {
    if (data.subscriptions.isEmpty) {
      return _emptyCard(FinancialReportStrings.noSubscriptions, medium);
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex(_card),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromHex(_border)),
      ),
      child: pw.Column(
        children: data.subscriptions.map((sub) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    sub.label,
                    style: pw.TextStyle(
                      font: medium,
                      fontSize: 10,
                      color: PdfColor.fromHex(_text),
                    ),
                  ),
                ),
                pw.Text(
                  '~${FinancialReportStrings.formatAmount(sub.avgAmount)} · ${sub.count}x',
                  style: pw.TextStyle(
                    font: medium,
                    fontSize: 9,
                    color: PdfColor.fromHex(_muted),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _transactionsTable(
    FinancialReportData data,
    pw.Font medium,
    pw.Font bold,
  ) {
    if (data.transactions.isEmpty) {
      return _emptyCard(FinancialReportStrings.noTransactions, medium);
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex(_border), width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.9),
        1: const pw.FlexColumnWidth(1.4),
        2: const pw.FlexColumnWidth(0.8),
        3: const pw.FlexColumnWidth(1.1),
        4: const pw.FlexColumnWidth(1.8),
      },
      children: [
        _tableHeaderRow(
          [
            FinancialReportStrings.colDate,
            FinancialReportStrings.colCategory,
            FinancialReportStrings.colType,
            FinancialReportStrings.colAmount,
            FinancialReportStrings.colNotes,
          ],
          bold,
        ),
        ...data.transactions.map((t) {
          final typeLabel =
              t.type == 'income' ? FinancialReportStrings.typeIncome : FinancialReportStrings.typeExpense;
          final amountColor = t.type == 'income' ? _success : _text;
          return pw.TableRow(
            children: [
              _tableCell(FinancialReportStrings.formatShortDate(t.date), medium),
              _tableCell(t.category, medium),
              _tableCell(typeLabel, medium),
              _tableCell(
                FinancialReportStrings.formatAmount(t.amount),
                medium,
                accent: amountColor,
              ),
              _tableCell(t.notes ?? '—', medium, maxLines: 2),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _alertsSection(
    FinancialReportData data,
    pw.Font medium,
  ) {
    if (data.alerts.isEmpty) {
      return _emptyCard(FinancialReportStrings.noAlerts, medium);
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFF8F6'),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromHex('#F0D4CE')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: data.alerts
            .map(
              (alert) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '• ',
                      style: pw.TextStyle(
                        font: medium,
                        fontSize: 10,
                        color: PdfColor.fromHex(_danger),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        alert,
                        style: pw.TextStyle(
                          font: medium,
                          fontSize: 10,
                          color: PdfColor.fromHex(_text),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  pw.Widget _recommendationsCard(
    FinancialReportData data,
    pw.Font medium,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex(_primarySoft),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromHex(_border)),
      ),
      child: pw.Text(
        FinancialReportStrings.recommendations(data.healthScore),
        style: pw.TextStyle(
          font: medium,
          fontSize: 10,
          color: PdfColor.fromHex(_text),
        ),
      ),
    );
  }

  pw.Widget _emptyCard(String message, pw.Font medium) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex(_card),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromHex(_border)),
      ),
      child: pw.Text(
        message,
        style: pw.TextStyle(
          font: medium,
          fontSize: 10,
          color: PdfColor.fromHex(_muted),
        ),
      ),
    );
  }

  pw.TableRow _tableHeaderRow(List<String> labels, pw.Font bold) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColor.fromHex(_primarySoft)),
      children: labels
          .map(
            (label) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  font: bold,
                  fontSize: 9,
                  color: PdfColor.fromHex(_primary),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _tableCell(
    String text,
    pw.Font medium, {
    String? accent,
    int maxLines = 1,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: pw.Text(
        text,
        maxLines: maxLines,
        style: pw.TextStyle(
          font: medium,
          fontSize: 9,
          color: PdfColor.fromHex(accent ?? _text),
        ),
      ),
    );
  }
}
