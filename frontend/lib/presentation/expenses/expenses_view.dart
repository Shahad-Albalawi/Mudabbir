import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/presentation/expenses/expenses_viewmodel.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/statistics/statistics_viewmodel.dart';
import 'package:mudabbir/presentation/expenses/widgets/expense_form_sheet.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_animated_list_item.dart';
import 'package:mudabbir/presentation/widgets/app_confirm_dialog.dart';
import 'package:mudabbir/presentation/widgets/app_offline_banner.dart';
import 'package:mudabbir/presentation/widgets/riyal_amount.dart';
import 'package:mudabbir/presentation/widgets/app_skeleton.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
/// Full expense list with filters and CRUD actions.
class ExpensesView extends ConsumerWidget {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expensesProvider);
    final notifier = ref.read(expensesProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    ref.listen<ExpensesState>(expensesProvider, (previous, next) {
      if (next.successMessage != null &&
          previous?.successMessage != next.successMessage) {
        ref.read(statisticsProvider.notifier).loadStatistics(force: true);
        ref.read(homeProvider.notifier).reload();
      }
    });

    return AppGroupedScaffold(
      largeTitle: true,
      title: Text(AppStrings.expensesTitle),
      actions: [
        IconButton(
          tooltip: AppStrings.expensesAddButton,
          onPressed: () => _openForm(context, ref),
          icon: const Icon(CupertinoIcons.add),
        ),
      ],
      body: state.isLoading && state.expenses.isEmpty
          ? const AppListSkeleton()
          : Column(
              children: [
                _FiltersBar(state: state, notifier: notifier),
                if (state.isOffline)
                  AppOfflineBanner(
                    message: AppStrings.expenseOfflineBanner,
                    onRetry: notifier.loadExpenses,
                  ),
                if (state.errorMessage != null)
                  _MessageBanner(
                    text: state.errorMessage!,
                    color: scheme.error,
                  ),
                if (state.successMessage != null)
                  _MessageBanner(
                    text: state.successMessage!,
                    color: scheme.success,
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppLayout.pageGutter,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.expensesTotalFiltered,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      RiyalAmount(
                        state.filteredTotal,
                        fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                        fontWeight: FontWeight.w600,
                        symbolBold: true,
                        color: scheme.dataGreen,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.errorMessage != null && state.expenses.isEmpty
                      ? IOSEmptyState(
                          icon: Icons.cloud_off_rounded,
                          title: AppStrings.snackErrorTitle,
                          subtitle: state.errorMessage!,
                          buttonLabel: AppStrings.retry,
                          onPressed: notifier.loadExpenses,
                        )
                      : state.expenses.isEmpty
                          ? IOSEmptyState(
                              icon: CupertinoIcons.doc_text,
                              title: AppStrings.expensesEmptyTitle,
                              subtitle: AppStrings.expensesEmptySubtitle,
                              buttonLabel: AppStrings.expensesAddButton,
                              onPressed: () => _openForm(context, ref),
                            )
                          : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppLayout.pageGutter,
                            8,
                            AppLayout.pageGutter,
                            AppLayout.bottomNavClearance,
                          ),
                          itemCount: state.expenses.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = state.expenses[index];
                            return AppAnimatedListItem(
                              index: index,
                              child: _ExpenseTile(
                                item: item,
                                onEdit: () => _openForm(
                                  context,
                                  ref,
                                  existing: item,
                                ),
                                onDelete: () => _confirmDelete(
                                  context,
                                  ref,
                                  item,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    ExpenseTransaction? existing,
  }) async {
    ref.read(expensesProvider.notifier).clearMessages();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ExpenseFormSheet(existing: existing),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ExpenseTransaction item,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.expenseDeleteConfirmTitle,
      message: AppStrings.expenseDeleteConfirmBody,
      confirmLabel: AppStrings.delete,
      cancelLabel: AppStrings.txCancel,
    );
    if (confirmed == true) {
      await ref.read(expensesProvider.notifier).deleteExpense(item.id);
    }
  }
}

class _FiltersBar extends StatelessWidget {
  final ExpensesState state;
  final ExpensesNotifier notifier;

  const _FiltersBar({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.expensesFilterRecurring,
      child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppLayout.pageGutter,
        12,
        AppLayout.pageGutter,
        4,
      ),
      child: Row(
        children: [
          _MonthPicker(state: state, notifier: notifier),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(AppStrings.expensesFilterRecurring),
            selected: state.recurringOnly,
            onSelected: notifier.toggleRecurringOnly,
          ),
          const SizedBox(width: 8),
          DropdownButton<int?>(
            value: state.selectedCategoryId,
            hint: Text(AppStrings.expensesFilterCategory),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(AppStrings.expensesFilterAll),
              ),
              ...state.categories.map(
                (c) => DropdownMenuItem<int?>(
                  value: c['id'] as int,
                  child: Text(
                    EntityLocalizations.categoryName(c['name'] as String?),
                  ),
                ),
              ),
            ],
            onChanged: notifier.setCategoryFilter,
          ),
        ],
      ),
      ),
    );
  }
}

class _MonthPicker extends StatelessWidget {
  final ExpensesState state;
  final ExpensesNotifier notifier;

  const _MonthPicker({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final parts = state.selectedMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final label = '${parts[1]}/${parts[0]}';

    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(year, month),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          final key =
              '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
          notifier.setMonth(key);
        }
      },
      icon: const Icon(CupertinoIcons.calendar, size: 18),
      label: Text('${AppStrings.expensesFilterMonth}: $label'),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseTransaction item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onEdit,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.expenseAmount.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              CupertinoIcons.arrow_down,
              size: 18,
              color: scheme.expenseAmount,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.categoryName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.date} • ${item.accountName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.textMuted,
                  ),
                ),
                if (item.notes != null && item.notes!.isNotEmpty)
                  Text(
                    item.notes!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.textMuted,
                    ),
                  ),
                if (item.isRecurring)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      AppStrings.expensesRecurringBadge,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          RiyalAmount(
            item.amount,
            fontSize: Theme.of(context).textTheme.titleSmall?.fontSize,
            fontWeight: FontWeight.w600,
            color: scheme.error,
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              CupertinoIcons.delete,
              size: 20,
              color: scheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  final String text;
  final Color color;
  const _MessageBanner({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppLayout.pageGutter,
        vertical: 6,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppLayout.chipRadius),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(text),
    );
  }
}
