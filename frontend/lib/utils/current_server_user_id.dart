import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';

/// Reads the authenticated Laravel user id persisted after login/register.
int? tryCurrentServerUserId() {
  final raw = getIt<HiveService>().getValue(HiveConstants.savedUserInfo);
  if (raw is! Map) return null;
  final id = raw['id'];
  if (id is int) return id;
  if (id is num) return id.toInt();
  return null;
}

String? tryCurrentServerUserEmail() {
  final raw = getIt<HiveService>().getValue(HiveConstants.savedUserInfo);
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
