import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/report_service.dart';

/// Shared PDF export flow for settings and statistics.
class FinancialReportExporter {
  final ReportService _reportService;

  FinancialReportExporter({ReportService? reportService})
      : _reportService = reportService ?? getIt<ReportService>();

  Future<void> shareMonthlyReport() async {
    await _reportService.generateAndShareMonthlyReport();
  }
}
