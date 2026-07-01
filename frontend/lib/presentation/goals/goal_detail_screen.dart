import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/domain/services/goal_progress_engine.dart';
import 'package:mudabbir/presentation/goals/goal_milestone_utils.dart';
import 'package:mudabbir/presentation/goals/goals_viewmodel.dart';
import 'package:mudabbir/presentation/goals/goal_theme.dart';
import 'package:mudabbir/presentation/goals/widgets/goal_detail_info_row.dart';
import 'package:mudabbir/presentation/goals/widgets/goal_motivation_banner.dart';
import 'package:mudabbir/presentation/goals/widgets/journey_map_full.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/goals/goal_copy_helpers.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/riyal_amount.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/presentation/widgets/section_title_text.dart';
import 'package:mudabbir/service/gamification/celebration_service.dart';
import 'package:mudabbir/service/gamification/confetti_widget.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/popup_service/popup_widgets.dart';

class GoalDetailScreen extends ConsumerStatefulWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final int goalId;

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  bool _showConfetti = false;

  SavingsGoal? _findGoal(List<SavingsGoal> goals) {
    for (final g in goals) {
      if (g.id == widget.goalId) return g;
    }
    return null;
  }

  void _showContributionDialog(SavingsGoal goal) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final viewModel = ref.read(goalViewmodelProvider.notifier);
    final previousAmount = goal.currentAmount;
    var saving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            return AlertDialog(
              title: Text(AppStrings.goalContributionTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppStrings.goalLine(goal.name)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: AppStrings.goalsAmountLabel,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: AppStrings.goalContributionNote,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(dialogContext),
                  child: Text(AppStrings.txCancel),
                ),
                AppLoadingButton(
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
                    final result = await viewModel.addContribution(
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

                    if (!result.newlyCompleted) {
                      CelebrationService.detectMilestone(
                        previousAmount,
                        result.goal.currentAmount,
                        result.goal.target,
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalViewmodelProvider);
    final goal = _findGoal(state.goals);
    final colors = context.colors;
    final pageBg = colors.background;

    if (goal == null) {
      return AppGroupedScaffold(
        titleText: AppStrings.navGoals,
        body: ColoredBox(
          color: pageBg,
          child: Center(
            child: IOSEmptyState(
              icon: Icons.flag_outlined,
              title: AppStrings.goalLoadFailed,
              buttonLabel: AppStrings.retry,
              onPressed: () {
                ref.read(goalViewmodelProvider.notifier).getAllGoals();
                context.pop();
              },
            ),
          ),
        ),
      );
    }

    final theme = GoalTheme.forGoal(goal);
    final percent = goal.progressPercent.round();
    final bannerMessage = GoalMilestoneUtils.getMotivationBannerMessage(percent);
    final monthlyRequired = GoalProgressEngine.requiredMonthlySavings(
      remaining: goal.remainingAmount,
      now: DateTime.now(),
      endDate: goal.endDate,
    );

    return AppGroupedScaffold(
      titleText: goal.name,
      body: ConfettiOverlay(
        showConfetti: _showConfetti,
        onConfettiComplete: () => setState(() => _showConfetti = false),
        child: ColoredBox(
          color: pageBg,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.pageGutter,
              AppSpacing.md,
              AppLayout.pageGutter,
              AppLayout.bottomNavClearance,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GoalMotivationBanner(
                  message: bannerMessage,
                  accent: theme.color,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionTitleText(
                        AppStrings.isEnglishLocale
                            ? 'Your journey'
                            : 'رحلتك نحو الهدف',
                        style: AppTypography.titleMedium(
                          colors.textPrimary,
                        ).copyWith(fontWeight: AppFontWeights.bold),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      JourneyMapFull(
                        targetAmount: goal.target,
                        progressPercent: goal.progressPercent,
                        color: theme.color,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Column(
                    children: [
                      GoalDetailInfoRow(
                        icon: Icons.event_outlined,
                        label: AppStrings.goalDeadlineLabel,
                        value: GoalCopyHelpers.formatDate(goal.endDate),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GoalDetailInfoRow(
                        icon: Icons.auto_graph_outlined,
                        label: AppStrings.goalProjectedLabel,
                        value: GoalCopyHelpers.projectedDateText(
                          goal.eta.projectedDate,
                        ),
                      ),
                      if (!goal.isCompleted && goal.remainingAmount > 0) ...[
                        const SizedBox(height: AppSpacing.md),
                        GoalDetailInfoRow(
                          icon: Icons.trending_up_outlined,
                          label: AppStrings.goalMonthlyNeeded,
                          valueWidget: RiyalAmount(
                            monthlyRequired,
                            fontSize: 14,
                            fontWeight: AppFontWeights.bold,
                            symbolBold: true,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!goal.isCompleted) ...[
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        HapticService.light();
                        _showContributionDialog(goal);
                      },
                      icon: const Icon(Icons.add_rounded, size: 22),
                      label: Text(AppStrings.goalAddContributionButton),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.color,
                        foregroundColor: AppColors.textInverse,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
