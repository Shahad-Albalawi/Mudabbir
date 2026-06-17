import 'package:mudabbir/constants/hive_constants.dart';

/// Stable SQLite file key for the current session (not the display name).
String resolveLocalDbUserId(dynamic savedUserInfo) {
  if (savedUserInfo is Map) {
    final fromKey =
        savedUserInfo[HiveConstants.userInfoLocalDbKey]?.toString().trim();
    if (fromKey != null && fromKey.isNotEmpty) return fromKey;
    final name = savedUserInfo['name']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
  }
  return 'guest_user';
}
