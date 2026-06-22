import 'package:hive/hive.dart';

/// Hive-backed cache for budgets (offline-first reads).
class BudgetHiveCache {
  static const String boxName = 'budgets_cache_v1';
  static const String budgetsListKey = 'budgets_list';
  static const String lastSyncAtKey = 'last_sync_at';
  static const String pendingOpsKey = 'pending_budget_ops';

  Box? _box;

  Future<void> init() async {
    _box ??= await Hive.openBox(boxName);
  }

  Box get box {
    final b = _box;
    if (b == null) {
      throw StateError('BudgetHiveCache.init() must be called first');
    }
    return b;
  }

  List<Map<String, dynamic>>? getBudgetsList() {
    final raw = box.get(budgetsListKey);
    if (raw is! List) return null;
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> saveBudgetsList(List<Map<String, dynamic>> items) async {
    await box.put(budgetsListKey, items);
    await setLastSyncAt(DateTime.now());
  }

  Future<void> upsertBudget(Map<String, dynamic> budget) async {
    final list = List<Map<String, dynamic>>.from(getBudgetsList() ?? []);
    final id = budget['id'];
    final index = list.indexWhere((b) => b['id'] == id);
    if (index >= 0) {
      list[index] = budget;
    } else {
      list.insert(0, budget);
    }
    await saveBudgetsList(list);
  }

  Future<void> removeBudget(int id) async {
    final list = List<Map<String, dynamic>>.from(getBudgetsList() ?? []);
    list.removeWhere((b) => b['id'] == id);
    await saveBudgetsList(list);
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
