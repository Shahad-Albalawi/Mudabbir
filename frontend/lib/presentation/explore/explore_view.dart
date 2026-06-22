import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/home/widgets/add_container.dart';
import 'package:mudabbir/presentation/home/widgets/home_sync_banner.dart';
import 'package:mudabbir/presentation/home/widgets/summary_widget.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/expense_strings.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_action_tile.dart';
import 'package:mudabbir/presentation/widgets/app_animated_list_item.dart';
import 'package:mudabbir/presentation/widgets/app_section_header.dart';
import 'package:mudabbir/presentation/statistics/statistics_viewmodel.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

/// Main explore/home tab — iOS grouped layout.
class ExploreView extends ConsumerWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final homeViewModel = ref.read(homeProvider.notifier);

    return RefreshIndicator(
      onRefresh: () async {
        HapticService.light();
        await Future.wait([
          ref.read(homeProvider.notifier).reload(),
          ref.read(statisticsProvider.notifier).loadStatistics(force: true),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: AppLayout.bottomNavClearance,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFadeIn(child: const _WelcomeHeader()),
            const SizedBox(height: AppLayout.sectionGap),
            const AppFadeIn(
              delay: Duration(milliseconds: 60),
              child: HomeSyncBanner(),
            ),
            const AppFadeIn(
              delay: Duration(milliseconds: 100),
              child: SummaryWidget(),
            ),
            const SizedBox(height: AppLayout.sectionGap),
            AppSectionHeader(
              title: AppStrings.isEnglishLocale
                  ? 'Quick actions'
                  : 'إجراءات سريعة',
            ),
            const SizedBox(height: AppSpacing.sm),
            const AppFadeIn(
              delay: Duration(milliseconds: 140),
              child: AddContainer(),
            ),
            const SizedBox(height: AppLayout.sectionGap),
            AppSectionHeader(
              title: AppStrings.isEnglishLocale ? 'Insights' : 'رؤى مالية',
            ),
            const SizedBox(height: AppSpacing.sm),
            AppActionTile(
              title: ExpenseStrings.viewAllExpenses,
              icon: AppIcons.receipt,
              iconColor: scheme.primary,
              iconBackground: scheme.chromeIconFill,
              onTap: () => context.push(AppRoutes.expenses),
            ),
            const SizedBox(height: AppLayout.sectionGap),
            AppActionTile(
              title: AppStrings.navBudget,
              icon: AppIcons.wallet,
              iconColor: scheme.primary,
              iconBackground: scheme.chromeIconFill,
              onTap: () => context.push(AppRoutes.budget),
            ),
            const SizedBox(height: AppLayout.sectionGap),
            AppActionTile(
              title: AppStrings.statsAnalysisTitle,
              icon: AppIcons.statistics,
              iconColor: scheme.primary,
              iconBackground: scheme.chromeIconFill,
              onTap: () => context.push(AppRoutes.analysis),
            ),
            const SizedBox(height: AppLayout.sectionGap),
            AppActionTile(
              title: AppStrings.addChallenge,
              icon: AppIcons.challenge,
              iconColor: scheme.primary,
              iconBackground: scheme.chromeIconFill,
              onTap: () => context.push(AppRoutes.challenges),
            ),
            const SizedBox(height: AppLayout.sectionGap),
            AppActionTile(
              title: AppStrings.inviteFriend,
              icon: AppIcons.share,
              iconColor: scheme.primary,
              iconBackground: scheme.chromeIconFill,
              onTap: () => context.push(AppRoutes.invite),
            ),
            const SizedBox(height: AppLayout.sectionGap),
            AppSectionHeader(title: AppStrings.yourStat),
            const SizedBox(height: AppSpacing.smd),
            AppActionTile(
              title: AppStrings.statisticsString,
              icon: AppIcons.statistics,
              iconColor: scheme.primary,
              iconBackground: scheme.chromeIconFill,
              onTap: () => homeViewModel.changeNavBar(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.pageGutter),
      child: Text(
        AppStrings.homeText2,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: scheme.textMuted,
              height: 1.5,
            ),
      ),
    );
  }
}
