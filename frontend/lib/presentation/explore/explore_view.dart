import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/home/widgets/add_container.dart';
import 'package:mudabbir/presentation/home/widgets/summary_widget.dart';
import 'package:mudabbir/presentation/invite/invite_view.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/ios_style_constants.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/resources/values_manager.dart';
import 'package:mudabbir/presentation/widgets/ios_pressable.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/language/app_language_controller.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/theme/app_theme_controller.dart';

/// Main explore/home tab with financial summary and quick actions.
class ExploreView extends ConsumerWidget {
  const ExploreView({super.key});

  static const double _horizontalPadding = AppPadding.p16;
  static const double _sectionSpacing = AppSize.s16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeViewModel = ref.read(homeProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSize.s20, bottom: AppSize.s100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(context),
          const SizedBox(height: _sectionSpacing),
          const SummaryWidget(),
          const SizedBox(height: _sectionSpacing),
          const AddContainer(),
          const SizedBox(height: _sectionSpacing),
          _buildInviteBanner(context),
          const SizedBox(height: _sectionSpacing),
          _buildSectionTitle(context, AppStrings.yourStat),
          const SizedBox(height: AppSize.s12),
          _buildStatCard(
            context: context,
            title: AppStrings.statisticsString,
            icon: CupertinoIcons.chart_bar_fill,
            isPrimary: true,
            onTap: () => homeViewModel.changeNavBar(1),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: IOSPressable(
        onTap: () {
          HapticService.light();
          getIt<NavigationService>().navigate(InviteView());
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p20,
            vertical: AppPadding.p16,
          ),
          decoration: BoxDecoration(
            color: ColorManager.primaryWithOpacity10,
            borderRadius: BorderRadius.circular(IOSStyleConstants.radiusXLarge),
            border: Border.all(
              color: ColorManager.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share_rounded, color: ColorManager.primary, size: 22),
              const SizedBox(width: AppSize.s8),
              Text(
                AppStrings.inviteFriend,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ColorManager.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.homeText1,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: AppSize.s4),
                Text(
                  AppStrings.homeText2,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.72),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppStrings.themeModeTooltip,
            onPressed: () async {
              HapticService.light();
              await _showThemePicker(context);
            },
            icon: Icon(
              CupertinoIcons.moon_stars_fill,
              color: ColorManager.primary,
            ),
          ),
          IconButton(
            tooltip: AppStrings.languageTooltip,
            onPressed: () async {
              HapticService.light();
              await _showLanguagePicker(context);
            },
            icon: Icon(CupertinoIcons.globe, color: ColorManager.primary),
          ),
        ],
      ),
    );
  }

  Future<void> _showThemePicker(BuildContext context) async {
    final controller = getIt<AppThemeController>();
    final current = controller.themeMode;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_auto),
                title: Text(AppStrings.themeSystem),
                trailing: current == ThemeMode.system
                    ? const Icon(Icons.check, color: ColorManager.primary)
                    : null,
                onTap: () async {
                  await controller.setThemeMode(ThemeMode.system);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode_rounded),
                title: Text(AppStrings.themeLight),
                trailing: current == ThemeMode.light
                    ? const Icon(Icons.check, color: ColorManager.primary)
                    : null,
                onTap: () async {
                  await controller.setThemeMode(ThemeMode.light);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_rounded),
                title: Text(AppStrings.themeDark),
                trailing: current == ThemeMode.dark
                    ? const Icon(Icons.check, color: ColorManager.primary)
                    : null,
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
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.translate),
                title: Text(AppStrings.languageArabicOption),
                trailing: current == 'ar'
                    ? const Icon(Icons.check, color: ColorManager.primary)
                    : null,
                onTap: () async {
                  await controller.setLocale('ar');
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.translate),
                title: Text(AppStrings.languageEnglishOption),
                trailing: current == 'en'
                    ? const Icon(Icons.check, color: ColorManager.primary)
                    : null,
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: IOSPressable(
        onTap: () {
          HapticService.light();
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            color: isPrimary ? ColorManager.primary : ColorManager.white,
            borderRadius: BorderRadius.circular(IOSStyleConstants.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: isPrimary
                    ? ColorManager.primary.withValues(alpha: 0.2)
                    : ColorManager.shadowLight,
                blurRadius: IOSStyleConstants.shadowBlur,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white.withValues(alpha: 0.2)
                        : ColorManager.primaryWithOpacity10,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: isPrimary
                        ? ColorManager.white
                        : ColorManager.primary,
                  ),
                ),
                const SizedBox(width: AppSize.s16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isPrimary
                          ? ColorManager.white
                          : ColorManager.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 18,
                  color: isPrimary
                      ? ColorManager.white.withValues(alpha: 0.9)
                      : ColorManager.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
