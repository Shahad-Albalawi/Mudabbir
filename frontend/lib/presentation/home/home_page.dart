import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/presentation/chatbot/chatbot_view.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/home/widgets/modern_bottom_navbar.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/modern_gradient_appbar.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_brand_logo.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import 'package:mudabbir/utils/user_display_name.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  /// Display name from Hive; strips legacy placeholder labels (e.g. preview).
  String _getUserDisplayName(HiveService hive) {
    try {
      return UserDisplayName.fromSavedUserInfo(
        hive.getValue(HiveConstants.savedUserInfo),
      );
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final homeViewModel = ref.read(homeProvider.notifier);
    final homeState = ref.watch(homeProvider);
    final hive = getIt<HiveService>();
    final userName = _getUserDisplayName(hive);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: ModernGradientAppBar(
        showBackButton: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppBrandLogo(height: 26),
            if (userName.isNotEmpty) ...[
              const SizedBox(width: 10),
              Text(
                userName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.homeGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () async {
              await getIt<AuthNotifier>().didLogout();
            },
            icon: const Icon(CupertinoIcons.square_arrow_right),
            tooltip: AppStrings.logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticService.medium();
          getIt<NavigationService>().navigate(ChatbotView());
        },
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 1,
        child: const Icon(CupertinoIcons.chat_bubble, size: 22),
      ),
      body: homeViewModel.pages[homeState.currentIndex],
      bottomNavigationBar: ModernBottomNavBar(
        currentIndex: homeState.currentIndex,
        onTap: (value) {
          homeViewModel.changeNavBar(value);
        },
      ),
    );
  }
}
