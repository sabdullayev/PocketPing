import '../../../../core/network/dio_client.dart';
import '../../../../core/services/notification_service.dart';
import '../../../request_builder/domain/entities/http_method.dart';
import '../../../request_builder/domain/entities/http_request_entity.dart';
import '../../domain/entities/monitor_target_entity.dart';
import '../../domain/repositories/monitor_repository.dart';
import '../datasources/monitor_local_datasource.dart';
import '../models/monitor_target_model.dart';

class MonitorRepositoryImpl implements MonitorRepository {
  final MonitorLocalDataSource localDataSource;
  final DioClient dioClient;

  MonitorRepositoryImpl({
    required this.localDataSource,
    required this.dioClient,
  });

  @override
  Future<List<MonitorTargetEntity>> getTargets() async {
    final models = await localDataSource.getTargets();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveTarget(MonitorTargetEntity target) async {
    final model = MonitorTargetModel.fromEntity(target);
    await localDataSource.saveTarget(model);
  }

  @override
  Future<void> deleteTarget(String id) async {
    await localDataSource.deleteTarget(id);
  }

  @override
  Future<MonitorTargetEntity> pingTarget(MonitorTargetEntity target) async {
    final request = HttpRequestEntity(
      method: HttpMethod.get,
      url: target.url,
    );

    final response = await dioClient.execute(request);
    final isHealthy = response.statusCode == 200;

    final updated = target.copyWith(
      lastCheckedAt: DateTime.now(),
      lastStatusCode: response.statusCode,
      lastDurationMs: response.durationMs,
      isHealthy: isHealthy,
      errorMessage: isHealthy ? null : (response.errorMessage ?? response.statusMessage),
    );

    // If server is down / not 200 OK, send loud alert notification
    if (!isHealthy) {
      try {
        await NotificationService.instance.showServerDownAlert(
          serverName: target.name,
          url: target.url,
          statusCode: response.statusCode,
          error: response.errorMessage ?? response.statusMessage,
        );
      } catch (_) {}
    }

    await saveTarget(updated);
    return updated;
  }
}
