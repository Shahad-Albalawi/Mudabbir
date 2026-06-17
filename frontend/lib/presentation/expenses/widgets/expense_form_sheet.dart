import 'package:flutter/material.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/presentation/expenses/expenses_viewmodel.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/expense_strings.dart';
import 'package:mudabbir/service/financial_refresh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom sheet for creating or editing an expense.
class ExpenseFormSheet extends ConsumerStatefulWidget {
  final ExpensesViewModel model;
  final ExpenseTransaction? existing;

  const ExpenseFormSheet({
    super.key,
    required this.model,
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

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _amountCtrl = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(0) : '',
    );
    _dateCtrl = TextEditingController(
      text: existing?.date ?? DateTime.now().toIso8601String().split('T').first,
    );
    _notesCtrl = TextEditingController(text: existing?.notes ?? '');
    _accountId = existing?.accountId ??
        (widget.model.accounts.isNotEmpty
            ? widget.model.accounts.first['id'] as int?
            : null);
    _categoryId = existing?.categoryId ??
        (widget.model.categories.isNotEmpty
            ? widget.model.categories.first['id'] as int?
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
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return ExpenseStrings.invalidAmount;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dateCtrl,
                  readOnly: true,
                  decoration: InputDecoration(labelText: ExpenseStrings.date),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(_dateCtrl.text) ??
                          DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
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
                  items: widget.model.accounts
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
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  decoration:
                      InputDecoration(labelText: ExpenseStrings.category),
                  items: widget.model.categories
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
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  decoration: InputDecoration(labelText: ExpenseStrings.notes),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(ExpenseStrings.recurringMonthly),
                  value: _isRecurring,
                  onChanged: (v) => setState(() => _isRecurring = v),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(ExpenseStrings.save),
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
    if (_accountId == null || _categoryId == null) return;

    setState(() => _saving = true);
    final amount = double.parse(_amountCtrl.text);
    final notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

    final message = widget.existing == null
        ? await widget.model.addExpense(
            amount: amount,
            date: _dateCtrl.text,
            accountId: _accountId!,
            categoryId: _categoryId!,
            notes: notes,
            isRecurring: _isRecurring,
          )
        : await widget.model.updateExpense(
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
