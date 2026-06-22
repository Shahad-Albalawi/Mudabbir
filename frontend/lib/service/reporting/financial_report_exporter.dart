import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/service/chatbot/chatbot_insights_engine.dart';
import 'package:mudabbir/service/chatbot/chatbot_context_loader.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/reporting/financial_report_builder.dart';
import 'package:mudabbir/service/reporting/financial_report_service.dart';
import 'package:mudabbir/utils/user_display_name.dart';

/// Shared PDF export flow for chatbot, settings, and statistics.
class FinancialReportExporter {
  final ChatbotContextLoader _contextLoader;
  final FinancialReportService _reportService;

  FinancialReportExporter({
    ChatbotContextLoader? contextLoader,
    FinancialReportService? reportService,
  })  : _contextLoader = contextLoader ?? ChatbotContextLoader(),
        _reportService = reportService ?? getIt<FinancialReportService>();

  Future<void> shareMonthlyReport() async {
    final contextData = await _contextLoader.load();
    final insights = ChatbotInsightsEngine.buildFinancialInsights(contextData);
    final categoryBreakdown =
        ChatbotInsightsEngine.buildCategoryExpenseBreakdown(contextData);
    final userName = UserDisplayName.fromSavedUserInfo(
      getIt<HiveService>().getValue(HiveConstants.savedUserInfo),
    );
    final reportData = FinancialReportBuilder.fromContext(
      contextData: contextData,
      insights: insights,
      categoryBreakdown: categoryBreakdown,
      userName: userName,
    );
    await _reportService.shareMonthlyReport(reportData);
  }
}
