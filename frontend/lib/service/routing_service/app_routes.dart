/// Central route paths for [GoRouter].
abstract final class AppRoutes {
  static const splash = '/splash';
  static const home = '/home';
  static const login = '/login';
  static const signup = '/signup';
  static const register = signup;
  static const onboarding = '/onboarding';
  static const landing = '/landing';

  static const expenses = '/expenses';
  static const chatbot = '/chatbot';
  static const budget = '/budget';
  static const analysis = '/analysis';
  static const financialHealth = '/analysis/financial-health';
  static const analysisReport = financialHealth;
  static const invite = '/invite';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const privacyPolicy = '/privacy';
  static const termsOfService = '/terms';

  static const challenges = '/challenges';
  static const challengesCreate = '/challenges/create';
  static const challengesInvitations = '/challenges/invitations';
  static String challengeDetail(int id) => '/challenges/$id';

  static const goals = '/goals';
  static String goalDetail(int id) => '/goals/$id';
}
