import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/presentation/goals/goals_viewmodel.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/goal_strings.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/presentation/widgets/ios_loading_widget.dart';
import 'package:mudabbir/service/gamification/celebration_service.dart';
import 'package:mudabbir/service/gamification/confetti_widget.dart';
import 'package:mudabbir/service/gamification/journey_progress_map.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/popup_service/goal_popup.dart';
import 'package:mudabbir/service/popup_service/popup_service.dart';

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

    showDialog(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          backgroundColor: scheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(GoalStrings.contributionTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.goalLine(goal.name),
                style: TextStyle(color: scheme.textMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppStrings.goalsAmountLabel,
                  hintText: AppStrings.goalsAmountHint,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: GoalStrings.contributionNote,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(GoalStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                if (amount == null || amount <= 0) {
                  getIt<NavigationService>().showErrorSnackbar(
                    title: AppStrings.snackErrorTitle,
                    body: AppStrings.goalsInvalidAmount,
                  );
                  return;
                }

                final result = await goalViewmodel.addContribution(
                  goalId: goal.id,
                  amount: amount,
                  note: noteController.text.trim().isEmpty
                      ? null
                      : noteController.text.trim(),
                );

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);

                if (result == null) return;

                HapticService.success();
                setState(() => _showConfetti = true);

                final milestone = CelebrationService.detectMilestone(
                  previousAmount,
                  result.goal.currentAmount,
                  result.goal.target,
                );

                if (result.newlyCompleted) {
                  _showCompletionAlert(result.goal.name);
                } else if (milestone != null && mounted) {
                  CelebrationService.showMilestoneDialog(
                    context,
                    milestone,
                    result.goal.name,
                  );
                }
              },
              child: Text(AppStrings.goalsAddButton),
            ),
          ],
        );
      },
    );
  }

  void _showCompletionAlert(String goalName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(GoalStrings.completedAlertTitle),
        content: Text(GoalStrings.completedAlertBody(goalName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.milestoneAwesome),
          ),
        ],
      ),
    );
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
        return scheme.primary;
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
        if (!context.mounted) return;
        getIt<NavigationService>().showSuccessSnackbar(
          title: AppStrings.snackSuccessTitle,
          body: AppStrings.goalsDeletedSuccess,
        );
      }
      if (next.isAdd) {
        await goalViewmodel.getAllGoals();
      }
      if (next.isEdit) {
        await goalViewmodel.getAllGoals();
      }
    });

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      body: ConfettiOverlay(
        showConfetti: _showConfetti,
        onConfettiComplete: () => setState(() => _showConfetti = false),
        child: Builder(
          builder: (context) {
            if (goalState.isLoading) {
              return const Center(child: IOSLoadingWidget(size: 56));
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
                  iconColor: scheme.primary,
                ),
              );
            }

            return Column(
              children: [
                if (goalState.isOffline)
                  MaterialBanner(
                    content: Text(GoalStrings.offlineBanner),
                    leading: const Icon(Icons.cloud_off_outlined),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            ref.read(goalViewmodelProvider.notifier).getAllGoals(),
                        child: Text(ServerChallengeStrings.retry),
                      ),
                    ],
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
                      icon: const Icon(Icons.add_rounded),
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
                    itemBuilder: (_, i) => _goalCard(
                      context,
                      goalState.goals[i],
                      goalViewmodel,
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
      onTap: goal.isCompleted
          ? null
          : () {
              HapticService.light();
              _showContributionDialog(goal);
            },
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          GoalStrings.typeLabel(goal.type),
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  IconButton(
                    onPressed: goal.isCompleted
                        ? null
                        : () {
                            HapticService.light();
                            GoalPopup().showEdit(context, ref, goal);
                          },
                    icon: Icon(
                      CupertinoIcons.pencil,
                      color: scheme.primary,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () => viewmodel.deleteGoal(goal.id),
                    icon: Icon(
                      CupertinoIcons.delete,
                      color: scheme.error,
                      size: 20,
                    ),
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
                      color: scheme.primary,
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
                primaryColor: scheme.primary,
                secondaryColor: scheme.primary.withValues(alpha: 0.65),
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
              if (!goal.isCompleted) ...[
                const SizedBox(height: 8),
                Text(
                  GoalStrings.contributeHint,
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.primary.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ],
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
        color: scheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.flag_outlined, color: scheme.primary),
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
