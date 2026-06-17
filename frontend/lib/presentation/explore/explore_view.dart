import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/presentation/expenses/expenses_view.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/home/widgets/add_container.dart';
import 'package:mudabbir/presentation/home/widgets/summary_widget.dart';
import 'package:mudabbir/presentation/invite/invite_view.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/expense_strings.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_action_tile.dart';
import 'package:mudabbir/presentation/widgets/app_brand_logo.dart';
import 'package:mudabbir/presentation/widgets/app_section_header.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/language/app_language_controller.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/theme/app_theme_controller.dart';
import 'package:mudabbir/utils/user_display_name.dart';

/// Main explore/home tab with financial summary and quick actions.
class ExploreView extends ConsumerWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeViewModel = ref.read(homeProvider.notifier);
    final userName = UserDisplayName.fromSavedUserInfo(
      getIt<HiveService>().getValue(HiveConstants.savedUserInfo),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 12,
        bottom: AppLayout.bottomNavClearance,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeHeader(
            userName: userName,
            onThemeTap: () => _showThemePicker(context),
            onLanguageTap: () => _showLanguagePicker(context),
          ),
          const SizedBox(height: AppLayout.sectionGap),
          const SummaryWidget(),
          const SizedBox(height: AppLayout.sectionGap),
          const AddContainer(),
          const SizedBox(height: AppLayout.sectionGap),
          AppActionTile(
            title: ExpenseStrings.viewAllExpenses,
            icon: Icons.receipt_long_rounded,
            onTap: () =>
                getIt<NavigationService>().navigate(const ExpensesView()),
          ),
          const SizedBox(height: AppLayout.sectionGap),
          AppActionTile(
            title: AppStrings.inviteFriend,
            icon: Icons.ios_share_outlined,
            onTap: () =>
                getIt<NavigationService>().navigate(InviteView()),
          ),
          const SizedBox(height: AppLayout.sectionGap),
          AppSectionHeader(title: AppStrings.yourStat),
          const SizedBox(height: 12),
          AppActionTile(
            title: AppStrings.statisticsString,
            icon: CupertinoIcons.chart_bar,
            onTap: () => homeViewModel.changeNavBar(1),
          ),
        ],
      ),
    );
  }

  Future<void> _showThemePicker(BuildContext context) async {
    final controller = getIt<AppThemeController>();
    final current = controller.themeMode;
    final scheme = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetTile(
                ctx,
                icon: Icons.brightness_auto,
                label: AppStrings.themeSystem,
                selected: current == ThemeMode.system,
                scheme: scheme,
                onTap: () async {
                  await controller.setThemeMode(ThemeMode.system);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              _sheetTile(
                ctx,
                icon: Icons.light_mode_rounded,
                label: AppStrings.themeLight,
                selected: current == ThemeMode.light,
                scheme: scheme,
                onTap: () async {
                  await controller.setThemeMode(ThemeMode.light);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              _sheetTile(
                ctx,
                icon: Icons.dark_mode_rounded,
                label: AppStrings.themeDark,
                selected: current == ThemeMode.dark,
                scheme: scheme,
                onTap: () async {
                  await controller.setThemeMode(ThemeMode.dark);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final controller = getIt<AppLanguageController>();
    final current = controller.locale.languageCode;
    final scheme = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetTile(
                ctx,
                icon: Icons.translate,
                label: AppStrings.languageArabicOption,
                selected: current == 'ar',
                scheme: scheme,
                onTap: () async {
                  await controller.setLocale('ar');
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              _sheetTile(
                ctx,
                icon: Icons.translate,
                label: AppStrings.languageEnglishOption,
                selected: current == 'en',
                scheme: scheme,
                onTap: () async {
                  await controller.setLocale('en');
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetTile(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required bool selected,
    required ColorScheme scheme,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: scheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String userName;
  final VoidCallback onThemeTap;
  final VoidCallback onLanguageTap;

  const _WelcomeHeader({
    required this.userName,
    required this.onThemeTap,
    required this.onLanguageTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final greeting = userName.isEmpty
        ? AppStrings.homeText1
        : AppStrings.homeText1;
    final namePart = userName.isEmpty ? null : userName;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.pageGutter),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        decoration: BoxDecoration(
          color: scheme.homeBannerFill,
          borderRadius: BorderRadius.circular(AppLayout.cardRadius),
          border: Border.all(
            color: scheme.homeGreen.withValues(alpha: 0.22),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppBrandLogo(height: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: scheme.onSurface,
                      ),
                      children: [
                        TextSpan(text: '$greeting${namePart != null ? '، ' : ''}'),
                        if (namePart != null)
                          TextSpan(
                            text: namePart,
                            style: TextStyle(color: scheme.homeGreen),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.homeText2,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: AppStrings.themeModeTooltip,
              onPressed: () {
                HapticService.light();
                onThemeTap();
              },
              icon: Icon(Icons.brightness_6_outlined, size: 20, color: scheme.homeGreen),
            ),
            IconButton(
              tooltip: AppStrings.languageTooltip,
              onPressed: () {
                HapticService.light();
                onLanguageTap();
              },
              icon: Icon(Icons.language_outlined, size: 20, color: scheme.homeGreen),
            ),
          ],
        ),
      ),
    );
  }
}
