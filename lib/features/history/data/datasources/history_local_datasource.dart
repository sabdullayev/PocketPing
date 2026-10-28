import 'package:hive/hive.dart';
import '../models/history_item_model.dart';

abstract class HistoryLocalDataSource {
  Future<List<HistoryItemModel>> getHistory();
  Future<void> saveHistoryItem(HistoryItemModel item);
  Future<void> deleteHistoryItem(String id);
  Future<void> clearHistory();
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  static const String boxName = 'history_box';
  static const int maxHistoryCount = 100;

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  @override
  Future<List<HistoryItemModel>> getHistory() async {
    final box = await _getBox();
    final List<HistoryItemModel> items = [];
    final values = box.values.toList();
    for (int i = values.length - 1; i >= 0; i--) {
      final raw = values[i];
      if (raw is Map) {
        try {
          items.add(HistoryItemModel.fromMap(raw));
        } catch (_) {}
      }
    }
    return items;
  }

  @override
  Future<void> saveHistoryItem(HistoryItemModel item) async {
    final box = await _getBox();
    // Use put with unique id so duplicate calls are idempotent
    await box.put(item.id, item.toMap());

    // Prune old history if exceeding max count
    if (box.length > maxHistoryCount) {
      final excess = box.length - maxHistoryCount;
      final keys = box.keys.take(excess).toList();
      for (final key in keys) {
        await box.delete(key);
      }
    }
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    final box = await _getBox();
    if (box.containsKey(id)) {
      await box.delete(id);
    } else {
      // Fallback for any legacy entries keyed by index
      for (final key in box.keys) {
        final val = box.get(key);
        if (val is Map && val['id'] == id) {
          await box.delete(key);
          break;
        }
      }
    }
  }

  @override
  Future<void> clearHistory() async {
    final box = await _getBox();
    await box.clear();
  }
}
