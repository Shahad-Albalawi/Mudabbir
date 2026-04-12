import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/persentation/goals/goals_viewmodel.dart';
import 'package:mudabbir/persentation/resources/color_manager.dart';
import 'package:mudabbir/persentation/resources/strings_manager.dart';
import 'package:mudabbir/persentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/popup_service/goal_popup.dart';
import 'package:mudabbir/service/popup_service/popup_service.dart';

// Import the gamification files
import 'package:mudabbir/service/gamification/celebration_service.dart';
import 'package:mudabbir/service/gamification/journey_progress_map.dart';
import 'package:mudabbir/service/gamification/confetti_widget.dart';

class GoalView extends ConsumerStatefulWidget {
  const GoalView({super.key});

  @override
  ConsumerState<GoalView> createState() => _GoalViewState();
}

class _GoalViewState extends ConsumerState<GoalView> {
  bool _showConfetti = false;

  // Method to show update dialog with gamification
  void _showUpdateDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> goal,
  ) {
    final amountController = TextEditingController();
    final goalViewmodel = ref.read(goalViewmodelProvider.notifier);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final dlgScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: dlgScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_circle_outline,
                  color: ColorManager.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.goalsAddAmountTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: dlgScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.goalLine(goal['name'].toString()),
                style: TextStyle(
                  fontSize: 16,
                  color: dlgScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  labelText: AppStrings.goalsAmountLabel,
                  hintText: AppStrings.goalsAmountHint,
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorManager.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.attach_money,
                      color: ColorManager.primary,
                      size: 20,
                    ),
                  ),
                  filled: true,
                  fillColor: dlgScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: dlgScheme.outline.withValues(alpha: 0.35),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorManager.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppStrings.txCancel,
                style: TextStyle(
                  color: dlgScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final amountText = amountController.text.trim();
                  if (amountText.isNotEmpty) {
                    final amount = double.tryParse(amountText);
                    if (amount != null && amount > 0) {
                      // Get previous amount for milestone detection
                      final previousAmount = (goal['current_amount'] ?? 0.0)
                          .toDouble();
                      final target = (goal['target'] ?? 1.0).toDouble();

                      // Update goal
                      await goalViewmodel.updateGoalAmount(goal['id'], amount);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();

                      // Calculate new amount
                      final newAmount = previousAmount + amount;

                      // Detect milestone
                      final milestone = CelebrationService.detectMilestone(
                        previousAmount,
                        newAmount,
                        target,
                      );

                      // Show success message
                      // getIt<NavigationService>().showSuccessSnackbar(
                      //   title: 'نجح',
                      //   body: 'تم تحديث الهدف بنجاح',
                      // );

                      // Haptic + confetti
                      HapticService.success();
                      if (!context.mounted) return;
                      setState(() => _showConfetti = true);

                      // Show milestone dialog if achieved
                      if (milestone != null) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (!context.mounted) return;
                          CelebrationService.showMilestoneDialog(
                            context,
                            milestone,
                            goal['name'],
                          );
                        });
                      }
                    } else {
                      getIt<NavigationService>().showErrorSnackbar(
                        title: AppStrings.snackErrorTitle,
                        body: AppStrings.goalsInvalidAmount,
                      );
                    }
                  }
                },
                child: Text(
                  AppStrings.goalsAddButton,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final goalState = ref.watch(goalViewmodelProvider);
    final goalViewmodel = ref.read(goalViewmodelProvider.notifier);

    ref.listen<GoalState>(goalViewmodelProvider, (
      previousState,
      newState,
    ) async {
      if (newState.isDelete != null) {
        await goalViewmodel.getAllGoals();
        if (!context.mounted) return;
        getIt<NavigationService>().showSuccessSnackbar(
          title: AppStrings.snackSuccessTitle,
          body: AppStrings.goalsDeletedSuccess,
        );
      }
      if (newState.isAdd == true) {
        await goalViewmodel.getAllGoals();
      }
      if (newState.isUpdate == true) {
        // Goal updated successfully
      }
    });

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      body: ConfettiOverlay(
        showConfetti: _showConfetti,
        onConfettiComplete: () {
          setState(() => _showConfetti = false);
        },
        child: Builder(
          builder: (context) {
            // Loading
            if (goalState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Empty state (no goals)
            if (goalState.goals.isEmpty) {
              return Center(
                child: IOSEmptyState(
                  icon: Icons.flag_outlined,
                  title: AppStrings.goalsEmptyTitle,
                  subtitle: AppStrings.goalsEmptySubtitle,
                  buttonLabel: AppStrings.addNewGoal,
                  onPressed: () {
                    HapticService.medium();
                    GoalPopup().show(context, ref);
                  },
                  iconColor: ColorManager.primary,
                ),
              );
            }

            // Goals exist → show "Add" button + list
            return Column(
              children: [
                // Add Goal Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: ColorManager.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: ColorManager.primary.withValues(alpha: 0.14),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        HapticService.medium();
                        getIt<PopupService>().showAddGoalPopup(context, ref);
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text(
                        AppStrings.addNewGoal,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Goals List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: goalState.goals.length,
                    itemBuilder: (_, i) {
                      final goal = goalState.goals[i];
                      final currentAmount = (goal['current_amount'] ?? 0.0)
                          .toDouble();
                      final target = (goal['target'] ?? 1.0).toDouble();
                      final progress = target > 0
                          ? (currentAmount / target).clamp(0.0, 1.0)
                          : 0.0;

                      return GestureDetector(
                        onTap: () {
                          HapticService.light();
                          _showUpdateDialog(context, ref, goal);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Goal Header
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: ColorManager.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.flag_outlined,
                                        color: ColorManager.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "${goal['name']}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await goalViewmodel.deleteGoal(
                                          goal['id'],
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: ColorManager.error,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Amount Info
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${currentAmount.toStringAsFixed(0)} ر.س",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: ColorManager.primary,
                                      ),
                                    ),
                                    Text(
                                      "${AppStrings.fromAmount} ${target.toStringAsFixed(0)} ر.س",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Journey Progress Map with Animation
                                JourneyProgressMap(
                                  progress: progress,
                                  goalName: goal['name'],
                                  primaryColor: ColorManager.primary,
                                  secondaryColor: ColorManager.darkPrimary,
                                ),

                                const SizedBox(height: 8),

                                // Tap Hint
                                Text(
                                  AppStrings.tapToAdd,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: ColorManager.primary.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
