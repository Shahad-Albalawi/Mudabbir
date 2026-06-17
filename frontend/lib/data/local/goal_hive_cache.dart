import 'package:hive/hive.dart';

/// Hive-backed cache for savings goals (offline-first reads).
class GoalHiveCache {
  static const String boxName = 'goals_cache_v1';
  static const String goalsListKey = 'goals_list';
  static const String lastSyncAtKey = 'last_sync_at';
  static const String pendingOpsKey = 'pending_goal_ops';

  Box? _box;

  Future<void> init() async {
    _box ??= await Hive.openBox(boxName);
  }

  Box get box {
    final b = _box;
    if (b == null) {
      throw StateError('GoalHiveCache.init() must be called first');
    }
    return b;
  }

  List<Map<String, dynamic>>? getGoalsList() {
    final raw = box.get(goalsListKey);
    if (raw is! List) return null;
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> saveGoalsList(List<Map<String, dynamic>> items) async {
    await box.put(goalsListKey, items);
    await setLastSyncAt(DateTime.now());
  }

  Future<void> upsertGoal(Map<String, dynamic> goal) async {
    final list = List<Map<String, dynamic>>.from(getGoalsList() ?? []);
    final id = goal['id'];
    final index = list.indexWhere((g) => g['id'] == id);
    if (index >= 0) {
      list[index] = goal;
    } else {
      list.insert(0, goal);
    }
    await saveGoalsList(list);
  }

  Future<void> removeGoal(int id) async {
    final list = List<Map<String, dynamic>>.from(getGoalsList() ?? []);
    list.removeWhere((g) => g['id'] == id);
    await saveGoalsList(list);
  }

  DateTime? getLastSyncAt() {
    final raw = box.get(lastSyncAtKey) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setLastSyncAt(DateTime when) async {
    await box.put(lastSyncAtKey, when.toIso8601String());
  }

  List<Map<String, dynamic>> getPendingOps() {
    final raw = box.get(pendingOpsKey);
    if (raw is! List) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> queueOp(Map<String, dynamic> op) async {
    final ops = getPendingOps()..add(op);
    await box.put(pendingOpsKey, ops);
  }

  Future<void> setPendingOps(List<Map<String, dynamic>> ops) async {
    await box.put(pendingOpsKey, ops);
  }

  Future<void> clearAll() async {
    await box.clear();
  }
}
