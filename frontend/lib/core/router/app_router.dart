import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/core/router/app_screens.dart';
import 'package:mudabbir/core/router/main_shell.dart';
import 'package:mudabbir/features/auth/login_screen.dart';
import 'package:mudabbir/features/onboarding/onboarding_screen.dart';
import 'package:mudabbir/features/splash/splash_screen.dart';
import 'package:mudabbir/presentation/goals/goal_detail_screen.dart';
import 'package:mudabbir/presentation/home/home_screen.dart';
import 'package:mudabbir/presentation/notifications/notifications_screen.dart';
import 'package:mudabbir/presentation/screens/chatbot_screen.dart';
import 'package:mudabbir/presentation/server_challenges/screens/challenge_detail_screen.dart';
import 'package:mudabbir/presentation/server_challenges/screens/create_challenge_screen.dart';
import 'package:mudabbir/presentation/server_challenges/screens/pending_invitations_screen.dart';
import 'package:mudabbir/presentation/settings/privacy_policy_view.dart';
import 'package:mudabbir/presentation/settings/terms_of_service_view.dart';
import 'package:mudabbir/presentation/web/landing_page.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(RouterRef ref) {
  return GoRouter(
    navigatorKey: getIt<NavigationService>().navigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.landing,
        builder: (_, __) => const LandingPage(),
      ),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.analysis,
            builder: (_, __) => const AnalysisScreen(),
          ),
          GoRoute(
            path: AppRoutes.goals,
            builder: (_, __) => const GoalsScreen(),
          ),
          GoRoute(
            path: AppRoutes.challenges,
            builder: (_, __) => const ChallengesScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.expenses,
        builder: (_, __) => const ExpensesScreen(),
      ),
      GoRoute(
        path: AppRoutes.budget,
        builder: (_, __) => const BudgetScreen(),
      ),
      GoRoute(
        path: AppRoutes.chatbot,
        builder: (_, __) => const ChatbotScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (_, __) => const PrivacyPolicyView(),
      ),
      GoRoute(
        path: AppRoutes.termsOfService,
        builder: (_, __) => const TermsOfServiceView(),
      ),
      GoRoute(
        path: AppRoutes.financialHealth,
        builder: (_, __) => const FinancialHealthScreen(),
      ),
      GoRoute(
        path: AppRoutes.challengesCreate,
        builder: (_, __) => const CreateChallengeScreen(),
      ),
      GoRoute(
        path: AppRoutes.challengesInvitations,
        builder: (_, __) => const PendingInvitationsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.challenges}/:id',
        builder: (context, state) {
          final id = routePathId(state.pathParameters['id']);
          if (id == null) {
            return _invalidRouteFallback(context, AppRoutes.challenges);
          }
          return ChallengeDetailScreen(challengeId: id);
        },
      ),
      GoRoute(
        path: '${AppRoutes.goals}/:id',
        builder: (context, state) {
          final id = routePathId(state.pathParameters['id']);
          if (id == null) {
            return _invalidRouteFallback(context, AppRoutes.goals);
          }
          return GoalDetailScreen(goalId: id);
        },
      ),
    ],
  );
}

/// Invalid `:id` — redirect to parent list instead of a broken screen.
Widget _invalidRouteFallback(BuildContext context, String fallbackRoute) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) {
      context.go(fallbackRoute);
    }
  });
  return const SizedBox.shrink();
}
