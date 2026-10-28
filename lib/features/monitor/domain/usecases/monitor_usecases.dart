import '../entities/monitor_target_entity.dart';
import '../repositories/monitor_repository.dart';

class GetMonitorTargetsUseCase {
  final MonitorRepository repository;
  GetMonitorTargetsUseCase(this.repository);

  Future<List<MonitorTargetEntity>> call() => repository.getTargets();
}

class SaveMonitorTargetUseCase {
  final MonitorRepository repository;
  SaveMonitorTargetUseCase(this.repository);

  Future<void> call(MonitorTargetEntity target) => repository.saveTarget(target);
}

class DeleteMonitorTargetUseCase {
  final MonitorRepository repository;
  DeleteMonitorTargetUseCase(this.repository);

  Future<void> call(String id) => repository.deleteTarget(id);
}

class PingTargetUseCase {
  final MonitorRepository repository;
  PingTargetUseCase(this.repository);

  Future<MonitorTargetEntity> call(MonitorTargetEntity target) => repository.pingTarget(target);
}
