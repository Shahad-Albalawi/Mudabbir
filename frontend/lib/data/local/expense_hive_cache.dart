import 'package:hive/hive.dart';

/// Hive-backed cache for expenses (offline-first reads).
class ExpenseHiveCache {
  static const String boxName = 'expenses_cache_v1';
  static const String expensesListKey = 'expenses_list';
  static const String lastSyncAtKey = 'last_sync_at';
  static const String pendingOpsKey = 'pending_expense_ops';

  Box? _box;

  Future<void> init() async {
    _box ??= await Hive.openBox(boxName);
  }

  Box get box {
    final b = _box;
    if (b == null) {
      throw StateError('ExpenseHiveCache.init() must be called first');
    }
    return b;
  }

  List<Map<String, dynamic>>? getExpensesList() {
    final raw = box.get(expensesListKey);
    if (raw is! List) return null;
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> saveExpensesList(List<Map<String, dynamic>> items) async {
    await box.put(expensesListKey, items);
    await setLastSyncAt(DateTime.now());
  }

  Future<void> upsertExpense(Map<String, dynamic> expense) async {
    final list = List<Map<String, dynamic>>.from(getExpensesList() ?? []);
    final id = expense['id'];
    final index = list.indexWhere((e) => e['id'] == id);
    if (index >= 0) {
      list[index] = expense;
    } else {
      list.insert(0, expense);
    }
    await saveExpensesList(list);
  }

  Future<void> removeExpense(int id) async {
    final list = List<Map<String, dynamic>>.from(getExpensesList() ?? []);
    list.removeWhere((e) => e['id'] == id);
    await saveExpensesList(list);
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
}
