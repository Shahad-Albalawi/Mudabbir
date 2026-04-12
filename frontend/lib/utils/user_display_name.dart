/// Display-only name from Hive `savedUserInfo` (never used for DB paths).
class UserDisplayName {
  UserDisplayName._();

  /// Returns a trimmed name, or empty if missing / placeholder (e.g. old «معاينة»).
  static String fromSavedUserInfo(dynamic userInfo) {
    if (userInfo is! Map) return '';
    final raw = userInfo['name'];
    if (raw == null) return '';
    return sanitize(raw.toString());
  }

  static String sanitize(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '';
    final lower = t.toLowerCase();
    if (lower == 'preview' || lower == 'demo') return '';
    // Arabic «معاينة» / «معاينه» and common variants
    if (t.contains('معاين')) return '';
    return t;
  }
}
