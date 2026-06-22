import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:dartz/dartz.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/data/local/local_database.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/expense_sync_result.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/domain/repository/expense_repository/expense_repository.dart';
import 'package:mudabbir/domain/repository/synced_expense_repository/synced_expense_repository.dart';
import 'package:mudabbir/presentation/resources/expense_strings.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';
import 'package:mudabbir/presentation/widgets/ios_dialog_style.dart';
import 'package:mudabbir/presentation/widgets/ios_loading_widget.dart';
import 'package:mudabbir/service/financial_refresh.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/notifications/financial_alert_service.dart';
import 'package:mudabbir/utils/local_db_user_id.dart';

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
            shape: IOSDialogStyle.dialogShape(),
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
  bool _saving = false;

  TransactionPopup get _popup => GetIt.I<TransactionPopup>();
  SyncedExpenseRepository get _synced => GetIt.I<SyncedExpenseRepository>();

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
            padding: EdgeInsets.all(40),
            child: Center(child: IOSLoadingWidget()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                AppStrings.txLoadFailed(snapshot.error!),
                textAlign: TextAlign.center,
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
              child: Text(message, textAlign: TextAlign.center),
            ),
          );
        }

        final data = loadResult.getOrElse(() => {});
        final accounts = data['accounts']! as List<dynamic>;
        final categories = data['categories']! as List<dynamic>;
        final currentBalance = (data['balance'] as num?)?.toDouble() ?? 0.0;
        final isIncome = widget.type == 'income';

        return Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
          decoration: IOSDialogStyle.surfaceDecoration(context),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IOSDialogStyle.header(
                  context,
                  title: isIncome
                      ? AppStrings.addIncome
                      : AppStrings.addExpense,
                  subtitle: isIncome
                      ? null
                      : '${AppStrings.txAvailableBalanceShort} ${ExpenseStrings.formatAmount(currentBalance)}',
                  icon: isIncome
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        IOSDialogStyle.sectionLabel(
                          context,
                          AppStrings.txSectionAmount,
                        ),
                        const SizedBox(height: 12),
                        PopupWidgets.amountField(_amountCtrl),
                        const SizedBox(height: 24),
                        IOSDialogStyle.sectionLabel(
                          context,
                          AppStrings.txSectionDate,
                        ),
                        const SizedBox(height: 12),
                        PopupWidgets.dateField(_dateCtrl, context),
                        const SizedBox(height: 24),
                        IOSDialogStyle.sectionLabel(
                          context,
                          AppStrings.txSectionDetails,
                        ),
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
                        IOSDialogStyle.sectionLabel(
                          context,
                          AppStrings.txSectionNotes,
                        ),
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

  Widget _buildActions(
    BuildContext context,
    List<dynamic> accounts,
    List<dynamic> categories,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label: AppStrings.txCancel,
              child: OutlinedButton(
                onPressed: _saving ? null : () => Navigator.pop(context),
                child: Text(AppStrings.txCancel),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppLoadingButton(
              isLoading: _saving,
              label: widget.type == 'income'
                  ? AppStrings.txSaveIncome
                  : AppStrings.txSaveExpense,
              onPressed: () => _save(context, accounts, categories),
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

    final type = widget.type;
    setState(() => _saving = true);
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

    final result = await _synced.addTransaction(tx);
    ExpenseWriteSyncResult? successWrite;
    final ok = await result.fold((failure) async {
      PopupWidgets.showErrorSnackBar(context, failure.userFacingMessage);
      return false;
    }, (write) async {
      successWrite = write;
      if (write.result.budgetSnapshot != null) {
        await FinancialAlertService.instance.maybeNotifyBudgetUsage(
          write.result.budgetSnapshot,
        );
      }
      return true;
    });
    if (!context.mounted) return;
    if (!ok || successWrite == null) {
      setState(() => _saving = false);
      return;
    }

    await FinancialRefresh.refreshAll(widget.ref);

    if (!context.mounted) return;
    HapticService.success();
    Navigator.pop(context);

    final write = successWrite!;
    final successText = write.queuedOffline
        ? ExpenseStrings.savedOffline
        : write.result.budgetMessage == null
            ? AppStrings.txSuccess(type)
            : '${AppStrings.txSuccess(type)}\n${write.result.budgetMessage}';
    PopupWidgets.showSuccessSnackBar(context, successText);
  }
}
