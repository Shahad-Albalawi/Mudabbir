import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/presentation/goals/goals_viewmodel.dart';
import 'package:mudabbir/presentation/goals/widgets/goal_list_card.dart';
import 'package:mudabbir/presentation/goals/widgets/goals_summary_card.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_animated_list_item.dart';
import 'package:mudabbir/presentation/widgets/app_offline_banner.dart';
import 'package:mudabbir/presentation/widgets/app_skeleton.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';
import 'package:mudabbir/presentation/widgets/ios_dialog_style.dart';
import 'package:mudabbir/presentation/widgets/app_snackbar.dart';
import 'package:mudabbir/service/financial_refresh.dart';
import 'package:mudabbir/service/gamification/celebration_service.dart';
import 'package:mudabbir/service/gamification/confetti_widget.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/notifications/financial_alert_service.dart';
import 'package:mudabbir/service/popup_service/goal_popup.dart';
import 'package:mudabbir/service/popup_service/popup_service.dart';
import 'package:mudabbir/service/popup_service/popup_widgets.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

class GoalView extends ConsumerStatefulWidget {
  const GoalView({super.key});

  @override
  ConsumerState<GoalView> createState() => _GoalViewState();
}

class _GoalViewState extends ConsumerState<GoalView> {
  bool _showConfetti = false;

  void _showContributionDialog(SavingsGoal goal) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final goalViewmodel = ref.read(goalViewmodelProvider.notifier);
    final previousAmount = goal.currentAmount;
    var saving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            final scheme = Theme.of(dialogContext).colorScheme;
            return Dialog(
              shape: IOSDialogStyle.dialogShape(),
              child: Container(
                width: MediaQuery.of(dialogContext).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
                decoration: IOSDialogStyle.surfaceDecoration(dialogContext),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IOSDialogStyle.header(
                      dialogContext,
                      title: AppStrings.goalContributionTitle,
                      icon: CupertinoIcons.plus_circle_fill,
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppStrings.goalLine(goal.name),
                              style: Theme.of(dialogContext)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: scheme.textMuted),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: amountController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: AppStrings.goalsAmountLabel,
                                prefixIcon: Icon(
                                  AppIcons.income,
                                  color: scheme.chromeIcon,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: noteController,
                              decoration: InputDecoration(
                                labelText: AppStrings.goalContributionNote,
                                prefixIcon: Icon(
                                  CupertinoIcons.text_bubble,
                                  color: scheme.chromeIcon,
                                ),
                              ),
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
                                onPressed: saving
                                    ? null
                                    : () => Navigator.pop(dialogContext),
                                child: Text(AppStrings.txCancel),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppLoadingButton(
                              isLoading: saving,
                              label: AppStrings.goalsAddButton,
                              onPressed: () async {
                                final amount =
                                    double.tryParse(amountController.text.trim());
                                if (amount == null || amount <= 0) {
                                  PopupWidgets.showErrorSnackBar(
                                    dialogContext,
                                    AppStrings.goalsInvalidAmount,
                                  );
                                  return;
                                }

                                setLocalState(() => saving = true);
                                final result = await goalViewmodel.addContribution(
                                  goalId: goal.id,
                                  amount: amount,
                                  note: noteController.text.trim().isEmpty
                                      ? null
                                      : noteController.text.trim(),
                                );

                                if (!dialogContext.mounted) return;
                                setLocalState(() => saving = false);
                                Navigator.pop(dialogContext);

                                if (result == null) return;

                                HapticService.success();
                                setState(() => _showConfetti = true);

                                if (result.newlyCompleted) {
                                  _showCompletionAlert(result.goal.name);
                                } else {
                                  final milestone =
                                      CelebrationService.detectMilestone(
                                    previousAmount,
                                    result.goal.currentAmount,
                                    result.goal.target,
                                  );
                                  if (milestone == null) {
                                    AppSnackbar.success(
                                      AppStrings.goalContributionSuccessBody(
                                        amount,
                                      ),
                                      title: AppStrings.goalContributionSuccessTitle,
                                    );
                                  }
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
            );
          },
        );
      },
    );
  }

  void _showCompletionAlert(String goalName) {
    FinancialAlertService.instance.notifyGoalCompleted(goalName);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: IOSDialogStyle.dialogShape(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: IOSDialogStyle.surfaceDecoration(ctx),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IOSDialogStyle.header(
                ctx,
                title: AppStrings.goalCompletedAlertTitle,
                icon: Icons.emoji_events_outlined,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                child: Text(
                  AppStrings.goalCompletedAlertBody(goalName),
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(ctx).colorScheme.textMuted,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Semantics(
                  button: true,
                  label: AppStrings.milestoneAwesome,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(AppStrings.milestoneAwesome),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final goalState = ref.watch(goalViewmodelProvider);
    final goalViewmodel = ref.read(goalViewmodelProvider.notifier);

    ref.listen<GoalState>(goalViewmodelProvider, (previous, next) async {
      if (next.isDelete) {
        await goalViewmodel.getAllGoals();
        await FinancialRefresh.refreshAll(ref);
        if (!context.mounted) return;
        AppSnackbar.success(AppStrings.goalsDeletedSuccess);
      }
      if (next.isAdd) {
        await goalViewmodel.getAllGoals();
        await FinancialRefresh.refreshAll(ref);
        if (!context.mounted) return;
        AppSnackbar.success(AppStrings.goalCreateSuccess);
      }
      if (next.isEdit) {
        await goalViewmodel.getAllGoals();
        await FinancialRefresh.refreshAll(ref);
        if (!context.mounted) return;
        AppSnackbar.success(AppStrings.goalUpdatedSuccess);
      }
      if (next.error != null &&
          previous?.error != next.error &&
          !next.isLoading) {
        if (next.error == AppStrings.offlineSavedPendingSync) {
          AppSnackbar.success(AppStrings.offlineSavedPendingSync);
        } else {
          AppSnackbar.error(next.error!);
        }
      }
    });

    return Scaffold(
      backgroundColor: scheme.pageBackground,
      body: ConfettiOverlay(
        showConfetti: _showConfetti,
        onConfettiComplete: () => setState(() => _showConfetti = false),
        child: Builder(
          builder: (context) {
            if (goalState.isLoading) {
              return const AppListSkeleton();
            }

            if (goalState.error != null && goalState.goals.isEmpty) {
              return Center(
                child: IOSEmptyState(
                  icon: Icons.flag_outlined,
                  title: AppStrings.snackErrorTitle,
                  subtitle: goalState.error!,
                  buttonLabel: AppStrings.retry,
                  onPressed: () =>
                      ref.read(goalViewmodelProvider.notifier).getAllGoals(),
                ),
              );
            }

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
                  iconColor: scheme.chromeIcon,
                ),
              );
            }

            return Column(
              children: [
                if (goalState.isOffline)
                  AppOfflineBanner(
                    message: AppStrings.goalOfflineBanner,
                    onRetry: () =>
                        ref.read(goalViewmodelProvider.notifier).getAllGoals(),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.pageGutter,
                    8,
                    AppLayout.pageGutter,
                    12,
                  ),
                  child: AppLoadingButton(
                    isLoading: false,
                    label: AppStrings.addNewGoal,
                    onPressed: () {
                      HapticService.medium();
                      getIt<PopupService>().showAddGoalPopup(context, ref);
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppLayout.pageGutter,
                      0,
                      AppLayout.pageGutter,
                      AppLayout.bottomNavClearance,
                    ),
                    itemCount: goalState.goals.length + 1,
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GoalsSummaryCard(goals: goalState.goals),
                        );
                      }
                      final goal = goalState.goals[i - 1];
                      return AppAnimatedListItem(
                        index: i,
                        child: GoalListCard(
                          goal: goal,
                          onContribute: () {
                            HapticService.light();
                            _showContributionDialog(goal);
                          },
                          onDetails: () {
                            HapticService.light();
                            context.push(AppRoutes.goalDetail(goal.id));
                          },
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
