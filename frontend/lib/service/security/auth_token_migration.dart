import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';
import 'package:mudabbir/utils/dev_log.dart';

/// One-time migration: move any legacy Hive bearer token into secure storage.
class AuthTokenMigration {
  AuthTokenMigration._();

  static Future<void> run({
    required HiveService hiveService,
    required AuthTokenSecureStore secureStore,
  }) async {
    final legacy = hiveService.getValue(HiveConstants.savedToken);
    if (legacy is! String || legacy.isEmpty) {
      return;
    }

    final current = await secureStore.readToken();
    if (current == null || current.isEmpty) {
      await secureStore.writeToken(legacy);
      devLog('[Auth] Migrated legacy Hive token to secure storage.');
    }

    await hiveService.deleteValue(HiveConstants.savedToken);
  }
}
