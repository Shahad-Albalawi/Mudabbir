import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/persentation/chatbot/chatbot_view.dart';
import 'package:mudabbir/persentation/home/home_viewmodel.dart';
import 'package:mudabbir/persentation/home/widgets/modern_bottom_navbar.dart';
import 'package:mudabbir/persentation/resources/color_manager.dart';
import 'package:mudabbir/persentation/resources/modern_gradient_appbar.dart';
import 'package:mudabbir/persentation/resources/strings_manager.dart';
import 'package:mudabbir/persentation/resources/values_manager.dart';
import 'package:mudabbir/persentation/widgets/ios_pressable.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  /// Safely gets user display name from Hive, with fallback.
  String _getUserDisplayName(HiveService hive) {
    try {
      final userInfo = hive.getValue(HiveConstants.savedUserInfo);
      if (userInfo is Map && userInfo['name'] != null) {
        return userInfo['name'].toString();
      }
    } catch (_) {
      // Fallback on unexpected data
    }
    return '';
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
          children: [
            Container(
              padding: const EdgeInsets.all(AppPadding.p8),
              decoration: BoxDecoration(
                color: ColorManager.primaryWithOpacity12,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                CupertinoIcons.creditcard_fill,
                color: ColorManager.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSize.s12),
            Flexible(
              child: Text(
                userName.isEmpty
                    ? AppStrings.title
                    : '${AppStrings.title} - $userName',
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () async {
              await getIt<AuthNotifier>().didLogout();
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: AppStrings.logout,
          ),
        ],
      ),
      floatingActionButton: IOSPressable(
        onTap: () {
          HapticService.medium();
          getIt<NavigationService>().navigate(ChatbotView());
        },
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: ColorManager.primaryWithOpacity25,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: null,
            backgroundColor: ColorManager.primary,
            elevation: 0,
            child: const Icon(CupertinoIcons.chat_bubble_2_fill, size: 26),
          ),
        ),
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
