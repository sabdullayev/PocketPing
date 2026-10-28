import 'package:hive/hive.dart';
import '../models/monitor_target_model.dart';

abstract class MonitorLocalDataSource {
  Future<List<MonitorTargetModel>> getTargets();
  Future<void> saveTarget(MonitorTargetModel target);
  Future<void> deleteTarget(String id);
}

class MonitorLocalDataSourceImpl implements MonitorLocalDataSource {
  static const String boxName = 'monitor_box';

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  @override
  Future<List<MonitorTargetModel>> getTargets() async {
    final box = await _getBox();
    final List<MonitorTargetModel> items = [];
    for (int i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw is Map) {
        try {
          items.add(MonitorTargetModel.fromMap(raw));
        } catch (_) {}
      }
    }
    return items;
  }

  @override
  Future<void> saveTarget(MonitorTargetModel target) async {
    final box = await _getBox();
    int existingIdx = -1;
    for (int i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw is Map && raw['id'] == target.id) {
        existingIdx = i;
        break;
      }
    }

    if (existingIdx >= 0) {
      await box.putAt(existingIdx, target.toMap());
    } else {
      await box.add(target.toMap());
    }
  }

  @override
  Future<void> deleteTarget(String id) async {
    final box = await _getBox();
    for (int i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw is Map && raw['id'] == id) {
        await box.deleteAt(i);
        break;
      }
    }
  }
}
