import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/persentation/budget/budget_viewmodel.dart';
import 'package:mudabbir/persentation/resources/strings_manager.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/popup_service/popup_service.dart';

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
      if (newState.isDelete != null) {
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: scheme.onPrimary,
              size: 26,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                () {
                  final raw = getIt<HiveService>().getValue(HiveConstants.savedUserInfo);
                  final name = raw is Map && raw['name'] != null
                      ? raw['name'].toString()
                      : '';
                  return name.isEmpty ? AppStrings.title : '${AppStrings.title} - $name';
                }(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: scheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Builder(
        builder: (context) {
          // Loading
          if (budgetState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty state (no budgets)
          if (budgetState.budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: scheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.noBudgetsYet,
                    style: TextStyle(
                      fontSize: 18,
                      color: scheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      getIt<PopupService>().showAddBudgetPopup(context, ref);
                    },
                    child: Text(AppStrings.addNewBudget),
                  ),
                ],
              ),
            );
          }

          // Budgets exist → show "Add" button + list
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  style: Theme.of(context).elevatedButtonTheme.style,
                  onPressed: () {
                    getIt<PopupService>().showAddBudgetPopup(context, ref);
                  },
                  icon: const Icon(Icons.add),
                  label: Text(
                    AppStrings.addBudgetButton,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: budgetState.budgets.length,
                  itemBuilder: (_, i) {
                    final budget = budgetState.budgets[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: scheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        trailing: IconButton(
                          onPressed: () async {
                            await budgetViewmodel.deleteBudget(budget['id']);
                          },
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: scheme.error,
                          ),
                        ),

                        leading: Icon(
                          Icons.monetization_on,
                          color: scheme.onSurfaceVariant,
                        ),
                        title: Text(
                          "${budget['amount']}", // if budget is a Map
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
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
