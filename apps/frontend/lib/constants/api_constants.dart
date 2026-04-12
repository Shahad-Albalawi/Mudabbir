import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _prodBaseUrl =
      'https://gemini-api-s-challenges-uvxa39.laravel.cloud';
  static const String _androidEmulatorLocalBaseUrl = 'http://10.0.2.2:8000';

  // In debug mode on Android emulator, point to local Laravel backend.
  static final String baseUrl = kReleaseMode
      ? _prodBaseUrl
      : const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: _androidEmulatorLocalBaseUrl,
        );

  static final Map<String, String> headers = {};
  static final Map<String, String> userHeaders = {};
}
