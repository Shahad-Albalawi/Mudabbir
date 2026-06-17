import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/service/haptic_service.dart';

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

    return AppCard(
      color: scheme.brightness == Brightness.light
          ? scheme.homeBannerFill.withValues(alpha: 0.55)
          : scheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: scheme.homeGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.financialStatus,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      showTotal ? AppStrings.allTime : AppStrings.thisMonth,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  HapticService.selection();
                  setState(() => showTotal = !showTotal);
                },
                icon: Icon(
                  showTotal ? Icons.calendar_view_month : Icons.calendar_today,
                  size: 16,
                  color: scheme.homeGreen,
                ),
                label: Text(
                  showTotal
                      ? AppStrings.totalLabel
                      : AppStrings.currentMonthLabel,
                  style: TextStyle(fontSize: 12, color: scheme.homeGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _amountRow(
            context,
            label: AppStrings.totalIncome,
            amount: _formatAmount(
              showTotal ? homeState.totalIncome : homeState.monthlyIncome,
            ),
            color: scheme.success,
          ),
          const SizedBox(height: 10),
          _amountRow(
            context,
            label: AppStrings.currentBalance,
            amount: _formatAmount(
              showTotal ? homeState.currentBalance : homeState.monthlyBalance,
            ),
            color: scheme.homeGreen,
            emphasized: true,
          ),
          const SizedBox(height: 10),
          _amountRow(
            context,
            label: AppStrings.totalExpense,
            amount: _formatAmount(
              showTotal ? homeState.totalExpense : homeState.monthlyExpense,
            ),
            color: scheme.error,
          ),
          if (homeState.financialHealthScore > 0) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            _healthRow(context, homeState),
          ],
          if (homeState.spendingAlerts.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final alert in homeState.spendingAlerts)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: scheme.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        alert,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (homeState.nextMonthBudgetSuggestion > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${AppStrings.nextMonthBudgetSuggestion}: ${AppCurrency.format(homeState.nextMonthBudgetSuggestion)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _amountRow(
    BuildContext context, {
    required String label,
    required String amount,
    required Color color,
    bool emphasized = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.textOnCard,
            ),
          ),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _healthRow(BuildContext context, HomeState homeState) {
    final scheme = Theme.of(context).colorScheme;
    final score = homeState.financialHealthScore;
    final scoreColor = score >= 75
        ? scheme.homeGreen
        : score >= 50
        ? scheme.warning
        : scheme.error;

    return Row(
      children: [
        Icon(Icons.favorite_border, size: 18, color: scoreColor),
        const SizedBox(width: 8),
        Text(
          '${AppStrings.financialHealth}: $score/100',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
