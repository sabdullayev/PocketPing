import '../entities/monitor_target_entity.dart';

abstract class MonitorRepository {
  Future<List<MonitorTargetEntity>> getTargets();
  Future<void> saveTarget(MonitorTargetEntity target);
  Future<void> deleteTarget(String id);
  Future<MonitorTargetEntity> pingTarget(MonitorTargetEntity target);
}
