import 'package:flutter/material.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/presentation/expenses/expenses_viewmodel.dart';
import 'package:mudabbir/presentation/expenses/widgets/expense_form_sheet.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/expense_strings.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/presentation/widgets/ios_loading_widget.dart';
import 'package:stacked/stacked.dart';

/// Full expense list with filters and CRUD actions.
class ExpensesView extends StatelessWidget {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ExpensesViewModel>.reactive(
      viewModelBuilder: () => ExpensesViewModel(),
      onViewModelReady: (model) => model.initialize(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          appBar: AppBar(
            title: Text(ExpenseStrings.title),
            actions: [
              IconButton(
                tooltip: ExpenseStrings.addExpense,
                onPressed: () => _openForm(context, model),
                icon: const Icon(Icons.add_rounded),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_off_outlined, size: 18),
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
                        color: ColorManager.error,
                      ),
                    if (model.successMessage != null)
                      _MessageBanner(
                        text: model.successMessage!,
                        color: ColorManager.success,
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
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
                                  color: ColorManager.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: model.expenses.isEmpty
                          ? IOSEmptyState(
                              icon: Icons.receipt_long_rounded,
                              title: ExpenseStrings.emptyTitle,
                              subtitle: ExpenseStrings.emptySubtitle,
                              buttonLabel: ExpenseStrings.addExpense,
                              onPressed: () => _openForm(context, model),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: model.expenses.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
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
          floatingActionButton: FloatingActionButton(
            backgroundColor: ColorManager.primary,
            onPressed: () => _openForm(context, model),
            child: const Icon(Icons.add, color: Colors.white),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
          ElevatedButton(
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
      icon: const Icon(Icons.calendar_month_rounded, size: 18),
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
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: ColorManager.error.withValues(alpha: 0.12),
                child: const Icon(Icons.trending_down, color: ColorManager.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.categoryName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.date} • ${item.accountName}',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    if (item.notes != null && item.notes!.isNotEmpty)
                      Text(
                        item.notes!,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    if (item.isRecurring)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Chip(
                          label: Text(ExpenseStrings.recurringBadge),
                          visualDensity: VisualDensity.compact,
                          backgroundColor:
                              ColorManager.primaryWithOpacity08,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                ExpenseStrings.formatAmount(item.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ColorManager.error,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text),
    );
  }
}
