import 'package:flutter/foundation.dart';

/// Product / routing toggles (single source of truth).
class AppFlags {
  AppFlags._();

  /// Release builds: require sign-in (no guest DB / home without session).
  /// Debug & profile: allow opening home without login (faster emulator UX).
  static bool get allowGuestHome => !kReleaseMode;

  /// Sample transactions/goals in empty local DB — debug/profile only (not store builds).
  static bool get enableDemoSeed => !kReleaseMode;
}
