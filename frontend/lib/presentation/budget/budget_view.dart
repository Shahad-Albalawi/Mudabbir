import 'package:flutter/material.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/presentation/budget/budget_viewmodel.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/modern_gradient_appbar.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/presentation/widgets/ios_loading_widget.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/popup_service/popup_service.dart';
import 'package:mudabbir/utils/user_display_name.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetView extends ConsumerWidget {
  const BudgetView({super.key});

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
        getIt<NavigationService>().showSuccessSnackbar(
          title: AppStrings.snackSuccessTitle,
          body: AppStrings.budgetDeleted,
        );
      }
      if (newState.isAdd == true) {
        await budgetViewmodel.getAllBudgets();
      }
    });

    final scheme = Theme.of(context).colorScheme;
    final userName = UserDisplayName.fromSavedUserInfo(
      getIt<HiveService>().getValue(HiveConstants.savedUserInfo),
    );
    final title = userName.isEmpty
        ? AppStrings.title
        : '${AppStrings.title} - $userName';

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: ModernGradientAppBar(
        showBackButton: false,
        title: Text(title),
      ),
      body: Builder(
        builder: (context) {
          if (budgetState.isLoading) {
            return const Center(child: IOSLoadingWidget());
          }

          if (budgetState.budgets.isEmpty) {
            return Center(
              child: IOSEmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: AppStrings.noBudgetsYet,
                subtitle: AppStrings.addNewBudget,
                buttonLabel: AppStrings.addNewBudget,
                onPressed: () {
                  getIt<PopupService>().showAddBudgetPopup(context, ref);
                },
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppLayout.pageGutter),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      getIt<PopupService>().showAddBudgetPopup(context, ref);
                    },
                    icon: const Icon(Icons.add),
                    label: Text(AppStrings.addBudgetButton),
                  ),
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
                  itemCount: budgetState.budgets.length,
                  itemBuilder: (_, i) {
                    final budget = budgetState.budgets[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppLayout.sectionGap),
                      child: AppCard(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          leading: Icon(
                            Icons.monetization_on_outlined,
                            color: scheme.primary,
                          ),
                          title: Text(
                            '${budget['amount']} ﷼',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          trailing: IconButton(
                            onPressed: () async {
                              await budgetViewmodel.deleteBudget(budget['id']);
                            },
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: scheme.error,
                            ),
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
