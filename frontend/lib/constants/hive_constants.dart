class HiveConstants {
  static const String prefsBox = 'prefs';
  static const String onboardingSeenKey = 'onboarding_seen';

  static final String savedToken = 'savedToken';
  static final String savedFirstTime = 'firstTime';
  static final String savedUserInfo = 'userInfo';

  /// Optional: when set on [savedUserInfo] map, opens this SQLite profile (`guest_user`, etc.).
  static const String userInfoLocalDbKey = 'local_db_user';
}
