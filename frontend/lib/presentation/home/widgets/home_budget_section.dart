import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/home/home_screen_provider.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/riyal_amount.dart';
import 'package:mudabbir/presentation/widgets/section_title_text.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

/// قسم الميزانية — فئتان مع شريط تقدم رفيع.
class HomeBudgetSection extends StatelessWidget {
  const HomeBudgetSection({
    super.key,
    required this.categories,
  });

  final List<HomeBudgetCategoryRow> categories;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SectionTitleText(
                AppStrings.navBudget,
                style: textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.budget),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppStrings.homeBudgetManage,
                style: textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: categories.isEmpty
              ? Text(
                  AppStrings.homeBudgetEmptyCategories,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < categories.length; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      _CategoryBudgetRow(row: categories[i]),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _CategoryBudgetRow extends StatelessWidget {
  const _CategoryBudgetRow({required this.row});

  final HomeBudgetCategoryRow row;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(row.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                row.name,
                style: textTheme.titleSmall,
              ),
            ),
            RiyalAmount(
              row.spent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              symbolBold: false,
              color: colors.textPrimary,
            ),
            Text(
              ' / ',
              style: textTheme.bodySmall?.copyWith(color: colors.textTertiary),
            ),
            RiyalAmount(
              row.limit,
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: row.progress,
            minHeight: 5,
            color: AppColors.navy1,
            backgroundColor: colors.primarySurface,
          ),
        ),
      ],
    );
  }
}
