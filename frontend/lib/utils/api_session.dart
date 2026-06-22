import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';

/// True when the app has a stored API bearer token (secure storage only).
Future<bool> hasApiSession() async {
  final secure = await getIt<AuthTokenSecureStore>().readToken();
  return secure != null && secure.isNotEmpty;
}
