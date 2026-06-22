import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/presentation/goals/goals_viewmodel.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/goal_strings.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';
import 'package:mudabbir/presentation/widgets/ios_dialog_style.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/popup_service/popup_widgets.dart';

class GoalPopup {
  final ImagePicker _picker = ImagePicker();

  Future<void> show(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();

    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final currentCtrl = TextEditingController(text: '0');
    final startCtrl = TextEditingController(
      text: DateTime.now().toIso8601String().split('T').first,
    );
    final endCtrl = TextEditingController();

    String? selectedType;
    String? imagePath;

    final goalViewmodel = ref.read(goalViewmodelProvider.notifier);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final isSubmitting = ref.watch(
            goalViewmodelProvider.select((s) => s.isSubmitting),
          );
          return PopScope(
            canPop: !isSubmitting,
            child: StatefulBuilder(
              builder: (context, setLocalState) {
                return Dialog(
            shape: IOSDialogStyle.dialogShape(),
            elevation: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
              decoration: IOSDialogStyle.surfaceDecoration(context),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _header(context),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: GestureDetector(
                                onTap: () async {
                                  final picked = await _picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 1200,
                                    imageQuality: 85,
                                  );
                                  if (picked != null) {
                                    setLocalState(() => imagePath = picked.path);
                                  }
                                },
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: imagePath != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(11),
                                          child: Image.file(
                                            File(imagePath!),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_a_photo_outlined,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .textMuted,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              GoalStrings.pickImage,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _section(context,GoalStrings.goalName),
                            const SizedBox(height: 8),
                            PopupWidgets.textField(
                              controller: nameCtrl,
                              label: GoalStrings.goalNameHint,
                              icon: Icons.flag_outlined,
                              validator: (val) => val == null || val.isEmpty
                                  ? GoalStrings.nameRequired
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _section(context,GoalStrings.targetAmount),
                            const SizedBox(height: 8),
                            PopupWidgets.textField(
                              controller: targetCtrl,
                              label: GoalStrings.targetAmount,
                              icon: Icons.savings_outlined,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return GoalStrings.targetRequired;
                                }
                                final n = double.tryParse(val);
                                if (n == null || n <= 0) {
                                  return GoalStrings.invalidAmount;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _section(context,GoalStrings.currentAmount),
                            const SizedBox(height: 8),
                            PopupWidgets.textField(
                              controller: currentCtrl,
                              label: GoalStrings.currentAmount,
                              icon: Icons.account_balance_wallet_outlined,
                              validator: (val) {
                                if (val == null || val.isEmpty) return null;
                                final n = double.tryParse(val);
                                if (n == null || n < 0) {
                                  return GoalStrings.invalidAmount;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _section(context,GoalStrings.goalType),
                            const SizedBox(height: 8),
                            PopupWidgets.dropdownField<String>(
                              value: selectedType,
                              label: GoalStrings.goalType,
                              items: GoalStrings.goalTypes,
                              onChanged: (val) =>
                                  setLocalState(() => selectedType = val),
                              validator: (val) => val == null
                                  ? GoalStrings.typeRequired
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _section(context,GoalStrings.goalPeriod),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: PopupWidgets.dateField(
                                    startCtrl,
                                    context,
                                    label: GoalStrings.startDate,
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                            ? GoalStrings.startRequired
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: PopupWidgets.dateField(
                                    endCtrl,
                                    context,
                                    label: GoalStrings.endDate,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return GoalStrings.endRequired;
                                      }
                                      final start =
                                          DateTime.tryParse(startCtrl.text);
                                      final end = DateTime.tryParse(val);
                                      if (start != null &&
                                          end != null &&
                                          !end.isAfter(start)) {
                                        return GoalStrings.endAfterStart;
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              button: true,
                              label: GoalStrings.cancel,
                              child: OutlinedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => Navigator.pop(context),
                                child: Text(GoalStrings.cancel),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppLoadingButton(
                              isLoading: isSubmitting,
                              label: GoalStrings.createButton,
                              onPressed: () async {
                                if (!(formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }

                                await goalViewmodel.addNewGoal(
                                  name: nameCtrl.text,
                                  target: double.parse(targetCtrl.text),
                                  currentAmount:
                                      double.tryParse(currentCtrl.text) ?? 0,
                                  type: selectedType!,
                                  startDate:
                                      DateTime.parse(startCtrl.text),
                                  endDate: DateTime.parse(endCtrl.text),
                                  imageSourcePath: imagePath,
                                );

                                if (!context.mounted) return;
                                final error =
                                    ref.read(goalViewmodelProvider).error;
                                if (error != null &&
                                    error != GoalStrings.savedOffline) {
                                  PopupWidgets.showErrorSnackBar(
                                    context,
                                    GoalStrings.createFailed,
                                  );
                                  return;
                                }

                                HapticService.success();
                                Navigator.pop(context);
                                PopupWidgets.showSuccessSnackBar(
                                  context,
                                  GoalStrings.createdSuccess,
                                );
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
          );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> showEdit(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    if (goal.isCompleted) return;

    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: goal.name);
    final targetCtrl = TextEditingController(text: goal.target.toString());
    final startCtrl = TextEditingController(
      text: goal.startDate.toIso8601String().split('T').first,
    );
    final endCtrl = TextEditingController(
      text: goal.endDate.toIso8601String().split('T').first,
    );

    String? selectedType = GoalStrings.resolveGoalTypeForDropdown(goal.type);
    String? imagePath = goal.imagePath;

    final goalViewmodel = ref.read(goalViewmodelProvider.notifier);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final isSubmitting = ref.watch(
            goalViewmodelProvider.select((s) => s.isSubmitting),
          );
          return PopScope(
            canPop: !isSubmitting,
            child: StatefulBuilder(
              builder: (context, setLocalState) {
                return Dialog(
            shape: IOSDialogStyle.dialogShape(),
            elevation: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
              decoration: IOSDialogStyle.surfaceDecoration(context),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IOSDialogStyle.header(
                      context,
                      title: GoalStrings.editTitle,
                      subtitle: GoalStrings.editSubtitle,
                      icon: Icons.edit_outlined,
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PopupWidgets.textField(
                              controller: nameCtrl,
                              label: GoalStrings.goalNameHint,
                              icon: Icons.flag_outlined,
                              validator: (val) => val == null || val.isEmpty
                                  ? GoalStrings.nameRequired
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            PopupWidgets.textField(
                              controller: targetCtrl,
                              label: GoalStrings.targetAmount,
                              icon: Icons.savings_outlined,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return GoalStrings.targetRequired;
                                }
                                final n = double.tryParse(val);
                                if (n == null || n <= 0) {
                                  return GoalStrings.invalidAmount;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            PopupWidgets.dropdownField<String>(
                              value: selectedType,
                              label: GoalStrings.goalType,
                              items: GoalStrings.goalTypes,
                              onChanged: (val) =>
                                  setLocalState(() => selectedType = val),
                              validator: (val) => val == null
                                  ? GoalStrings.typeRequired
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: PopupWidgets.dateField(
                                    startCtrl,
                                    context,
                                    label: GoalStrings.startDate,
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                            ? GoalStrings.startRequired
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: PopupWidgets.dateField(
                                    endCtrl,
                                    context,
                                    label: GoalStrings.endDate,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return GoalStrings.endRequired;
                                      }
                                      final start =
                                          DateTime.tryParse(startCtrl.text);
                                      final end = DateTime.tryParse(val);
                                      if (start != null &&
                                          end != null &&
                                          !end.isAfter(start)) {
                                        return GoalStrings.endAfterStart;
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              button: true,
                              label: GoalStrings.cancel,
                              child: OutlinedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => Navigator.pop(context),
                                child: Text(GoalStrings.cancel),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppLoadingButton(
                              isLoading: isSubmitting,
                              label: GoalStrings.saveButton,
                              onPressed: () async {
                                if (!(formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }

                                await goalViewmodel.updateGoal(
                                  goalId: goal.id,
                                  name: nameCtrl.text,
                                  target: double.parse(targetCtrl.text),
                                  type: selectedType!,
                                  startDate: DateTime.parse(startCtrl.text),
                                  endDate: DateTime.parse(endCtrl.text),
                                  imageSourcePath: imagePath,
                                );

                                if (!context.mounted) return;
                                final error =
                                    ref.read(goalViewmodelProvider).error;
                                if (error != null &&
                                    error != GoalStrings.savedOffline) {
                                  PopupWidgets.showErrorSnackBar(
                                    context,
                                    GoalStrings.updateFailed,
                                  );
                                  return;
                                }

                                HapticService.success();
                                Navigator.pop(context);
                                PopupWidgets.showSuccessSnackBar(
                                  context,
                                  GoalStrings.updatedSuccess,
                                );
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
          );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context) {
    return IOSDialogStyle.header(
      context,
      title: GoalStrings.createTitle,
      subtitle: GoalStrings.createSubtitle,
      icon: Icons.flag_outlined,
    );
  }

  Widget _section(BuildContext context, String title) {
    return IOSDialogStyle.sectionLabel(context, title);
  }
}
