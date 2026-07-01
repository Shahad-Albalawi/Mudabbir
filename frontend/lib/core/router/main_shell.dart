import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/presentation/chatbot/ai_chat_sheet.dart';
import 'package:mudabbir/presentation/home/home_screen_provider.dart';
import 'package:mudabbir/presentation/home/widgets/ai_wallet_fab.dart';
import 'package:mudabbir/presentation/home/widgets/modern_bottom_navbar.dart';
import 'package:mudabbir/presentation/notifications/notifications_provider.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/server_challenges/challenge_copy_helpers.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/transactions/add_transaction_sheet.dart';
import 'package:mudabbir/presentation/widgets/shell_app_bar.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';
import 'package:mudabbir/utils/user_display_name.dart';

/// Bottom-nav shell for main tabs — `/home`, `/analysis`, `/goals`, `/challenges`.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _tabRoutes = [
    AppRoutes.home,
    AppRoutes.analysis,
    AppRoutes.goals,
    AppRoutes.challenges,
  ];

  static int _indexForLocation(String location) {
    if (location.startsWith(AppRoutes.analysis)) return 1;
    if (location.startsWith(AppRoutes.goals)) return 2;
    if (location.startsWith(AppRoutes.challenges)) return 3;
    return 0;
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
    final location = GoRouterState.of(context).matchedLocation;
    final tabIndex = _indexForLocation(location);
    final isHomeTab = tabIndex == 0;

    final hive = getIt<HiveService>();
    final screenState = ref.watch(homeScreenProvider);
    final userName = screenState.userName.isNotEmpty
        ? screenState.userName
        : UserDisplayName.fromSavedUserInfo(
            hive.getValue(HiveConstants.savedUserInfo),
          );
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: colors.background,
      extendBody: true,
      appBar: isHomeTab
          ? null
          : ShellAppBar(
              title: _titleForTab(tabIndex, userName),
              notificationBadgeCount: unreadCount,
            ),
      body: Stack(
        children: [
          child,
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
        currentIndex: tabIndex,
        onTabSelected: (index) => context.go(_tabRoutes[index]),
        onFabPressed: () => AddTransactionSheet.show(context),
      ),
    );
  }
}
