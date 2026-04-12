import 'package:hive/hive.dart';

class HiveService {
  final String _boxName = 'myBox';
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  dynamic getValue(String key) => _box.get(key);

  Future<void> setValue(String key, dynamic value) async {
    await _box.put(key, value);
  }

  Future<void> deleteValue(String key) async {
    await _box.delete(key);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
