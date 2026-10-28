import 'package:hive/hive.dart';
import '../models/environment_model.dart';

abstract class EnvironmentsLocalDataSource {
  Future<List<EnvironmentModel>> getEnvironments();
  Future<void> saveEnvironment(EnvironmentModel environment);
  Future<void> deleteEnvironment(String id);
  Future<void> selectEnvironment(String? id);
}

class EnvironmentsLocalDataSourceImpl implements EnvironmentsLocalDataSource {
  static const String boxName = 'environments_box';

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  @override
  Future<List<EnvironmentModel>> getEnvironments() async {
    final box = await _getBox();
    if (box.isEmpty) {
      // Seed default Dev and Prod environments
      final dev = const EnvironmentModel(
        id: 'env_dev',
        name: 'Development',
        variables: [
          {'id': 'v1', 'key': 'base_url', 'value': 'https://jsonplaceholder.typicode.com', 'isEnabled': true},
          {'id': 'v2', 'key': 'token', 'value': 'dev_sample_token_123', 'isEnabled': true},
        ],
        isSelected: true,
      );
      final prod = const EnvironmentModel(
        id: 'env_prod',
        name: 'Production',
        variables: [
          {'id': 'v3', 'key': 'base_url', 'value': 'https://jsonplaceholder.typicode.com', 'isEnabled': true},
          {'id': 'v4', 'key': 'token', 'value': 'prod_sample_token_xyz', 'isEnabled': true},
        ],
        isSelected: false,
      );
      await box.add(dev.toMap());
      await box.add(prod.toMap());
    }

    final List<EnvironmentModel> items = [];
    for (int i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw is Map) {
        try {
          items.add(EnvironmentModel.fromMap(raw));
        } catch (_) {}
      }
    }
    return items;
  }

  @override
  Future<void> saveEnvironment(EnvironmentModel environment) async {
    final box = await _getBox();
    int existingIdx = -1;
    for (int i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw is Map && raw['id'] == environment.id) {
        existingIdx = i;
        break;
      }
    }

    if (existingIdx >= 0) {
      await box.putAt(existingIdx, environment.toMap());
    } else {
      await box.add(environment.toMap());
    }
  }

  @override
  Future<void> deleteEnvironment(String id) async {
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
  Future<void> selectEnvironment(String? id) async {
    final box = await _getBox();
    for (int i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw is Map) {
        final isMatch = id != null && raw['id'] == id;
        final updated = Map<String, dynamic>.from(raw)..['isSelected'] = isMatch;
        await box.putAt(i, updated);
      }
    }
  }
}
