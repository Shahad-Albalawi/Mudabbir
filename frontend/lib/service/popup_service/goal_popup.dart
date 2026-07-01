import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/presentation/goals/goals_viewmodel.dart';
import 'package:mudabbir/presentation/goals/goal_copy_helpers.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
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
                                              AppStrings.goalPickImage,
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
                            _section(context, AppStrings.goalNameLabel),
                            const SizedBox(height: 8),
                            PopupWidgets.textField(
                              controller: nameCtrl,
                              label: AppStrings.goalNameHint,
                              icon: Icons.flag_outlined,
                              validator: (val) => val == null || val.isEmpty
                                  ? AppStrings.goalNameRequired
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _section(context,AppStrings.goalTargetAmountLabel),
                            const SizedBox(height: 8),
                            PopupWidgets.textField(
                              controller: targetCtrl,
                              label: AppStrings.goalTargetAmountLabel,
                              icon: Icons.savings_outlined,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return AppStrings.goalTargetRequired;
                                }
                                final n = double.tryParse(val);
                                if (n == null || n <= 0) {
                                  return AppStrings.goalsInvalidAmount;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _section(context,AppStrings.goalCurrentAmountLabel),
                            const SizedBox(height: 8),
                            PopupWidgets.textField(
                              controller: currentCtrl,
                              label: AppStrings.goalCurrentAmountLabel,
                              icon: Icons.account_balance_wallet_outlined,
                              validator: (val) {
                                if (val == null || val.isEmpty) return null;
                                final n = double.tryParse(val);
                                if (n == null || n < 0) {
                                  return AppStrings.goalsInvalidAmount;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _section(context,AppStrings.goalTypeLabel),
                            const SizedBox(height: 8),
                            PopupWidgets.dropdownField<String>(
                              value: selectedType,
                              label: AppStrings.goalTypeLabel,
                              items: GoalCopyHelpers.goalTypeOptions,
                              onChanged: (val) =>
                                  setLocalState(() => selectedType = val),
                              validator: (val) => val == null
                                  ? AppStrings.goalTypeRequired
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _section(context,AppStrings.goalPeriodLabel),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: PopupWidgets.dateField(
                                    startCtrl,
                                    context,
                                    label: AppStrings.fieldStartDate,
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                            ? AppStrings.goalStartRequired
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: PopupWidgets.dateField(
                                    endCtrl,
                                    context,
                                    label: AppStrings.fieldEndDate,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return AppStrings.goalEndRequired;
                                      }
                                      final start =
                                          DateTime.tryParse(startCtrl.text);
                                      final end = DateTime.tryParse(val);
                                      if (start != null &&
                                          end != null &&
                                          !end.isAfter(start)) {
                                        return AppStrings.goalEndAfterStart;
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
                              label: AppStrings.txCancel,
                              child: OutlinedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => Navigator.pop(context),
                                child: Text(AppStrings.txCancel),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppLoadingButton(
                              isLoading: isSubmitting,
                              label: AppStrings.goalPopupCreateTitle,
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
                                    error != AppStrings.offlineSavedPendingSync) {
                                  PopupWidgets.showErrorSnackBar(
                                    context,
                                    AppStrings.goalCreateFailed,
                                  );
                                  return;
                                }

                                HapticService.success();
                                Navigator.pop(context);
                                PopupWidgets.showSuccessSnackBar(
                                  context,
                                  AppStrings.goalCreateSuccess,
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

    String? selectedType = GoalCopyHelpers.resolveGoalTypeForDropdown(goal.type);
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
                      title: AppStrings.goalEditTitle,
                      subtitle: AppStrings.goalEditSubtitle,
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
                              label: AppStrings.goalNameHint,
                              icon: Icons.flag_outlined,
                              validator: (val) => val == null || val.isEmpty
                                  ? AppStrings.goalNameRequired
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            PopupWidgets.textField(
                              controller: targetCtrl,
                              label: AppStrings.goalTargetAmountLabel,
                              icon: Icons.savings_outlined,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return AppStrings.goalTargetRequired;
                                }
                                final n = double.tryParse(val);
                                if (n == null || n <= 0) {
                                  return AppStrings.goalsInvalidAmount;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            PopupWidgets.dropdownField<String>(
                              value: selectedType,
                              label: AppStrings.goalTypeLabel,
                              items: GoalCopyHelpers.goalTypeOptions,
                              onChanged: (val) =>
                                  setLocalState(() => selectedType = val),
                              validator: (val) => val == null
                                  ? AppStrings.goalTypeRequired
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: PopupWidgets.dateField(
                                    startCtrl,
                                    context,
                                    label: AppStrings.fieldStartDate,
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                            ? AppStrings.goalStartRequired
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: PopupWidgets.dateField(
                                    endCtrl,
                                    context,
                                    label: AppStrings.fieldEndDate,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return AppStrings.goalEndRequired;
                                      }
                                      final start =
                                          DateTime.tryParse(startCtrl.text);
                                      final end = DateTime.tryParse(val);
                                      if (start != null &&
                                          end != null &&
                                          !end.isAfter(start)) {
                                        return AppStrings.goalEndAfterStart;
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
                              label: AppStrings.txCancel,
                              child: OutlinedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => Navigator.pop(context),
                                child: Text(AppStrings.txCancel),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppLoadingButton(
                              isLoading: isSubmitting,
                              label: AppStrings.goalSaveChanges,
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
                                    error != AppStrings.offlineSavedPendingSync) {
                                  PopupWidgets.showErrorSnackBar(
                                    context,
                                    AppStrings.goalUpdateFailed,
                                  );
                                  return;
                                }

                                HapticService.success();
                                Navigator.pop(context);
                                PopupWidgets.showSuccessSnackBar(
                                  context,
                                  AppStrings.goalUpdatedSuccess,
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
      title: AppStrings.goalPopupCreateTitle,
      subtitle: AppStrings.goalPopupCreateSubtitle,
      icon: Icons.flag_outlined,
    );
  }

  Widget _section(BuildContext context, String title) {
    return IOSDialogStyle.sectionLabel(context, title);
  }
}
