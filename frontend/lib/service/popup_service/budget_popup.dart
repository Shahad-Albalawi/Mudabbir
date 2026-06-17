import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/widgets/ios_dialog_style.dart';
import '../../presentation/budget/budget_viewmodel.dart';
import 'popup_widgets.dart';

class BudgetPopup {
  Future<void> show(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final amountCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();

    int? selectedAccountId;
    List<Map<String, dynamic>> accounts = [];

    // Load accounts via ViewModel
    final budgetViewmodel = ref.read(budgetViewmodelProvider.notifier);
    final accResult = await budgetViewmodel.getAccounts();
    accResult.fold((_) {}, (data) => accounts = data);

    if (!context.mounted) return;
    if (accounts.isEmpty) {
      PopupWidgets.showErrorSnackBar(
        context,
        'No accounts found. Please create one first.',
      );
      return;
    }

    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 340;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
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
          decoration: IOSDialogStyle.surfaceDecoration(context),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IOSDialogStyle.header(
                  context,
                  title: 'Create Budget',
                  subtitle: 'Set up your spending limits',
                  icon: Icons.account_balance_wallet_outlined,
                ),

                // Content - Scrollable
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isSmallScreen ? 14 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Budget Amount Section
                        _buildSectionHeader(
                          context,
                          "Budget Amount",
                          isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 10),
                        PopupWidgets.textField(
                          controller: amountCtrl,
                          label: "Enter amount",
                          icon: Icons.attach_money,
                          validator: (val) {
                            if (val?.isEmpty ?? true) {
                              return "Amount required";
                            }
                            final num? n = num.tryParse(val!);
                            if (n == null) return "Invalid number";
                            if (n <= 0) return "Must be > 0";
                            return null;
                          },
                        ),
                        SizedBox(height: isSmallScreen ? 14 : 20),

                        // Budget Period Section
                        _buildSectionHeader(
                          context,
                          "Budget Period",
                          isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 10),

                        // Date fields - Always vertical on small/medium screens
                        if (isSmallScreen || isMediumScreen)
                          Column(
                            children: [
                              PopupWidgets.dateField(
                                startCtrl,
                                context,
                                label: "Start Date",
                                validator: (val) {
                                  if (val?.isEmpty ?? true) {
                                    return "Required";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              PopupWidgets.dateField(
                                endCtrl,
                                context,
                                label: "End Date",
                                validator: (val) {
                                  if (val?.isEmpty ?? true) {
                                    return "Required";
                                  }
                                  if (startCtrl.text.isNotEmpty) {
                                    final start = DateTime.tryParse(
                                      startCtrl.text,
                                    );
                                    final end = DateTime.tryParse(val!);
                                    if (start != null &&
                                        end != null &&
                                        end.isBefore(start)) {
                                      return "Must be after start";
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: PopupWidgets.dateField(
                                  startCtrl,
                                  context,
                                  label: "Start Date",
                                  validator: (val) {
                                    if (val?.isEmpty ?? true) {
                                      return "Required";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: PopupWidgets.dateField(
                                  endCtrl,
                                  context,
                                  label: "End Date",
                                  validator: (val) {
                                    if (val?.isEmpty ?? true) {
                                      return "Required";
                                    }
                                    if (startCtrl.text.isNotEmpty) {
                                      final start = DateTime.tryParse(
                                        startCtrl.text,
                                      );
                                      final end = DateTime.tryParse(val!);
                                      if (start != null &&
                                          end != null &&
                                          end.isBefore(start)) {
                                        return "Must be after start";
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: isSmallScreen ? 14 : 20),

                        // Account Section
                        _buildSectionHeader(context, "Account", isSmallScreen),
                        SizedBox(height: isSmallScreen ? 6 : 10),
                        PopupWidgets.dropdownField<int>(
                          value: selectedAccountId,
                          label: "Select account",
                          items: accounts,
                          onChanged: (val) => selectedAccountId = val,
                          validator: (val) => val == null ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions - Fixed at bottom
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
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                isSmallScreen ? 8 : 10,
                              ),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Expanded(
                        flex: isVerySmallScreen ? 1 : 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }

                            final budgetData = {
                              "amount": double.parse(amountCtrl.text),
                              "start_date": startCtrl.text,
                              "end_date": endCtrl.text,
                              "account_id": selectedAccountId,
                            };

                            try {
                              await budgetViewmodel.addNewBudget(budgetData);

                              if (!context.mounted) return;
                              Navigator.pop(context);
                              PopupWidgets.showSuccessSnackBar(
                                context,
                                "Budget created successfully! 🎉",
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              PopupWidgets.showErrorSnackBar(
                                context,
                                "Failed to create budget: $e",
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                isSmallScreen ? 8 : 10,
                              ),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isVerySmallScreen ? "Create" : "Create Budget",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
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
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    bool isSmallScreen,
  ) {
    return IOSDialogStyle.sectionLabel(context, title);
  }
}
