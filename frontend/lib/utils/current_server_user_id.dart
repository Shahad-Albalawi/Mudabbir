import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/core/providers/app_providers.dart';
import 'package:mudabbir/core/providers/provider_reader.dart';

/// Reads the authenticated Laravel user id persisted after login/register.
int? tryCurrentServerUserId() {
  final raw = readApp(hiveServiceProvider).getValue(HiveConstants.savedUserInfo);
  if (raw is! Map) return null;
  final id = raw['id'];
  if (id is int) return id;
  if (id is num) return id.toInt();
  return null;
}

String? tryCurrentServerUserEmail() {
  final raw = readApp(hiveServiceProvider).getValue(HiveConstants.savedUserInfo);
  if (raw is! Map) return null;
  final email = raw['email'];
  return email is String ? email : null;
}

int requireCurrentServerUserId() {
  final id = tryCurrentServerUserId();
  if (id == null) {
    throw StateError('No server user id in savedUserInfo');
  }
  return id;
}
