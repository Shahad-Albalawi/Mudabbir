import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/home/widgets/modern_bottom_navbar.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/modern_gradient_appbar.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';
import 'package:mudabbir/utils/user_display_name.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _getUserDisplayName(HiveService hive) {
    try {
      return UserDisplayName.fromSavedUserInfo(
        hive.getValue(HiveConstants.savedUserInfo),
      );
    } catch (_) {
      return '';
    }
  }

  String _titleForTab(int index, String userName) {
    return switch (index) {
      0 => userName.isNotEmpty
          ? '${AppStrings.homeText1}، $userName'
          : AppStrings.navHome,
      1 => AppStrings.navStatistics,
      2 => AppStrings.navGoals,
      _ => AppStrings.title,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final homeViewModel = ref.read(homeProvider.notifier);
    final homeState = ref.watch(homeProvider);
    final hive = getIt<HiveService>();
    final userName = _getUserDisplayName(hive);

    return Scaffold(
      backgroundColor: scheme.pageBackground,
      extendBody: true,
      appBar: ModernGradientAppBar(
        showBackButton: false,
        largeTitle: true,
        title: Text(_titleForTab(homeState.currentIndex, userName)),
        centerTitle: false,
        actions: [
          Semantics(
            label: AppStrings.settingsOpenLabel,
            button: true,
            child: IconButton(
              onPressed: () {
                HapticService.light();
                context.push(AppRoutes.settings);
              },
              icon: const Icon(AppIcons.settings, size: 22),
              tooltip: AppStrings.settingsOpenLabel,
            ),
          ),
        ],
      ),
      floatingActionButton: Semantics(
        label: AppStrings.chatbotFabLabel,
        button: true,
        child: FloatingActionButton(
          onPressed: () {
            HapticService.medium();
            context.push(AppRoutes.chatbot);
          },
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(AppIcons.chatFilled, size: 22),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: homeViewModel.pages[homeState.currentIndex]),
        ],
      ),
      bottomNavigationBar: ModernBottomNavBar(
        currentIndex: homeState.currentIndex,
        onTap: homeViewModel.changeNavBar,
      ),
    );
  }
}
