import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/presentation/auth/financial_form_validators.dart';
import 'package:mudabbir/presentation/expenses/expenses_viewmodel.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/expense_strings.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';
import 'package:mudabbir/service/financial_refresh.dart';

/// Bottom sheet for creating or editing an expense.
class ExpenseFormSheet extends ConsumerStatefulWidget {
  final ExpenseTransaction? existing;

  const ExpenseFormSheet({
    super.key,
    this.existing,
  });

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _notesCtrl;
  int? _accountId;
  int? _categoryId;
  bool _isRecurring = false;
  bool _saving = false;

  ExpensesState get _expensesState => ref.read(expensesProvider);

  ExpensesNotifier get _notifier => ref.read(expensesProvider.notifier);

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final meta = ref.read(expensesProvider);
    _amountCtrl = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(0) : '',
    );
    _dateCtrl = TextEditingController(
      text: existing?.date ?? DateTime.now().toIso8601String().split('T').first,
    );
    _notesCtrl = TextEditingController(text: existing?.notes ?? '');
    _accountId = existing?.accountId ??
        (meta.accounts.isNotEmpty ? meta.accounts.first['id'] as int? : null);
    _categoryId = existing?.categoryId ??
        (meta.categories.isNotEmpty
            ? meta.categories.first['id'] as int?
            : null);
    _isRecurring = existing?.isRecurring ?? false;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = _expensesState.accounts;
    final categories = _expensesState.categories;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.existing == null
                      ? ExpenseStrings.addExpense
                      : ExpenseStrings.editExpense,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: ExpenseStrings.amount),
                  validator: FinancialFormValidators.amount,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dateCtrl,
                  readOnly: true,
                  decoration: InputDecoration(labelText: ExpenseStrings.date),
                  validator: FinancialFormValidators.dateNotFuture,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(_dateCtrl.text) ??
                          DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      _dateCtrl.text =
                          picked.toIso8601String().split('T').first;
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _accountId,
                  decoration:
                      InputDecoration(labelText: ExpenseStrings.account),
                  items: accounts
                      .map(
                        (a) => DropdownMenuItem<int>(
                          value: a['id'] as int,
                          child: Text(
                            EntityLocalizations.accountName(a['name'] as String?),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _accountId = v),
                  validator: (_) => FinancialFormValidators.accountSelected(_accountId),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  decoration:
                      InputDecoration(labelText: ExpenseStrings.category),
                  items: categories
                      .map(
                        (c) => DropdownMenuItem<int>(
                          value: c['id'] as int,
                          child: Text(
                            EntityLocalizations.categoryName(c['name'] as String?),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  validator: (_) => FinancialFormValidators.categorySelected(_categoryId),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  decoration: InputDecoration(labelText: ExpenseStrings.notes),
                  maxLines: 2,
                  maxLength: FinancialFormValidators.maxNotesLength,
                  validator: FinancialFormValidators.notes,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(ExpenseStrings.recurringMonthly),
                  value: _isRecurring,
                  onChanged: (v) => setState(() => _isRecurring = v),
                ),
                const SizedBox(height: 16),
                AppLoadingButton(
                  isLoading: _saving,
                  label: ExpenseStrings.save,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final amount = double.parse(_amountCtrl.text);
    final notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

    final message = widget.existing == null
        ? await _notifier.addExpense(
            amount: amount,
            date: _dateCtrl.text,
            accountId: _accountId!,
            categoryId: _categoryId!,
            notes: notes,
            isRecurring: _isRecurring,
          )
        : await _notifier.updateExpense(
            widget.existing!,
            amount: amount,
            date: _dateCtrl.text,
            accountId: _accountId!,
            categoryId: _categoryId!,
            notes: notes,
            isRecurring: _isRecurring,
          );

    setState(() => _saving = false);

    if (!mounted) return;
    if (message != null) {
      await FinancialRefresh.refreshAll(ref);
      if (mounted) Navigator.pop(context);
    }
  }
}
