import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:dartz/dartz.dart';
import 'package:mudabbir/persentation/resources/color_manager.dart';
import 'package:mudabbir/persentation/resources/entity_localizations.dart';
import 'package:mudabbir/persentation/resources/strings_manager.dart';
import 'package:mudabbir/persentation/home/home_viewmodel.dart';

import '../../data/local/database_helper.dart';
import '../../domain/repository/home_repository/home_repository.dart';
import 'popup_widgets.dart';
import 'popup_validators.dart';

class TransactionPopup {
  final _db = GetIt.I<DbHelper>();
  final _homeRepo = GetIt.I<HomeRepository>();

  Future<void> show(BuildContext context, {required String type}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Consumer(
        builder: (context, ref,  _) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 24,
            child: _buildDialogContent(context, ref, type),
          );
        },
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context, WidgetRef ref, String type) {
    final formKey = GlobalKey<FormState>();
    final amountCtrl = TextEditingController();
    final dateCtrl = TextEditingController(
      text: DateTime.now().toString().split(' ')[0],
    );
    final notesCtrl = TextEditingController();

    int? accountId;
    int? categoryId;

    return FutureBuilder(
      future: _loadTransactionData(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || (snapshot.data?.isLeft() ?? true)) {
          return Center(
            child: Text(
              AppStrings.txLoadError,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        final data = snapshot.data!.getOrElse(() => {});
        final accounts = data['accounts']!;
        final categories = data['categories']!;
        final currentBalance = data['balance'] ?? 0.0;

        return Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.95),
              ],
            ),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        ColorManager.primary,
                        ColorManager.primary.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            type == 'income'
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            type == 'income'
                                ? AppStrings.addIncome
                                : AppStrings.addExpense,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      // Show current balance for expense
                      if (type == 'expense') ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.txAvailableBalance,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '\$${currentBalance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ✅ Form content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionHeader(context, AppStrings.txSectionAmount),
                        const SizedBox(height: 12),
                        PopupWidgets.amountField(amountCtrl),
                        const SizedBox(height: 24),

                        _buildSectionHeader(context, AppStrings.txSectionDate),
                        const SizedBox(height: 12),
                        PopupWidgets.dateField(dateCtrl, context),
                        const SizedBox(height: 24),

                        _buildSectionHeader(context, AppStrings.txSectionDetails),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: PopupWidgets.dropdownField<int>(
                                value: accountId,
                                label: AppStrings.labelAccount,
                                items: accounts,
                                onChanged: (val) => accountId = val,
                                formatItemLabel: EntityLocalizations.accountName,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PopupWidgets.dropdownField<int>(
                                value: categoryId,
                                label: AppStrings.labelCategory,
                                items: categories,
                                onChanged: (val) => categoryId = val,
                                formatItemLabel: EntityLocalizations.categoryName,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _buildSectionHeader(context, AppStrings.txSectionNotes),
                        const SizedBox(height: 12),
                        PopupWidgets.notesField(notesCtrl),
                      ],
                    ),
                  ),
                ),

                // ✅ Buttons
                Container(
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
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }

                            final amount = double.parse(amountCtrl.text);

                            // ✅ Validate expense against balance
                            if (type == 'expense') {
                              if (amount > currentBalance) {
                                _showBalanceError(context, currentBalance);
                                return;
                              }
                            }

                            // Save transaction
                            await _db.insert('transactions', {
                              'amount': amount,
                              'date': dateCtrl.text,
                              'type': type,
                              'notes': notesCtrl.text.trim(),
                              'account_id': accountId,
                              'category_id': categoryId,
                            });

                            // ✅ Reload Home state
                            await ref.read(homeProvider.notifier).reload();

                            Navigator.pop(context);
                            PopupWidgets.showSuccessSnackBar(
                              context,
                              AppStrings.txSuccess(type),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            type == 'income'
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Either<String, Map<String, dynamic>>> _loadTransactionData(
    String type,
  ) async {
    try {
      final cats = await _db.queryRow('categories', 'type = ?', [type]);
      final accs = await _db.queryRow('accounts', '1=?', [1]);

      final categories = cats.getOrElse(() => []);
      final accounts = accs.getOrElse(() => []);

      if (accounts.isEmpty) return Left(AppStrings.txNoAccounts);
      if (categories.isEmpty) return Left(AppStrings.txNoCategories(type));

      // ✅ Calculate current balance (total income - total expenses)
      double balance = 0.0;
      final transactions = await _db.queryRow('transactions', '1=?', [1]);
      final allTransactions = transactions.getOrElse(() => []);

      for (var transaction in allTransactions) {
        final amount = transaction['amount'] as double;
        final txType = transaction['type'] as String;
        if (txType == 'income') {
          balance += amount;
        } else if (txType == 'expense') {
          balance -= amount;
        }
      }

      return Right({
        'categories': categories,
        'accounts': accounts,
        'balance': balance,
      });
    } catch (e) {
      return Left(AppStrings.txLoadFailed(e));
    }
  }

  void _showBalanceError(BuildContext context, double currentBalance) {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: ColorManager.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(AppStrings.txInsufficientTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.txInsufficientBody,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorManager.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorManager.error.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.txAvailableBalanceShort,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '\$${currentBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: ColorManager.error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.txInsufficientHint,
              style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.txOk),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: ColorManager.primary,
      ),
    );
  }
}
