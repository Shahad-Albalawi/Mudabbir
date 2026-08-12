import 'package:mudabbir/core/providers/app_providers.dart';
import 'package:mudabbir/core/providers/provider_reader.dart';

/// True when the app has a stored API bearer token (secure storage only).
Future<bool> hasApiSession() async {
  final secure = await readApp(authTokenSecureStoreProvider).readToken();
  return secure != null && secure.isNotEmpty;
}
