import 'package:mudabbir/core/providers/app_providers.dart';
import 'package:mudabbir/core/providers/provider_reader.dart';
import 'package:mudabbir/service/report_service.dart';

/// Shared PDF export flow for settings and statistics.
class FinancialReportExporter {
  final ReportService _reportService;

  FinancialReportExporter({ReportService? reportService})
      : _reportService = reportService ?? readApp(reportServiceProvider);

  Future<void> shareMonthlyReport() async {
    await _reportService.generateAndShareMonthlyReport();
  }
}
