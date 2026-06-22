import 'package:hive/hive.dart';

/// Hive-backed cache for server challenges (offline-first reads).
class ChallengeHiveCache {
  static const String boxName = 'challenges_cache_v1';
  static const String challengesListKey = 'challenges_list';
  static const String lastSyncAtKey = 'last_sync_at';
  static const String pendingProgressKey = 'pending_progress_ops';

  Box? _box;

  Future<void> init() async {
    _box ??= await Hive.openBox(boxName);
  }

  Box get box {
    final b = _box;
    if (b == null) {
      throw StateError('ChallengeHiveCache.init() must be called first');
    }
    return b;
  }

  List<Map<String, dynamic>>? getChallengesList() {
    final raw = box.get(challengesListKey);
    if (raw is! List) return null;
    return raw
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> saveChallengesList(List<Map<String, dynamic>> items) async {
    await box.put(challengesListKey, items);
    await setLastSyncAt(DateTime.now());
  }

  Map<String, dynamic>? getChallenge(int id) {
    final list = getChallengesList();
    if (list == null) return null;
    for (final item in list) {
      if (item['id'] == id) return item;
    }
    return null;
  }

  Future<void> upsertChallenge(Map<String, dynamic> challenge) async {
    final list = List<Map<String, dynamic>>.from(getChallengesList() ?? []);
    final id = challenge['id'];
    final index = list.indexWhere((c) => c['id'] == id);
    if (index >= 0) {
      list[index] = challenge;
    } else {
      list.insert(0, challenge);
    }
    await saveChallengesList(list);
  }

  DateTime? getLastSyncAt() {
    final raw = box.get(lastSyncAtKey) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setLastSyncAt(DateTime when) async {
    await box.put(lastSyncAtKey, when.toIso8601String());
  }

  /// Legacy per-challenge progress (migrated from old `myBox` keys).
  double getLocalProgress(int challengeId) {
    return (box.get(_progressKey(challengeId)) as num?)?.toDouble() ?? 0.0;
  }

  Future<void> setLocalProgress(int challengeId, double amount) async {
    await box.put(_progressKey(challengeId), amount);
  }

  String _progressKey(int challengeId) => 'progress_$challengeId';

  List<Map<String, dynamic>> getPendingProgressOps() {
    final raw = box.get(pendingProgressKey);
    if (raw is! List) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> queuePendingProgress({
    required int challengeId,
    required double amount,
    required int userId,
  }) async {
    final ops = getPendingProgressOps()
      ..add({
        'challenge_id': challengeId,
        'user_id': userId,
        'amount': amount,
        'queued_at': DateTime.now().toIso8601String(),
      });
    await box.put(pendingProgressKey, ops);
  }

  Future<void> clearPendingProgressOps() async {
    await box.put(pendingProgressKey, <Map<String, dynamic>>[]);
  }

  Future<void> setPendingProgressOps(List<Map<String, dynamic>> ops) async {
    await box.put(pendingProgressKey, ops);
  }

  /// Migrates `challenge_{id}_current_amount` from the legacy settings box.
  Future<void> migrateLegacyProgress(Map<dynamic, dynamic> legacyBox) async {
    for (final key in legacyBox.keys) {
      if (key is! String || !key.startsWith('challenge_')) continue;
      if (!key.endsWith('_current_amount')) continue;
      final idStr = key
          .replaceFirst('challenge_', '')
          .replaceFirst('_current_amount', '');
      final id = int.tryParse(idStr);
      if (id == null) continue;
      final amount = (legacyBox[key] as num?)?.toDouble() ?? 0.0;
      if (amount > 0 && getLocalProgress(id) <= 0) {
        await setLocalProgress(id, amount);
      }
    }
  }

  Future<void> clearAll() async {
    await box.clear();
  }
}
