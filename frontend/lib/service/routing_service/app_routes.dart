/// Central route paths for [GoRouter].
abstract final class AppRoutes {
  static const splash = '/splash';
  static const home = '/';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';

  static const expenses = '/expenses';
  static const chatbot = '/chatbot';
  static const budget = '/budget';
  static const analysis = '/analysis';
  static const invite = '/invite';
  static const settings = '/settings';
  static const privacyPolicy = '/privacy';

  static const challenges = '/challenges';
  static const challengesCreate = '/challenges/create';
  static const challengesInvitations = '/challenges/invitations';
  static String challengeDetail(int id) => '/challenges/$id';
}
