import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/presentation/chatbot/chatbot_view.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/home/widgets/modern_bottom_navbar.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/modern_gradient_appbar.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/resources/values_manager.dart';
import 'package:mudabbir/presentation/widgets/ios_pressable.dart';
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
