import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/presentation/budget/budget_viewmodel.dart';
import 'package:mudabbir/presentation/budget/widgets/budget_card.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_animated_list_item.dart';
import 'package:mudabbir/presentation/widgets/app_confirm_dialog.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';
import 'package:mudabbir/presentation/widgets/app_offline_banner.dart';
import 'package:mudabbir/presentation/widgets/app_skeleton.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/presentation/widgets/app_snackbar.dart';
import 'package:mudabbir/service/financial_refresh.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/popup_service/popup_service.dart';
import 'package:mudabbir/utils/user_display_name.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetView extends ConsumerWidget {
  const BudgetView({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    BudgetViewmodel viewModel,
    int id,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.budgetDeleteConfirmTitle,
      message: AppStrings.budgetDeleteConfirmBody,
    );
    if (confirmed == true) {
      HapticService.medium();
      await viewModel.deleteBudget(id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetViewmodelProvider);
    final budgetViewmodel = ref.read(budgetViewmodelProvider.notifier);
    ref.listen<BudgetState>(budgetViewmodelProvider, (
      previousState,
      newState,
    ) async {
      if (newState.isDelete) {
        await budgetViewmodel.getAllBudgets();
        await FinancialRefresh.refreshAll(ref);
        AppSnackbar.success(AppStrings.budgetDeleted);
      }
      if (newState.isAdd == true) {
        await budgetViewmodel.getAllBudgets();
        await FinancialRefresh.refreshAll(ref);
        AppSnackbar.success(AppStrings.budgetCreateSuccess);
      }
      if (newState.error != null &&
          (previousState?.error != newState.error) &&
          !newState.isLoading) {
        AppSnackbar.error(newState.error!);
      }
    });

    final userName = UserDisplayName.fromSavedUserInfo(
      getIt<HiveService>().getValue(HiveConstants.savedUserInfo),
    );
    final title = userName.isEmpty
        ? AppStrings.title
        : '${AppStrings.title} - $userName';

    return AppGroupedScaffold(
      largeTitle: true,
      title: Text(title),
      body: Builder(
        builder: (context) {
          if (budgetState.isLoading) {
            return const AppListSkeleton();
          }

          if (budgetState.error != null && budgetState.items.isEmpty) {
            return Center(
              child: IOSEmptyState(
                icon: AppIcons.warning,
                title: AppStrings.snackErrorTitle,
                subtitle: budgetState.error!,
                buttonLabel: AppStrings.retry,
                onPressed: budgetViewmodel.getAllBudgets,
              ),
            );
          }

          if (budgetState.items.isEmpty) {
            return Center(
              child: IOSEmptyState(
                icon: AppIcons.wallet,
                title: AppStrings.noBudgetsYet,
                subtitle: AppStrings.addNewBudget,
                buttonLabel: AppStrings.addNewBudget,
                onPressed: () {
                  HapticService.medium();
                  getIt<PopupService>().showAddBudgetPopup(context, ref);
                },
              ),
            );
          }

          return Column(
            children: [
              if (budgetState.isOffline)
                AppOfflineBanner(
                  message: AppStrings.budgetOfflineBanner,
                  onRetry: budgetViewmodel.getAllBudgets,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.pageGutter,
                  8,
                  AppLayout.pageGutter,
                  12,
                ),
                child: AppLoadingButton(
                  isLoading: false,
                  label: AppStrings.addBudgetButton,
                  onPressed: () {
                    HapticService.medium();
                    getIt<PopupService>().showAddBudgetPopup(context, ref);
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.pageGutter,
                    0,
                    AppLayout.pageGutter,
                    AppLayout.bottomNavClearance,
                  ),
                  itemCount: budgetState.items.length,
                  itemBuilder: (_, i) {
                    final item = budgetState.items[i];
                    return AppAnimatedListItem(
                      index: i,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppLayout.sectionGap,
                        ),
                        child: BudgetCard(
                          budget: item.budget,
                          spent: item.spent,
                          onDelete: () => _confirmDelete(
                            context,
                            budgetViewmodel,
                            item.budget.id,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
