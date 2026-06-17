import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/server_challenges/screens/challenges_list_screen.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/ios_pressable.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/popup_service/popup_service.dart';

/// Quick action buttons for adding expense, income, or challenge.
class AddContainer extends ConsumerWidget {
  const AddContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: AppStrings.addExpense,
                icon: CupertinoIcons.minus,
                onTap: () {
                  HapticService.medium();
                  getIt<PopupService>().showAddExpensePopup(context);
                },
              ),
            ),
            VerticalDivider(
              width: 1,
              color: scheme.outline.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _ActionButton(
                label: AppStrings.addIncome,
                icon: CupertinoIcons.plus,
                onTap: () {
                  HapticService.medium();
                  getIt<PopupService>().showAddIncomePopup(context);
                },
              ),
            ),
            VerticalDivider(
              width: 1,
              color: scheme.outline.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _ActionButton(
                label: AppStrings.addChallenge,
                icon: CupertinoIcons.flag,
                onTap: () {
                  HapticService.medium();
                  getIt<NavigationService>().navigate(ChallengesListScreen());
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.homeGreenSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: scheme.homeGreen, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.textOnCard,
                fontWeight: FontWeight.w600,
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
