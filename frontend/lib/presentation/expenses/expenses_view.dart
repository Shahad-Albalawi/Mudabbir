import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/presentation/expenses/expenses_viewmodel.dart';
import 'package:mudabbir/presentation/expenses/widgets/expense_form_sheet.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/expense_strings.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/presentation/widgets/ios_loading_widget.dart';
import 'package:stacked/stacked.dart';

/// Full expense list with filters and CRUD actions.
class ExpensesView extends StatelessWidget {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ViewModelBuilder<ExpensesViewModel>.reactive(
      viewModelBuilder: () => ExpensesViewModel(),
      onViewModelReady: (model) => model.initialize(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: scheme.surfaceContainerHighest,
          appBar: AppBar(
            title: Text(ExpenseStrings.title),
            actions: [
              IconButton(
                tooltip: ExpenseStrings.addExpense,
                onPressed: () => _openForm(context, model),
                icon: const Icon(CupertinoIcons.add),
              ),
            ],
          ),
          body: model.isBusy
              ? const Center(child: IOSLoadingWidget(size: 48))
              : Column(
                  children: [
                    _FiltersBar(model: model),
                    if (model.isOffline)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppLayout.pageGutter,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.cloud,
                              size: 18,
                              color: scheme.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ExpenseStrings.offlineBanner,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            TextButton(
                              onPressed: model.loadExpenses,
                              child: Text(ServerChallengeStrings.retry),
                            ),
                          ],
                        ),
                      ),
                    if (model.errorMessage != null)
                      _MessageBanner(
                        text: model.errorMessage!,
                        color: scheme.error,
                      ),
                    if (model.successMessage != null)
                      _MessageBanner(
                        text: model.successMessage!,
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
                            ExpenseStrings.totalFiltered,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            ExpenseStrings.formatAmount(model.filteredTotal),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: model.expenses.isEmpty
                          ? IOSEmptyState(
                              icon: CupertinoIcons.doc_text,
                              title: ExpenseStrings.emptyTitle,
                              subtitle: ExpenseStrings.emptySubtitle,
                              buttonLabel: ExpenseStrings.addExpense,
                              onPressed: () => _openForm(context, model),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                AppLayout.pageGutter,
                                8,
                                AppLayout.pageGutter,
                                24,
                              ),
                              itemCount: model.expenses.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final item = model.expenses[index];
                                return _ExpenseTile(
                                  item: item,
                                  onEdit: () => _openForm(
                                    context,
                                    model,
                                    existing: item,
                                  ),
                                  onDelete: () => _confirmDelete(
                                    context,
                                    model,
                                    item,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _openForm(
    BuildContext context,
    ExpensesViewModel model, {
    ExpenseTransaction? existing,
  }) async {
    model.clearMessages();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => ExpenseFormSheet(
        model: model,
        existing: existing,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ExpensesViewModel model,
    ExpenseTransaction item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ExpenseStrings.deleteConfirmTitle),
        content: Text(ExpenseStrings.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ExpenseStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ExpenseStrings.deleteExpense),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await model.deleteExpense(item.id);
    }
  }
}

class _FiltersBar extends StatelessWidget {
  final ExpensesViewModel model;
  const _FiltersBar({required this.model});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppLayout.pageGutter,
        12,
        AppLayout.pageGutter,
        4,
      ),
      child: Row(
        children: [
          _MonthPicker(model: model),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(ExpenseStrings.filterRecurring),
            selected: model.recurringOnly,
            onSelected: model.toggleRecurringOnly,
          ),
          const SizedBox(width: 8),
          DropdownButton<int?>(
            value: model.selectedCategoryId,
            hint: Text(ExpenseStrings.filterCategory),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(ExpenseStrings.filterAll),
              ),
              ...model.categories.map(
                (c) => DropdownMenuItem<int?>(
                  value: c['id'] as int,
                  child: Text(
                    EntityLocalizations.categoryName(c['name'] as String?),
                  ),
                ),
              ),
            ],
            onChanged: model.setCategoryFilter,
          ),
        ],
      ),
    );
  }
}

class _MonthPicker extends StatelessWidget {
  final ExpensesViewModel model;
  const _MonthPicker({required this.model});

  @override
  Widget build(BuildContext context) {
    final parts = model.selectedMonth.split('-');
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
          model.setMonth(key);
        }
      },
      icon: const Icon(CupertinoIcons.calendar, size: 18),
      label: Text('${ExpenseStrings.filterMonth}: $label'),
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
          Icon(CupertinoIcons.arrow_down, size: 20, color: scheme.error),
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
                      ExpenseStrings.recurringBadge,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            ExpenseStrings.formatAmount(item.amount),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.error,
            ),
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
