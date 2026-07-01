import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/presentation/widgets/riyal_amount.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';

/// Shared transaction row for home and expenses lists.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onDelete,
    this.showDivider = false,
  });

  final ExpenseTransaction transaction;
  final Future<bool> Function(int id)? onDelete;
  final bool showDivider;

  static Color _categoryColor(int index) {
    return AppColors.chartPalette[index % AppColors.chartPalette.length];
  }

  static String _formatDate(String raw, BuildContext context) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('d MMM', locale).format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final isIncome = transaction.type == 'income';
    final amountColor = isIncome ? colors.green : colors.red;

    final title = transaction.notes?.trim().isNotEmpty == true
        ? transaction.notes!.trim()
        : EntityLocalizations.categoryName(transaction.categoryName);

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _categoryColor(transaction.categoryId)
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              EntityLocalizations.categoryEmoji(transaction.categoryName),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.date, context),
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          RiyalAmount(
            transaction.amount,
            prefix: isIncome ? '+' : '−',
            fontSize: textTheme.titleSmall?.fontSize,
            fontWeight: FontWeight.w700,
            symbolBold: false,
            color: amountColor,
          ),
        ],
      ),
    );

    Widget content = row;
    if (onDelete != null) {
      content = Dismissible(
        key: ValueKey(transaction.id),
        direction: DismissDirection.horizontal,
        confirmDismiss: (_) async {
          HapticFeedback.lightImpact();
          return onDelete!(transaction.id);
        },
        background: Container(
          alignment: AlignmentDirectional.centerStart,
          padding: const EdgeInsetsDirectional.only(start: 20),
          color: colors.red.withValues(alpha: 0.1),
          child: Icon(Icons.delete_outline_rounded, color: colors.red),
        ),
        child: row,
      );
    }

    if (!showDivider) return content;

    return Column(
      children: [
        Divider(height: 1, indent: 56, color: colors.divider),
        content,
      ],
    );
  }
}
