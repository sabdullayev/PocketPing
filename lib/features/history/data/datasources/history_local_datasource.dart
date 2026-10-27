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
    for (int i = box.length - 1; i >= 0; i--) {
      final raw = box.getAt(i);
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
    // Add new item
    await box.add(item.toMap());

    // Prune old history if exceeding max count
    if (box.length > maxHistoryCount) {
      final excess = box.length - maxHistoryCount;
      for (int i = 0; i < excess; i++) {
        await box.deleteAt(0);
      }
    }
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    final box = await _getBox();
    for (int i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw is Map && raw['id'] == id) {
        await box.deleteAt(i);
        break;
      }
    }
  }

  @override
  Future<void> clearHistory() async {
    final box = await _getBox();
    await box.clear();
  }
}
