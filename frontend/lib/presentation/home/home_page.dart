import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/home/home_screen_provider.dart';
import 'package:mudabbir/presentation/home/widgets/ai_wallet_fab.dart';
import 'package:mudabbir/presentation/chatbot/ai_chat_sheet.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/home/widgets/modern_bottom_navbar.dart';
import 'package:mudabbir/presentation/notifications/notifications_provider.dart';
import 'package:mudabbir/presentation/server_challenges/challenge_copy_helpers.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/transactions/add_transaction_sheet.dart';
import 'package:mudabbir/presentation/widgets/shell_app_bar.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
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
      3 => ServerChallengeStrings.listTitle,
      _ => AppStrings.title,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final homeViewModel = ref.read(homeProvider.notifier);
    final homeState = ref.watch(homeProvider);
    final screenState = ref.watch(homeScreenProvider);
    final hive = getIt<HiveService>();
    final userName = screenState.userName.isNotEmpty
        ? screenState.userName
        : _getUserDisplayName(hive);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final isHomeTab = homeState.currentIndex == 0;

    return Scaffold(
      backgroundColor: colors.background,
      extendBody: true,
      appBar: isHomeTab
          ? null
          : ShellAppBar(
              title: _titleForTab(homeState.currentIndex, userName),
              notificationBadgeCount: unreadCount,
            ),
      body: Stack(
        children: [
          homeViewModel.pages[homeState.currentIndex],
          PositionedDirectional(
            start: Spacing.lg,
            bottom: AppLayout.bottomNavClearance - Spacing.xxl,
            child: AiWalletFab(
              onTap: () => AiChatSheet.show(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ModernBottomNavBar(
        currentIndex: homeState.currentIndex,
        onTabSelected: homeViewModel.changeNavBar,
        onFabPressed: () => AddTransactionSheet.show(context),
      ),
    );
  }
}
