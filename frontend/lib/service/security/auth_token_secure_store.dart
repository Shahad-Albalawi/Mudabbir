import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- Persists the Sanctum bearer token in the platform keychain / Keystore.
// Mudabbir uses a single access token (no OAuth refresh_token rotation).
class AuthTokenSecureStore {
  AuthTokenSecureStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  static const _accessTokenKey = 'mudabbir.auth.access_token';

  /// Legacy alias kept for reads during migration from older key names.
  static const _legacyBearerKey = 'mudabbir.auth.bearer_token';

  final FlutterSecureStorage _storage;

  Future<void> writeToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
    await _storage.delete(key: _legacyBearerKey);
  }

  Future<String?> readToken() async {
    final access = await _storage.read(key: _accessTokenKey);
    if (access != null && access.isNotEmpty) {
      return access;
    }

    final legacy = await _storage.read(key: _legacyBearerKey);
    if (legacy != null && legacy.isNotEmpty) {
      await writeToken(legacy);
      return legacy;
    }

    return null;
  }

  /// Alias for [readToken].
  Future<String?> getToken() => readToken();

  Future<void> clearToken() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _legacyBearerKey);
  }
}
