import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import '../network/dio_client.dart';
import 'notification_service.dart';
import '../../features/monitor/data/datasources/monitor_local_datasource.dart';
import '../../features/monitor/data/models/monitor_target_model.dart';
import '../../features/request_builder/domain/entities/http_method.dart';
import '../../features/request_builder/domain/entities/http_request_entity.dart';

const String healthCheckTaskName = 'com.pocketping.periodic_health_check';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Hive.initFlutter();
      final box = await Hive.openBox(MonitorLocalDataSourceImpl.boxName);
      final dioClient = DioClient();

      for (int i = 0; i < box.length; i++) {
        final raw = box.getAt(i);
        if (raw is Map) {
          final target = MonitorTargetModel.fromMap(raw);
          if (target.isEnabled) {
            final request = HttpRequestEntity(
              method: HttpMethod.get,
              url: target.url,
            );
            final response = await dioClient.execute(request);
            final isHealthy = response.statusCode == 200;

            final updated = target.toEntity().copyWith(
              lastCheckedAt: DateTime.now(),
              lastStatusCode: response.statusCode,
              lastDurationMs: response.durationMs,
              isHealthy: isHealthy,
              errorMessage: isHealthy ? null : (response.errorMessage ?? response.statusMessage),
            );

            await box.putAt(i, MonitorTargetModel.fromEntity(updated).toMap());

            if (!isHealthy) {
              await NotificationService.instance.showServerDownAlert(
                serverName: target.name,
                url: target.url,
                statusCode: response.statusCode,
                error: response.errorMessage ?? response.statusMessage,
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Background health check error: $e');
    }
    return Future.value(true);
  });
}

class BackgroundPingService {
  BackgroundPingService._();

  static Future<void> initialize() async {
    // Workmanager is supported on Android and iOS
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await Workmanager().initialize(
          callbackDispatcher,
        );

        await Workmanager().registerPeriodicTask(
          'pocketping_health_check',
          healthCheckTaskName,
          frequency: const Duration(minutes: 15),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
        );
      } catch (e) {
        debugPrint('Workmanager init failed: $e');
      }
    }
  }
}
