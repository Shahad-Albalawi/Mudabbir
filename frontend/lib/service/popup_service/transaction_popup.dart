import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:dartz/dartz.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/data/local/local_database.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/domain/repository/expense_repository/expense_repository.dart';
import 'package:mudabbir/presentation/resources/expense_strings.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/financial_refresh.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/utils/local_db_user_id.dart';

import '../../data/local/database_helper.dart';
import 'popup_widgets.dart';

class TransactionPopup {
  final _expenseRepository = GetIt.I<ExpenseRepository>();

  Future<void> show(BuildContext context, {required String type}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            child: _TransactionDialogBody(type: type, ref: ref),
          );
        },
      ),
    );
  }

  Future<void> _ensureDatabaseReady() async {
    final user = GetIt.I<HiveService>().getValue(HiveConstants.savedUserInfo);
    await LocalDatabase.instance.initForUser(resolveLocalDbUserId(user));
  }

  Future<Either<String, Map<String, dynamic>>> loadTransactionData(
    String type,
  ) async {
    try {
      await _ensureDatabaseReady();

      final accountsResult = await _expenseRepository.getAccounts();
      final categoriesResult = type == 'income'
          ? await _expenseRepository.getIncomeCategories()
          : await _expenseRepository.getExpenseCategories();

      final accounts = accountsResult.getOrElse(() => []);
      final categories = categoriesResult.getOrElse(() => []);

      if (accounts.isEmpty) return Left(AppStrings.txNoAccounts);
      if (categories.isEmpty) return Left(AppStrings.txNoCategories(type));

      final balance = await _expenseRepository.getAccountBalance();

      return Right({
        'categories': categories,
        'accounts': accounts,
        'balance': balance,
      });
    } catch (e) {
      return Left(AppStrings.txLoadFailed(e));
    }
  }
}

class _TransactionDialogBody extends ConsumerStatefulWidget {
  final String type;
  final WidgetRef ref;

  const _TransactionDialogBody({
    required this.type,
    required this.ref,
  });

  @override
  ConsumerState<_TransactionDialogBody> createState() =>
      _TransactionDialogBodyState();
}

class _TransactionDialogBodyState extends ConsumerState<_TransactionDialogBody> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  late final Future<Either<String, Map<String, dynamic>>> _loadFuture;

  int? _accountId;
  int? _categoryId;

  TransactionPopup get _popup => GetIt.I<TransactionPopup>();
  ExpenseRepository get _expenseRepository => GetIt.I<ExpenseRepository>();

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = DateTime.now().toIso8601String().split('T').first;
    _loadFuture = _popup.loadTransactionData(widget.type);
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
    return FutureBuilder<Either<String, Map<String, dynamic>>>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                AppStrings.txLoadFailed(snapshot.error!),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final loadResult = snapshot.data;
        if (loadResult == null || loadResult.isLeft()) {
          final message =
              loadResult?.fold((l) => l, (_) => AppStrings.txLoadError) ??
              AppStrings.txLoadError;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final data = loadResult.getOrElse(() => {});
        final accounts = data['accounts']! as List<dynamic>;
        final categories = data['categories']! as List<dynamic>;
        final currentBalance = (data['balance'] as num?)?.toDouble() ?? 0.0;

        return Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outline
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(context),
                if (widget.type == 'expense')
                  _buildBalanceStrip(context, currentBalance),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionHeader(context, AppStrings.txSectionAmount),
                        const SizedBox(height: 12),
                        PopupWidgets.amountField(_amountCtrl),
                        const SizedBox(height: 24),
                        _sectionHeader(context, AppStrings.txSectionDate),
                        const SizedBox(height: 12),
                        PopupWidgets.dateField(_dateCtrl, context),
                        const SizedBox(height: 24),
                        _sectionHeader(context, AppStrings.txSectionDetails),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: PopupWidgets.dropdownField<int>(
                                value: _accountId,
                                label: AppStrings.labelAccount,
                                items: accounts,
                                onChanged: (val) =>
                                    setState(() => _accountId = val),
                                formatItemLabel:
                                    EntityLocalizations.accountName,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PopupWidgets.dropdownField<int>(
                                value: _categoryId,
                                label: AppStrings.labelCategory,
                                items: categories,
                                onChanged: (val) =>
                                    setState(() => _categoryId = val),
                                formatItemLabel:
                                    EntityLocalizations.categoryName,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _sectionHeader(context, AppStrings.txSectionNotes),
                        const SizedBox(height: 12),
                        PopupWidgets.notesField(_notesCtrl),
                      ],
                    ),
                  ),
                ),
                _buildActions(context, accounts, categories),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final type = widget.type;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outline
                .withValues(alpha: 0.18),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            type == 'income'
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              type == 'income'
                  ? AppStrings.addIncome
                  : AppStrings.addExpense,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStrip(BuildContext context, double currentBalance) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outline
                .withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.txAvailableBalance,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              ExpenseStrings.formatAmount(currentBalance),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    List<dynamic> accounts,
    List<dynamic> categories,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.txCancel),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _save(context, accounts, categories),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Text(
                widget.type == 'income'
                    ? AppStrings.txSaveIncome
                    : AppStrings.txSaveExpense,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    List<dynamic> accounts,
    List<dynamic> categories,
  ) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = double.parse(_amountCtrl.text);
    if (_accountId == null || _categoryId == null) {
      PopupWidgets.showErrorSnackBar(
        context,
        '${AppStrings.labelAccount} / ${AppStrings.labelCategory}',
      );
      return;
    }

    String? feedback;
    final type = widget.type;

    if (type == 'expense') {
      final tx = ExpenseTransaction(
        id: 0,
        amount: amount,
        date: _dateCtrl.text,
        type: type,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        accountId: _accountId!,
        categoryId: _categoryId!,
        accountName: EntityLocalizations.accountName(
          accounts.firstWhere(
            (a) => a['id'] == _accountId,
            orElse: () => {'name': ''},
          ),
        ),
        categoryName: EntityLocalizations.categoryName(
          categories.firstWhere(
            (c) => c['id'] == _categoryId,
            orElse: () => {'name': ''},
          ),
        ),
      );
      final result = await _expenseRepository.addTransaction(tx);
      final ok = result.fold((failure) {
        PopupWidgets.showErrorSnackBar(context, failure.userFacingMessage);
        return false;
      }, (write) {
        feedback = write.budgetMessage;
        return true;
      });
      if (!ok) return;
    } else {
      await GetIt.I<DbHelper>().insert('transactions', {
        'amount': amount,
        'date': _dateCtrl.text,
        'type': type,
        'notes': _notesCtrl.text.trim(),
        'account_id': _accountId,
        'category_id': _categoryId,
        'is_recurring': 0,
      });
    }

    await FinancialRefresh.refreshAll(ref);

    if (!context.mounted) return;
    Navigator.pop(context);
    final successText = feedback == null
        ? AppStrings.txSuccess(type)
        : '${AppStrings.txSuccess(type)}\n$feedback';
    PopupWidgets.showSuccessSnackBar(context, successText);
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
