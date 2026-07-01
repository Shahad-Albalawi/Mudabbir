import 'package:flutter/material.dart';
import 'package:mudabbir/core/theme/app_theme.dart';
import 'package:mudabbir/presentation/transactions/add_transaction_sheet.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/reporting/financial_report_exporter.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Bottom sheets for home quick actions (no full-screen navigation).
abstract final class HomeActionSheets {
  HomeActionSheets._();

  static Future<void> showExpense(BuildContext context) {
    HapticService.light();
    return AddTransactionSheet.show(context, initialType: 'expense');
  }

  static Future<void> showIncome(BuildContext context) {
    HapticService.light();
    return AddTransactionSheet.show(context, initialType: 'income');
  }

  static Future<void> showReport(BuildContext context) {
    HapticService.light();
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.homeMonthlyReportTitle,
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: Spacing.xxl),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await FinancialReportExporter().shareMonthlyReport();
                },
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(AppStrings.exportPdfReport),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
