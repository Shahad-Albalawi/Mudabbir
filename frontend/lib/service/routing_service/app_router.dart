import 'package:mudabbir/constants/app_flags.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/presentation/analysis/analysis_view.dart';
import 'package:mudabbir/presentation/budget/budget_view.dart';
import 'package:mudabbir/presentation/chatbot/chatbot_view.dart';
import 'package:mudabbir/presentation/expenses/expenses_view.dart';
import 'package:mudabbir/presentation/home/home_page.dart';
import 'package:mudabbir/presentation/invite/invite_view.dart';
import 'package:mudabbir/presentation/login/login_view.dart';
import 'package:mudabbir/presentation/onboarding/onboarding_view.dart';
import 'package:mudabbir/presentation/register/register_view.dart';
import 'package:mudabbir/presentation/server_challenges/screens/challenge_detail_screen.dart';
import 'package:mudabbir/presentation/server_challenges/screens/challenges_list_screen.dart';
import 'package:mudabbir/presentation/server_challenges/screens/create_challenge_screen.dart';
import 'package:mudabbir/presentation/server_challenges/screens/pending_invitations_screen.dart';
import 'package:mudabbir/presentation/settings/privacy_policy_view.dart';
import 'package:mudabbir/presentation/settings/settings_view.dart';
import 'package:mudabbir/presentation/splash/splash_view.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  /// Single instance — must not recreate on theme/locale rebuild in [MyApp].
  static final GoRouter router = GoRouter(
      navigatorKey: getIt<NavigationService>().navigatorKey,
      refreshListenable: getIt<AuthNotifier>(),
      initialLocation: AppRoutes.splash,
      redirect: (context, state) {
        final hive = getIt<HiveService>();
        final authNotifier = getIt<AuthNotifier>();
        final current = state.matchedLocation;

        if (!authNotifier.isInitialized) {
          return current == AppRoutes.splash ? null : AppRoutes.splash;
        }

        if (current == AppRoutes.splash) {
          final hasSeenOnboarding =
              hive.getValue(HiveConstants.savedFirstTime) == true;
          final isLoggedIn = authNotifier.isLoggedIn;

          if (!hasSeenOnboarding) return AppRoutes.onboarding;
          if (AppFlags.allowGuestHome) return AppRoutes.home;
          if (!isLoggedIn) return AppRoutes.login;
          return AppRoutes.home;
        }

        final hasSeenOnboarding =
            hive.getValue(HiveConstants.savedFirstTime) == true;
        final isLoggedIn = authNotifier.isLoggedIn;

        if (!hasSeenOnboarding && current != AppRoutes.onboarding) {
          return AppRoutes.onboarding;
        }
        if (hasSeenOnboarding &&
            !isLoggedIn &&
            current != AppRoutes.login &&
            current != AppRoutes.register &&
            current != AppRoutes.onboarding) {
          if (!AppFlags.allowGuestHome) return AppRoutes.login;
          // Guest debug mode: browse all screens locally; do not trap on home.
          return null;
        }
        if (isLoggedIn &&
            (current == AppRoutes.login || current == AppRoutes.register)) {
          return AppRoutes.home;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          pageBuilder: (context, state) => _buildSplashPage(const SplashView()),
        ),
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) => _buildPage(const HomePage()),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          pageBuilder: (context, state) => _buildPage(const LoginView()),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: 'register',
          pageBuilder: (context, state) => _buildPage(const RegisterView()),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          name: 'onboarding',
          pageBuilder: (context, state) => _buildPage(const OnboardingView()),
        ),
        GoRoute(
          path: AppRoutes.expenses,
          name: 'expenses',
          pageBuilder: (context, state) => _buildPage(const ExpensesView()),
        ),
        GoRoute(
          path: AppRoutes.chatbot,
          name: 'chatbot',
          pageBuilder: (context, state) => _buildPage(const ChatbotView()),
        ),
        GoRoute(
          path: AppRoutes.budget,
          name: 'budget',
          pageBuilder: (context, state) => _buildPage(BudgetView()),
        ),
        GoRoute(
          path: AppRoutes.analysis,
          name: 'analysis',
          pageBuilder: (context, state) => _buildPage(const AnalysisView()),
        ),
        GoRoute(
          path: AppRoutes.invite,
          name: 'invite',
          pageBuilder: (context, state) => _buildPage(const InviteView()),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          pageBuilder: (context, state) => _buildPage(const SettingsView()),
        ),
        GoRoute(
          path: AppRoutes.privacyPolicy,
          name: 'privacy',
          pageBuilder: (context, state) =>
              _buildPage(const PrivacyPolicyView()),
        ),
        GoRoute(
          path: AppRoutes.challenges,
          name: 'challenges',
          pageBuilder: (context, state) =>
              _buildPage(const ChallengesListScreen()),
          routes: [
            GoRoute(
              path: 'create',
              name: 'challenges-create',
              pageBuilder: (context, state) =>
                  _buildPage(const CreateChallengeScreen()),
            ),
            GoRoute(
              path: 'invitations',
              name: 'challenges-invitations',
              pageBuilder: (context, state) =>
                  _buildPage(const PendingInvitationsScreen()),
            ),
            GoRoute(
              path: ':id',
              name: 'challenge-detail',
              pageBuilder: (context, state) {
                final raw = state.pathParameters['id'];
                final id = int.tryParse(raw ?? '');
                if (id == null) {
                  return _buildPage(const ChallengesListScreen());
                }
                return _buildPage(ChallengeDetailScreen(challengeId: id));
              },
            ),
          ],
        ),
      ],
  );

  static Page<void> _buildSplashPage(Widget child) {
    return CustomTransitionPage<void>(
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
    );
  }

  static Page<void> _buildPage(Widget child) {
    return CustomTransitionPage<void>(
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final begin = Offset(isRtl ? -1.0 : 1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        final fadeTween = Tween<double>(begin: 0.85, end: 1);

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
