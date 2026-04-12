import 'package:mudabbir/constants/app_flags.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/presentation/home/home_page.dart';
import 'package:mudabbir/presentation/login/login_view.dart';
import 'package:mudabbir/presentation/onboarding/onboarding_view.dart';
import 'package:mudabbir/presentation/register/register_view.dart';
import 'package:mudabbir/presentation/splash/splash_view.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter get router {
    return GoRouter(
      navigatorKey: getIt<NavigationService>().navigatorKey,
      refreshListenable: getIt<AuthNotifier>(),
      initialLocation: '/splash',
      redirect: (context, state) {
        final hive = getIt<HiveService>();
        final authNotifier = getIt<AuthNotifier>();
        final current = state.matchedLocation;

        // Show splash while initializing
        if (!authNotifier.isInitialized) {
          return current == '/splash' ? null : '/splash';
        }

        // Still on splash – redirect to main flow
        if (current == '/splash') {
          final hasSeenOnboarding =
              hive.getValue(HiveConstants.savedFirstTime) == true;
          final isLoggedIn = authNotifier.isLoggedIn;

          if (!hasSeenOnboarding) return '/onboarding';
          if (AppFlags.allowGuestHome) return '/';
          if (!isLoggedIn) return '/login';
          return '/';
        }

        final hasSeenOnboarding =
            hive.getValue(HiveConstants.savedFirstTime) == true;
        final isLoggedIn = authNotifier.isLoggedIn;

        if (!hasSeenOnboarding && current != '/onboarding') {
          return '/onboarding';
        }
        if (hasSeenOnboarding &&
            !isLoggedIn &&
            current != '/login' &&
            current != '/register') {
          if (AppFlags.allowGuestHome) return '/';
          return '/login';
        }
        if (isLoggedIn && (current == '/login' || current == '/register')) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          pageBuilder: (context, state) => _buildPage(const SplashView()),
        ),
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) => _buildPage(const HomePage()),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) => _buildPage(LoginView()),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          pageBuilder: (context, state) => _buildPage(RegisterView()),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          pageBuilder: (context, state) => _buildPage(const OnboardingView()),
        ),
      ],
    );
  }

  static Page _buildPage(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        final fadeTween = Tween<double>(begin: 0, end: 1);

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }
}
