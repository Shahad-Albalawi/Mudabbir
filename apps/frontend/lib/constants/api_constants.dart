/// Remote API configuration.
///
/// **Default:** hosted Laravel (`_prodBaseUrl`) for challenges + chatbot.
/// If that host returns errors (e.g. 530), set `API_BASE_URL` to your own API
/// or run a local backend with `USE_LOCAL_API=true`.
///
/// **Local backend** (Android emulator → host port 8000):
/// `flutter run --dart-define=USE_LOCAL_API=true`
///
/// **Custom host:**
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com`
class ApiConstants {
  static const String _prodBaseUrl =
      'https://gemini-api-s-challenges-uvxa39.laravel.cloud';
  static const String _androidEmulatorLocalBaseUrl = 'http://10.0.2.2:8000';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    const useLocalApi = bool.fromEnvironment(
      'USE_LOCAL_API',
      defaultValue: false,
    );
    if (useLocalApi) return _androidEmulatorLocalBaseUrl;
    return _prodBaseUrl;
  }

  /// Same host as [baseUrl] with `/api` — used by Dio (e.g. server challenges).
  static String get apiV1Base =>
      '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/api';

  static final Map<String, String> headers = {};
  static final Map<String, String> userHeaders = {};
}
