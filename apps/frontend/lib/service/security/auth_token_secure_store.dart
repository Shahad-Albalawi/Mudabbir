import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- Persists the auth bearer token in the platform keychain / Keystore.
// Hive keeps a copy for fast Dio reads; this is the durable encrypted backup.
class AuthTokenSecureStore {
  AuthTokenSecureStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'mudabbir.auth.bearer_token';

  final FlutterSecureStorage _storage;

  Future<void> writeToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  Future<String?> readToken() async => _storage.read(key: _key);

  Future<void> clearToken() async => _storage.delete(key: _key);
}
