import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/budget/budget_viewmodel.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';
import 'package:mudabbir/presentation/widgets/ios_dialog_style.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'popup_widgets.dart';

class BudgetPopup {
  Future<void> show(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final amountCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();

    int? selectedAccountId;
    List<Map<String, dynamic>> accounts = [];

    final budgetViewmodel = ref.read(budgetViewmodelProvider.notifier);
    final accResult = await budgetViewmodel.getAccounts();
    accResult.fold((_) {}, (data) => accounts = data);

    if (!context.mounted) return;
    if (accounts.isEmpty) {
      PopupWidgets.showErrorSnackBar(context, AppStrings.budgetNoAccountsHint);
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 340;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final isSubmitting = ref.watch(
            budgetViewmodelProvider.select((s) => s.isSubmitting),
          );
          return PopScope(
            canPop: !isSubmitting,
            child: StatefulBuilder(
              builder: (dialogContext, setLocalState) => Dialog(
        shape: IOSDialogStyle.dialogShape(),
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isVerySmallScreen ? 12 : 20,
          vertical: isVerySmallScreen ? 20 : 40,
        ),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: isMediumScreen ? double.infinity : 400,
            maxHeight: screenHeight * 0.9,
          ),
          decoration: IOSDialogStyle.surfaceDecoration(dialogContext),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IOSDialogStyle.header(
                  dialogContext,
                  title: AppStrings.budgetPopupTitle,
                  subtitle: AppStrings.budgetPopupSubtitle,
                  icon: Icons.account_balance_wallet_outlined,
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isSmallScreen ? 14 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        IOSDialogStyle.sectionLabel(
                          dialogContext,
                          AppStrings.budgetPopupAmountSection,
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 10),
                        PopupWidgets.textField(
                          controller: amountCtrl,
                          label: AppStrings.goalsAmountHint,
                          icon: Icons.attach_money,
                          validator: _validateAmount,
                        ),
                        SizedBox(height: isSmallScreen ? 14 : 20),
                        IOSDialogStyle.sectionLabel(
                          dialogContext,
                          AppStrings.budgetPopupPeriodSection,
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 10),
                        if (isSmallScreen || isMediumScreen)
                          Column(
                            children: [
                              PopupWidgets.dateField(
                                startCtrl,
                                dialogContext,
                                label: AppStrings.fieldStartDate,
                                validator: _required,
                              ),
                              const SizedBox(height: 10),
                              PopupWidgets.dateField(
                                endCtrl,
                                dialogContext,
                                label: AppStrings.fieldEndDate,
                                validator: (val) =>
                                    _validateEndDate(val, startCtrl.text),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: PopupWidgets.dateField(
                                  startCtrl,
                                  dialogContext,
                                  label: AppStrings.fieldStartDate,
                                  validator: _required,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: PopupWidgets.dateField(
                                  endCtrl,
                                  dialogContext,
                                  label: AppStrings.fieldEndDate,
                                  validator: (val) =>
                                      _validateEndDate(val, startCtrl.text),
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: isSmallScreen ? 14 : 20),
                        IOSDialogStyle.sectionLabel(
                          dialogContext,
                          AppStrings.budgetPopupAccountSection,
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 10),
                        PopupWidgets.dropdownField<int>(
                          value: selectedAccountId,
                          label: AppStrings.fieldSelectAccount,
                          items: accounts,
                          onChanged: (val) => selectedAccountId = val,
                          validator: (val) =>
                              val == null ? AppStrings.fieldRequired : null,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(
                    isSmallScreen ? 14 : 20,
                    isSmallScreen ? 10 : 14,
                    isSmallScreen ? 14 : 20,
                    isSmallScreen ? 14 : 20,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: AppStrings.txCancel,
                          child: OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(dialogContext),
                            child: Text(AppStrings.txCancel),
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Expanded(
                        flex: isVerySmallScreen ? 1 : 2,
                        child: AppLoadingButton(
                          isLoading: isSubmitting,
                          label: isVerySmallScreen
                              ? AppStrings.addNewBudget
                              : AppStrings.addBudgetButton,
                          onPressed: () async {
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }

                            await budgetViewmodel.addNewBudget(
                              amount: double.parse(amountCtrl.text),
                              startDate: startCtrl.text,
                              endDate: endCtrl.text,
                              accountId: selectedAccountId!,
                            );
                            if (!dialogContext.mounted) return;

                            final error =
                                ref.read(budgetViewmodelProvider).error;
                            if (error != null) {
                              PopupWidgets.showErrorSnackBar(
                                dialogContext,
                                AppStrings.budgetCreateFailed,
                              );
                              return;
                            }

                            HapticService.success();
                            Navigator.pop(dialogContext);
                            if (context.mounted) {
                              PopupWidgets.showSuccessSnackBar(
                                context,
                                AppStrings.budgetCreateSuccess,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
              ),
            ),
          );
        },
      ),
    );
  }

  String? _validateAmount(String? val) {
    if (val?.isEmpty ?? true) return AppStrings.fieldAmountRequired;
    final num? n = num.tryParse(val!);
    if (n == null) return AppStrings.fieldAmountInvalid;
    if (n <= 0) return AppStrings.fieldAmountPositive;
    return null;
  }

  String? _required(String? val) {
    if (val?.isEmpty ?? true) return AppStrings.fieldRequired;
    return null;
  }

  String? _validateEndDate(String? val, String startText) {
    final required = _required(val);
    if (required != null) return required;
    if (startText.isEmpty) return null;
    final start = DateTime.tryParse(startText);
    final end = DateTime.tryParse(val!);
    if (start != null && end != null && end.isBefore(start)) {
      return AppStrings.fieldEndAfterStart;
    }
    return null;
  }
}
