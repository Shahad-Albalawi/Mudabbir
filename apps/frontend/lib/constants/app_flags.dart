/// Product / routing toggles (single source of truth).
class AppFlags {
  AppFlags._();

  /// When false, GoRouter sends unauthenticated users to [LoginView] instead of home.
  /// Set to true temporarily for emulator screenshots without a backend session.
  static const bool allowGuestHome = true;
}
