import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/domain/models/budget_record.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/budget_strings.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';

/// Intelligent budget card — remaining amount, calm progress, clear status.
class BudgetCard extends StatelessWidget {
  final BudgetRecord budget;
  final double spent;
  final VoidCallback onDelete;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final limit = budget.amount;
    final ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.5) : 0.0;
    final displayRatio = ratio.clamp(0.0, 1.0);
    final remaining = (limit - spent).clamp(0.0, limit);
    final isOver = spent > limit;
    final isWarning = !isOver && limit > 0 && spent / limit >= 0.8;

    final progressColor = isOver
        ? scheme.error
        : isWarning
            ? scheme.warning
            : scheme.primary;

    final statusLabel = isOver
        ? BudgetStrings.statusOverBudget
        : isWarning
            ? BudgetStrings.statusNearLimit
            : BudgetStrings.statusOnTrack;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      BudgetStrings.cardLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppCurrency.format(remaining),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isOver ? scheme.error : scheme.onSurface,
                            letterSpacing: AppTypographyScale.titleTracking,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      BudgetStrings.remainingOf(limit),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: progressColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    tooltip: AppStrings.delete,
                    icon: Icon(
                      CupertinoIcons.trash,
                      size: 20,
                      color: scheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: displayRatio,
              minHeight: 6,
              backgroundColor: scheme.outline.withValues(alpha: 0.12),
              color: progressColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${budget.startDate} – ${budget.endDate}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.textMuted,
                    ),
              ),
              Text(
                AppStrings.budgetSpentSummary(
                  spent.toStringAsFixed(0),
                  limit.toStringAsFixed(0),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isOver ? scheme.error : scheme.textMuted,
                      fontWeight: isOver ? FontWeight.w500 : FontWeight.w400,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
