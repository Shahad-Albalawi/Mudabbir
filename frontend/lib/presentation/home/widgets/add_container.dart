import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/ios_pressable.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/popup_service/popup_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Quick actions — premium iOS icon row on grouped card.
class AddContainer extends ConsumerWidget {
  const AddContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: AppStrings.addExpense,
                icon: AppIcons.expense,
                onTap: () {
                  HapticService.medium();
                  getIt<PopupService>().showAddExpensePopup(context);
                },
              ),
            ),
            VerticalDivider(
              width: 1,
              color: scheme.outline.withValues(alpha: 0.12),
            ),
            Expanded(
              child: _ActionButton(
                label: AppStrings.addIncome,
                icon: AppIcons.income,
                onTap: () {
                  HapticService.medium();
                  getIt<PopupService>().showAddIncomePopup(context);
                },
              ),
            ),
            VerticalDivider(
              width: 1,
              color: scheme.outline.withValues(alpha: 0.12),
            ),
            Expanded(
              child: _ActionButton(
                label: AppStrings.addChallenge,
                icon: AppIcons.challenge,
                onTap: () {
                  HapticService.medium();
                  context.push(AppRoutes.challenges);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return IOSPressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppTouch.minTarget,
              height: AppTouch.minTarget,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.groupedFill,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: scheme.primary, size: 22),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
