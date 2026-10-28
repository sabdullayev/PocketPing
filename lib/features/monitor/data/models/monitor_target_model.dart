import '../../domain/entities/monitor_target_entity.dart';

class MonitorTargetModel {
  final String id;
  final String name;
  final String url;
  final int intervalMinutes;
  final bool isEnabled;
  final String? lastCheckedAt;
  final int? lastStatusCode;
  final int? lastDurationMs;
  final bool? isHealthy;
  final String? errorMessage;

  const MonitorTargetModel({
    required this.id,
    required this.name,
    required this.url,
    required this.intervalMinutes,
    required this.isEnabled,
    this.lastCheckedAt,
    this.lastStatusCode,
    this.lastDurationMs,
    this.isHealthy,
    this.errorMessage,
  });

  factory MonitorTargetModel.fromEntity(MonitorTargetEntity entity) {
    return MonitorTargetModel(
      id: entity.id,
      name: entity.name,
      url: entity.url,
      intervalMinutes: entity.intervalMinutes,
      isEnabled: entity.isEnabled,
      lastCheckedAt: entity.lastCheckedAt?.toIso8601String(),
      lastStatusCode: entity.lastStatusCode,
      lastDurationMs: entity.lastDurationMs,
      isHealthy: entity.isHealthy,
      errorMessage: entity.errorMessage,
    );
  }

  MonitorTargetEntity toEntity() {
    return MonitorTargetEntity.raw(
      id: id,
      name: name,
      url: url,
      intervalMinutes: intervalMinutes,
      isEnabled: isEnabled,
      lastCheckedAt: lastCheckedAt != null ? DateTime.tryParse(lastCheckedAt!) : null,
      lastStatusCode: lastStatusCode,
      lastDurationMs: lastDurationMs,
      isHealthy: isHealthy,
      errorMessage: errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'intervalMinutes': intervalMinutes,
      'isEnabled': isEnabled,
      'lastCheckedAt': lastCheckedAt,
      'lastStatusCode': lastStatusCode,
      'lastDurationMs': lastDurationMs,
      'isHealthy': isHealthy,
      'errorMessage': errorMessage,
    };
  }

  factory MonitorTargetModel.fromMap(Map<dynamic, dynamic> map) {
    return MonitorTargetModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      url: map['url']?.toString() ?? '',
      intervalMinutes: (map['intervalMinutes'] as num?)?.toInt() ?? 15,
      isEnabled: map['isEnabled'] == true,
      lastCheckedAt: map['lastCheckedAt']?.toString(),
      lastStatusCode: (map['lastStatusCode'] as num?)?.toInt(),
      lastDurationMs: (map['lastDurationMs'] as num?)?.toInt(),
      isHealthy: map['isHealthy'] as bool?,
      errorMessage: map['errorMessage']?.toString(),
    );
  }
}
