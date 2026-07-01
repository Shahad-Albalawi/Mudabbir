import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/core/theme/app_theme.dart';
import 'package:mudabbir/presentation/home/widgets/home_action_sheets.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

/// أربع إجراءات سريعة: مصروف، دخل، تقرير PDF، تحليل.
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            label: AppStrings.homeQaExpense,
            icon: Icons.remove_rounded,
            color: colors.red,
            onTap: () => HomeActionSheets.showExpense(context),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            label: AppStrings.homeQaIncome,
            icon: Icons.add_rounded,
            color: colors.green,
            onTap: () => HomeActionSheets.showIncome(context),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            label: AppStrings.homeQaPdfReport,
            icon: Icons.picture_as_pdf_outlined,
            color: colors.primary,
            onTap: () => HomeActionSheets.showReport(context),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            label: AppStrings.homeQaAnalysis,
            icon: Icons.insights_outlined,
            color: colors.primary,
            onTap: () {
              HapticService.light();
              context.push(AppRoutes.financialHealth);
            },
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: () {
          HapticService.light();
          onTap();
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: colors.border, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.5, color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
