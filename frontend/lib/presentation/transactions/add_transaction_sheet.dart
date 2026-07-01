import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/expense_sync_result.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/domain/repository/synced_expense_repository/synced_expense_repository.dart';
import 'package:mudabbir/presentation/home/home_screen_provider.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/resources/saudi_riyal_font.dart';
import 'package:mudabbir/presentation/transactions/transaction_sheet_categories.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';
import 'package:mudabbir/service/financial_refresh.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/popup_service/popup_widgets.dart';
import 'package:mudabbir/service/popup_service/transaction_popup.dart';

/// Bottom sheet — add income or expense with category grid.
abstract final class AddTransactionSheet {
  AddTransactionSheet._();

  static Future<void> show(
    BuildContext context, {
    String initialType = 'expense',
  }) {
    HapticService.medium();
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: _AddTransactionSheetBody(initialType: initialType),
      ),
    );
  }
}

class _AddTransactionSheetBody extends ConsumerStatefulWidget {
  const _AddTransactionSheetBody({required this.initialType});

  final String initialType;

  @override
  ConsumerState<_AddTransactionSheetBody> createState() =>
      _AddTransactionSheetBodyState();
}

class _AddTransactionSheetBodyState
    extends ConsumerState<_AddTransactionSheetBody> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _amountFocus = FocusNode();

  late String _type;
  late TransactionSheetCategory _selectedCategory;
  bool _saving = false;

  int? _accountId;
  Map<String, int> _categoryIdsByDbName = {};
  String? _loadError;

  SyncedExpenseRepository get _synced => GetIt.I<SyncedExpenseRepository>();
  TransactionPopup get _popup => GetIt.I<TransactionPopup>();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType == 'income' ? 'income' : 'expense';
    _selectedCategory = TransactionSheetCategories.defaultFor(_type);
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _amountFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final result = await _popup.loadTransactionData(_type);
    if (!mounted) return;
    result.fold(
      (message) => setState(() => _loadError = message),
      (data) {
        final accounts = data['accounts']! as List<dynamic>;
        final categories = data['categories']! as List<dynamic>;
        if (accounts.isEmpty || categories.isEmpty) {
          setState(() => _loadError = AppStrings.txNoCategories(_type));
          return;
        }
        final ids = <String, int>{};
        for (final row in categories) {
          final name = row['name']?.toString() ?? '';
          ids[name] = (row['id'] as num).toInt();
        }
        setState(() {
          _loadError = null;
          _accountId = (accounts.first['id'] as num).toInt();
          _categoryIdsByDbName = ids;
        });
      },
    );
  }

  Future<void> _setType(String type) async {
    if (_type == type) return;
    HapticService.selection();
    setState(() {
      _type = type;
      if (!_selectedCategory.supports(_type)) {
        _selectedCategory = TransactionSheetCategories.defaultFor(_type);
      }
    });
    await _loadData();
  }

  Future<void> _selectCategory(TransactionSheetCategory category) async {
    HapticService.selection();
    if (!category.supports(_type)) {
      final nextType = category.types.contains('income') ? 'income' : 'expense';
      await _setType(nextType);
    }
    if (!mounted) return;
    setState(() => _selectedCategory = category);
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldAmountRequired;
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return AppStrings.fieldAmountInvalid;
    if (parsed <= 0) return AppStrings.fieldAmountPositive;
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_accountId == null || _categoryIdsByDbName.isEmpty) {
      PopupWidgets.showErrorSnackBar(context, AppStrings.txLoadFailed(''));
      return;
    }

    final categoryId = _categoryIdsByDbName[_selectedCategory.dbName];
    if (categoryId == null) {
      PopupWidgets.showErrorSnackBar(
        context,
        AppStrings.txNoCategories(_type),
      );
      return;
    }

    final amount = double.parse(_amountCtrl.text.replaceAll(',', '.'));
    setState(() => _saving = true);

    final today = DateTime.now().toIso8601String().split('T').first;
    final tx = ExpenseTransaction(
      id: 0,
      amount: amount,
      date: today,
      type: _type,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      accountId: _accountId!,
      categoryId: categoryId,
      accountName: '',
      categoryName: _selectedCategory.dbName,
    );

    final result = await _synced.addTransaction(tx);
    if (!mounted) return;

    ExpenseWriteSyncResult? writeResult;
    final ok = await result.fold(
      (failure) async {
        PopupWidgets.showErrorSnackBar(context, failure.userFacingMessage);
        return false;
      },
      (write) async {
        writeResult = write;
        return true;
      },
    );

    if (!ok || writeResult == null) {
      setState(() => _saving = false);
      return;
    }

    final saved = tx.copyWith(id: writeResult!.result.transactionId);
    ref.read(homeScreenProvider.notifier).prependTransaction(saved);
    await FinancialRefresh.refreshAll(ref);
    ref.read(homeProvider.notifier).reload();

    if (!mounted) return;
    HapticService.success();
    Navigator.pop(context);
    PopupWidgets.showSuccessSnackBar(context, AppStrings.txSuccess(_type));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: colors.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(TransactionSheetCategories.sheetTopRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + bottomInset),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colors.textTertiary.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                _TypeTabs(
                  type: _type,
                  onChanged: _setType,
                ),
                const SizedBox(height: 20),
                if (_loadError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(color: colors.red),
                    ),
                  ),
                _AmountField(
                  controller: _amountCtrl,
                  focusNode: _amountFocus,
                  validator: _validateAmount,
                ),
                const SizedBox(height: 20),
                _CategoryGrid(
                  selected: _selectedCategory,
                  type: _type,
                  onSelected: _selectCategory,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 1,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: AppStrings.isEnglishLocale
                        ? 'Note (optional)'
                        : 'ملاحظة (اختياري)',
                    filled: true,
                    fillColor: colors.surfaceTint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AppLoadingButton(
                  isLoading: _saving,
                  label: AppStrings.expensesSaveButton,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeTabs extends StatelessWidget {
  const _TypeTabs({
    required this.type,
    required this.onChanged,
  });

  final String type;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeTab(
              label: AppStrings.expensesAddButton,
              selected: type == 'expense',
              onTap: () => onChanged('expense'),
            ),
          ),
          Expanded(
            child: _TypeTab(
              label: AppStrings.addIncome,
              selected: type == 'income',
              onTap: () => onChanged('income'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navy1 : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.focusNode,
    required this.validator,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currencyLabel = SaudiRiyalFont.isAvailable
        ? SaudiRiyalFont.symbol
        : (AppStrings.isEnglishLocale
            ? SaudiRiyalFont.fallbackLabelEn
            : 'ر.س');

    return Column(
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          currencyLabel,
          style: TextStyle(
            fontFamily: SaudiRiyalFont.isAvailable
                ? SaudiRiyalFont.family
                : null,
            fontSize: 16,
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.selected,
    required this.type,
    required this.onSelected,
  });

  final TransactionSheetCategory selected;
  final String type;
  final ValueChanged<TransactionSheetCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: TransactionSheetCategories.all.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final category = TransactionSheetCategories.all[index];
        final isSelected = category.dbName == selected.dbName;
        final dimmed = !category.supports(type);

        return Opacity(
          opacity: dimmed ? 0.45 : 1,
          child: Material(
            color: isSelected
                ? AppColors.navySurface
                : colors.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => onSelected(category),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.navy1
                        : colors.border.withValues(alpha: 0.6),
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category.icon,
                      size: 22,
                      color: isSelected ? AppColors.navy1 : colors.textSecondary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.navy1
                            : colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
