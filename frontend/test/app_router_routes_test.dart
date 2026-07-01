import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/core/router/app_router.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    getIt.registerSingleton<NavigationService>(NavigationService());
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('GoRouter matches AppRoutes', () {
    test('router resolves every primary AppRoutes path', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);

      final paths = <String>[
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.signup,
        AppRoutes.landing,
        AppRoutes.home,
        AppRoutes.analysis,
        AppRoutes.goals,
        AppRoutes.challenges,
        AppRoutes.expenses,
        AppRoutes.budget,
        AppRoutes.chatbot,
        AppRoutes.settings,
        AppRoutes.notifications,
        AppRoutes.privacyPolicy,
        AppRoutes.termsOfService,
        AppRoutes.financialHealth,
        AppRoutes.challengesCreate,
        AppRoutes.challengesInvitations,
        AppRoutes.goalDetail(1),
        AppRoutes.challengeDetail(2),
      ];

      for (final path in paths) {
        final match = router.configuration.findMatch(Uri.parse(path));
        expect(
          match.isNotEmpty,
          isTrue,
          reason: 'No GoRoute registered for $path',
        );
      }
    });
  });
}
