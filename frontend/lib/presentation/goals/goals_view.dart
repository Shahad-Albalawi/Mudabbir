import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/presentation/goals/goals_viewmodel.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/goal_strings.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_animated_list_item.dart';
import 'package:mudabbir/presentation/widgets/app_confirm_dialog.dart';
import 'package:mudabbir/presentation/widgets/app_offline_banner.dart';
import 'package:mudabbir/presentation/widgets/app_skeleton.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';
import 'package:mudabbir/presentation/widgets/ios_dialog_style.dart';
import 'package:mudabbir/service/financial_refresh.dart';
import 'package:mudabbir/service/gamification/celebration_service.dart';
import 'package:mudabbir/service/gamification/confetti_widget.dart';
import 'package:mudabbir/service/gamification/journey_progress_map.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/notifications/financial_alert_service.dart';
import 'package:mudabbir/service/popup_service/goal_popup.dart';
import 'package:mudabbir/service/popup_service/popup_service.dart';
import 'package:mudabbir/service/popup_service/popup_widgets.dart';

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
                      title: GoalStrings.contributionTitle,
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
                                labelText: GoalStrings.contributionNote,
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
                              label: GoalStrings.cancel,
                              child: OutlinedButton(
                                onPressed: saving
                                    ? null
                                    : () => Navigator.pop(dialogContext),
                                child: Text(GoalStrings.cancel),
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
                                    getIt<NavigationService>()
                                        .showSuccessSnackbar(
                                      title:
                                          GoalStrings.contributionSuccessTitle,
                                      body: GoalStrings.contributionSuccessBody(
                                        amount,
                                      ),
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
                title: GoalStrings.completedAlertTitle,
                icon: Icons.emoji_events_outlined,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                child: Text(
                  GoalStrings.completedAlertBody(goalName),
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

  Future<void> _confirmDeleteGoal(BuildContext context, SavingsGoal goal) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.goalDeleteConfirmTitle,
      message: AppStrings.goalDeleteConfirmBody(goal.name),
    );
    if (confirmed) {
      HapticService.medium();
      await ref.read(goalViewmodelProvider.notifier).deleteGoal(goal.id);
    }
  }

  Color _statusColor(BuildContext context, GoalTrackStatus status) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case GoalTrackStatus.onTrack:
        return scheme.success;
      case GoalTrackStatus.behind:
        return scheme.warning;
      case GoalTrackStatus.overdue:
        return scheme.error;
      case GoalTrackStatus.completed:
        return scheme.dataGreen;
      case GoalTrackStatus.noData:
        return scheme.textMuted;
    }
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
        getIt<NavigationService>().showSuccessSnackbar(
          title: AppStrings.snackSuccessTitle,
          body: AppStrings.goalsDeletedSuccess,
        );
      }
      if (next.isAdd) {
        await goalViewmodel.getAllGoals();
        await FinancialRefresh.refreshAll(ref);
        if (!context.mounted) return;
        getIt<NavigationService>().showSuccessSnackbar(
          title: AppStrings.snackSuccessTitle,
          body: GoalStrings.createdSuccess,
        );
      }
      if (next.isEdit) {
        await goalViewmodel.getAllGoals();
        await FinancialRefresh.refreshAll(ref);
        if (!context.mounted) return;
        getIt<NavigationService>().showSuccessSnackbar(
          title: AppStrings.snackSuccessTitle,
          body: GoalStrings.updatedSuccess,
        );
      }
      if (next.error != null &&
          previous?.error != next.error &&
          !next.isLoading) {
        if (next.error == GoalStrings.savedOffline) {
          getIt<NavigationService>().showSuccessSnackbar(
            title: AppStrings.snackSuccessTitle,
            body: GoalStrings.savedOffline,
          );
        } else {
          getIt<NavigationService>().showErrorSnackbar(
            title: AppStrings.snackErrorTitle,
            body: next.error!,
          );
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
                    message: GoalStrings.offlineBanner,
                    onRetry: () =>
                        ref.read(goalViewmodelProvider.notifier).getAllGoals(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(AppLayout.pageGutter),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () {
                        HapticService.medium();
                        getIt<PopupService>().showAddGoalPopup(context, ref);
                      },
                      icon: const Icon(CupertinoIcons.add),
                      label: Text(
                        AppStrings.addNewGoal,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
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
                    itemCount: goalState.goals.length,
                    itemBuilder: (_, i) => AppAnimatedListItem(
                      index: i,
                      child: _goalCard(
                        context,
                        goalState.goals[i],
                        goalViewmodel,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _goalCard(
    BuildContext context,
    SavingsGoal goal,
    GoalViewmodel viewmodel,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final progress = goal.progressPercent / 100;
    final statusColor = _statusColor(context, goal.eta.status);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _goalImage(context, goal),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.textOnCard,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                GoalStrings.typeLabel(goal.type),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  GoalStrings.statusLabel(goal.eta.status),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // RTL: trailing cluster sits on physical left — delete beside edit.
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!goal.isCompleted)
                        _goalCardIconButton(
                          context,
                          icon: CupertinoIcons.plus,
                          color: scheme.primary,
                          background: scheme.primary.withValues(alpha: 0.12),
                          onPressed: () {
                            HapticService.light();
                            _showContributionDialog(goal);
                          },
                        ),
                      _goalCardIconButton(
                        context,
                        icon: CupertinoIcons.pencil,
                        color: scheme.primary,
                        background: scheme.success.withValues(alpha: 0.14),
                        onPressed: goal.isCompleted
                            ? null
                            : () {
                                HapticService.light();
                                GoalPopup().showEdit(context, ref, goal);
                              },
                      ),
                      _goalCardIconButton(
                        context,
                        icon: CupertinoIcons.delete,
                        color: scheme.error,
                        onPressed: () => _confirmDeleteGoal(context, goal),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    GoalStrings.formatAmount(goal.currentAmount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: scheme.dataGreen,
                    ),
                  ),
                  Text(
                    '${AppStrings.fromAmount} ${GoalStrings.formatAmount(goal.target)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: scheme.outline.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${goal.progressPercent.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 10),
              JourneyProgressMap(
                progress: progress,
                goalName: goal.name,
              ),
              const SizedBox(height: 12),
              _infoRow(
                context,
                Icons.event_outlined,
                GoalStrings.deadlineLabel,
                GoalStrings.formatDate(goal.endDate),
              ),
              const SizedBox(height: 6),
              _infoRow(
                context,
                Icons.auto_graph_outlined,
                GoalStrings.projectedLabel,
                GoalStrings.projectedDateText(goal.eta.projectedDate),
              ),
              if (goal.eta.requiredMonthlyToDeadline != null) ...[
                const SizedBox(height: 6),
                _infoRow(
                  context,
                  Icons.trending_up_outlined,
                  GoalStrings.monthlyNeeded,
                  GoalStrings.formatAmount(goal.eta.requiredMonthlyToDeadline!),
                ),
              ],
            ],
          ),
    );
  }

  Widget _goalCardIconButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    Color? background,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsetsDirectional.only(start: 4),
          padding: const EdgeInsets.all(8),
          decoration: background != null
              ? BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(10),
                )
              : null,
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  Widget _goalImage(BuildContext context, SavingsGoal goal) {
    final scheme = Theme.of(context).colorScheme;
    final path = goal.imagePath;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(path),
          width: 52,
          height: 52,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: scheme.chromeIconFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.flag_outlined, color: scheme.chromeIcon),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.textMuted),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: scheme.textMuted),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
