import 'package:flutter/foundation.dart';

/// Remote API configuration.
///
/// **Release APK:** URL is set in `frontend/config/release.json` and applied via
/// `scripts/build-release-apk.ps1` or:
/// `flutter build apk --release --dart-define-from-file=config/release.json`
///
/// **Default production host** (Laravel Cloud). Override at build time with
/// `--dart-define=API_BASE_URL=https://your-api.example.com` if you deploy elsewhere
/// (e.g. Render — see `docs/DEPLOY_RENDER.md`).
///
/// **Local backend** (Android emulator → host port 8000):
/// `flutter run --dart-define=USE_LOCAL_API=true`
class ApiConstants {
  static const String _prodBaseUrl =
      'https://mudabbir-backend-api.onrender.com';
  static const String _androidEmulatorLocalBaseUrl = 'http://10.0.2.2:8000';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    const useLocalApi = bool.fromEnvironment(
      'USE_LOCAL_API',
      defaultValue: false,
    );
    const forceProd = bool.fromEnvironment(
      'FORCE_PROD_API',
      defaultValue: false,
    );
    if (useLocalApi || (kDebugMode && !forceProd)) {
      return _androidEmulatorLocalBaseUrl;
    }
    return _prodBaseUrl;
  }

  /// Same host as [baseUrl] with `/api` — used by Dio (e.g. server challenges).
  static String get apiV1Base =>
      '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/api';

  static final Map<String, String> headers = {};
  static final Map<String, String> userHeaders = {};
}
