import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/persentation/goals/goals_viewmodel.dart';
import 'package:mudabbir/persentation/resources/color_manager.dart';
import 'package:mudabbir/service/popup_service/popup_widgets.dart';

class GoalPopup {
  Future<void> show(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();

    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final currentCtrl = TextEditingController(text: "0.0");
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();

    String? selectedType;
    final List<String> types = ["Saving", "Investment", "Debt", "Other"];

    // ViewModel
    final goalViewmodel = ref.read(goalViewmodelProvider.notifier);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 24,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 650),
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
                // Header
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.flag_outlined,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Create Goal",
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Set your financial goal",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary.withOpacity(0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionHeader(context, "Goal Name"),
                        const SizedBox(height: 12),
                        PopupWidgets.textField(
                          controller: nameCtrl,
                          label: "Enter goal name",
                          icon: Icons.text_fields,
                          validator: (val) => val == null || val.isEmpty
                              ? "Name is required"
                              : null,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionHeader(context, "Target Amount"),
                        const SizedBox(height: 12),
                        PopupWidgets.textField(
                          controller: targetCtrl,
                          label: "Enter target amount",
                          icon: Icons.attach_money,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Target amount is required";
                            }
                            final num? n = num.tryParse(val);
                            if (n == null || n <= 0) {
                              return "Enter a valid number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildSectionHeader(context, "Current Amount"),
                        const SizedBox(height: 12),
                        PopupWidgets.textField(
                          controller: currentCtrl,
                          label: "Current amount (optional)",
                          icon: Icons.savings_outlined,
                          validator: (val) {
                            if (val == null || val.isEmpty) return null;
                            final num? n = num.tryParse(val);
                            if (n == null || n < 0) {
                              return "Enter a valid number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildSectionHeader(context, "Goal Type"),
                        const SizedBox(height: 12),
                        PopupWidgets.dropdownField<String>(
                          value: selectedType,
                          label: "Select type",
                          items: [
                            "Saving",
                            "Investment",
                            "Debt",
                            "Other",
                          ], // List<String>
                          onChanged: (val) => selectedType = val,
                          validator: (val) =>
                              val == null ? "Please select a type" : null,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionHeader(context, "Goal Period"),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: PopupWidgets.dateField(
                                startCtrl,
                                context,
                                label: "Start Date",
                                validator: (val) => val == null || val.isEmpty
                                    ? "Start date required"
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PopupWidgets.dateField(
                                endCtrl,
                                context,
                                label: "End Date",
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return "End date required";
                                  }
                                  if (startCtrl.text.isNotEmpty) {
                                    final start = DateTime.tryParse(
                                      startCtrl.text,
                                    );
                                    final end = DateTime.tryParse(val);
                                    if (start != null &&
                                        end != null &&
                                        end.isBefore(start)) {
                                      return "End must be after start";
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }

                            final goalData = {
                              "name": nameCtrl.text,
                              "target": double.parse(targetCtrl.text),
                              "current_amount":
                                  double.tryParse(currentCtrl.text) ?? 0.0,
                              "type": selectedType,
                              "start_date": startCtrl.text,
                              "end_date": endCtrl.text,
                            };

                            try {
                              await goalViewmodel.addNewGoal(goalData);
                              Navigator.pop(context);
                              PopupWidgets.showSuccessSnackBar(
                                context,
                                "Goal created successfully! 🎉",
                              );
                            } catch (e) {
                              PopupWidgets.showErrorSnackBar(
                                context,
                                "Failed to create goal: $e",
                              );
                            }
                          },
                          child: const Text("Create Goal"),
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
