import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/ios_style_constants.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/resources/values_manager.dart';
import 'package:mudabbir/presentation/server_challenges/screens/challenges_list_screen.dart';
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
    final homeViewModel = ref.read(homeProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p20,
        vertical: AppPadding.p24,
      ),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(IOSStyleConstants.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: ColorManager.shadowLight,
            blurRadius: IOSStyleConstants.shadowBlur,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            label: AppStrings.addExpense,
            icon: CupertinoIcons.minus_circle,
            color: ColorManager.error,
            onTap: () {
              HapticService.medium();
              getIt<PopupService>().showAddExpensePopup(context);
              homeViewModel.loadFinancialSummary();
              ref.read(homeProvider.notifier).reload();
            },
          ),
          _ActionButton(
            label: AppStrings.addIncome,
            icon: CupertinoIcons.add_circled,
            color: ColorManager.success,
            onTap: () {
              HapticService.medium();
              getIt<PopupService>().showAddIncomePopup(context);
              homeViewModel.loadFinancialSummary();
              ref.read(homeProvider.notifier).reload();
            },
          ),
          _ActionButton(
            label: AppStrings.addChallenge,
            icon: CupertinoIcons.flag_fill,
            color: ColorManager.primary,
            onTap: () {
              HapticService.medium();
              getIt<NavigationService>().navigate(ChallengesListScreen());
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IOSPressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p12,
          vertical: AppPadding.p8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppPadding.p14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(
                  IOSStyleConstants.radiusMedium,
                ),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppSize.s8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ColorManager.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
