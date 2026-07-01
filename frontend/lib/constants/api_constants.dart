import 'dart:io';

import 'package:flutter/foundation.dart';

/// Remote API configuration.
///
/// **Release APK:** URL is set in `frontend/config/release.json` and applied via
/// `scripts/build-release-apk.ps1` or:
/// `flutter build apk --release --dart-define-from-file=config/release.json`
///
/// **Debug / profile:** uses local Laravel on port 8000 by default.
/// Override with `--dart-define=USE_PROD_API=true` or `API_BASE_URL=...`.
class ApiConstants {
  /// Default timeout for all API calls (connect + receive).
  static const Duration defaultTimeout = Duration(seconds: 10);

  static const String _prodBaseUrl =
      'https://mudabbir-backend-api.onrender.com';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    const useProdApi = bool.fromEnvironment(
      'USE_PROD_API',
      defaultValue: false,
    );
    if (useProdApi) return _prodBaseUrl;

    const forceLocal = bool.fromEnvironment('USE_LOCAL_API');
    if (kDebugMode || kProfileMode || forceLocal) {
      return _localDevBaseUrl;
    }

    return _prodBaseUrl;
  }

  /// Android emulator → host machine. iOS simulator / desktop → localhost.
  static String get _localDevBaseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  /// Same host as [baseUrl] with `/api` — used by Dio (e.g. server challenges).
  static String get apiV1Base =>
      '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/api';

  static final Map<String, String> headers = {};
  static final Map<String, String> userHeaders = {};
}
