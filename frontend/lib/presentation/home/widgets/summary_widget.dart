import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/app_skeleton.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/service/haptic_service.dart';

/// Premium financial overview — hero balance, calm metrics, clear hierarchy.
class SummaryWidget extends ConsumerStatefulWidget {
  const SummaryWidget({super.key});

  @override
  ConsumerState<SummaryWidget> createState() => _SummaryWidgetState();
}

class _SummaryWidgetState extends ConsumerState<SummaryWidget> {
  bool showTotal = false;

  String _formatAmount(num value) => AppCurrency.formatDetailed(value);

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final scheme = Theme.of(context).colorScheme;

    if (homeState.isLoading) {
      return const AppSummarySkeleton();
    }

    if (homeState.error != null) {
      return IOSEmptyState(
        icon: Icons.cloud_off_rounded,
        title: AppStrings.snackErrorTitle,
        subtitle: homeState.error!,
        buttonLabel: AppStrings.retry,
        onPressed: () => ref.read(homeProvider.notifier).reload(),
      );
    }

    final balance = showTotal
        ? homeState.currentBalance
        : homeState.monthlyBalance;
    final income =
        showTotal ? homeState.totalIncome : homeState.monthlyIncome;
    final expense =
        showTotal ? homeState.totalExpense : homeState.monthlyExpense;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.financialStatus,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: scheme.textMuted,
                        letterSpacing: 0.2,
                      ),
                ),
              ),
              _PeriodPill(
                showTotal: showTotal,
                onToggle: () {
                  HapticService.selection();
                  setState(() => showTotal = !showTotal);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.currentBalance,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatAmount(balance),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                  letterSpacing: AppTypographyScale.headlineTracking,
                  height: 1.08,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MetricChip(
                  label: AppStrings.totalIncome,
                  value: _formatAmount(income),
                  valueColor: scheme.incomeAmount,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricChip(
                  label: AppStrings.totalExpense,
                  value: _formatAmount(expense),
                  valueColor: scheme.expenseAmount,
                ),
              ),
            ],
          ),
          if (homeState.financialHealthScore > 0) ...[
            const SizedBox(height: AppSpacing.md),
            _HealthPill(score: homeState.financialHealthScore),
          ],
          if (homeState.spendingAlerts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (final alert in homeState.spendingAlerts)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  alert,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.textMuted,
                        height: 1.4,
                      ),
                ),
              ),
          ],
          if (homeState.nextMonthBudgetSuggestion > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.smd,
              ),
              decoration: BoxDecoration(
                color: scheme.insightSurface,
                borderRadius: BorderRadius.circular(AppLayout.chipRadius),
              ),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.financialLabel,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                  children: [
                    TextSpan(text: '${AppStrings.nextMonthBudgetSuggestion}: '),
                    TextSpan(
                      text: AppCurrency.format(
                        homeState.nextMonthBudgetSuggestion,
                      ),
                      style: TextStyle(
                        color: scheme.incomeAmount,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PeriodPill extends StatelessWidget {
  final bool showTotal;
  final VoidCallback onToggle;

  const _PeriodPill({required this.showTotal, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.groupedFill,
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.smd,
            vertical: AppSpacing.xs + 2,
          ),
          child: Text(
            showTotal ? AppStrings.allTime : AppStrings.thisMonth,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.groupedFill,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.textMuted,
                  fontWeight: FontWeight.w500,
                  fontSize: AppTypographyScale.caption,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                  letterSpacing: -0.2,
                ),
          ),
        ],
      ),
    );
  }
}

class _HealthPill extends StatelessWidget {
  final int score;

  const _HealthPill({required this.score});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = score >= 75
        ? scheme.dataGreen
        : score >= 50
            ? scheme.warning
            : scheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.heart, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '${AppStrings.financialHealth}: $score/100',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
