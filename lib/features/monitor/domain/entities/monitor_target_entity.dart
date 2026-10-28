import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class MonitorTargetEntity extends Equatable {
  final String id;
  final String name;
  final String url;
  final int intervalMinutes;
  final bool isEnabled;
  final DateTime? lastCheckedAt;
  final int? lastStatusCode;
  final int? lastDurationMs;
  final bool? isHealthy;
  final String? errorMessage;

  MonitorTargetEntity({
    String? id,
    required this.name,
    required this.url,
    this.intervalMinutes = 15,
    this.isEnabled = true,
    this.lastCheckedAt,
    this.lastStatusCode,
    this.lastDurationMs,
    this.isHealthy,
    this.errorMessage,
  }) : id = id ?? const Uuid().v4();

  const MonitorTargetEntity.raw({
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

  MonitorTargetEntity copyWith({
    String? id,
    String? name,
    String? url,
    int? intervalMinutes,
    bool? isEnabled,
    DateTime? lastCheckedAt,
    int? lastStatusCode,
    int? lastDurationMs,
    bool? isHealthy,
    String? errorMessage,
  }) {
    return MonitorTargetEntity.raw(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      isEnabled: isEnabled ?? this.isEnabled,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastStatusCode: lastStatusCode ?? this.lastStatusCode,
      lastDurationMs: lastDurationMs ?? this.lastDurationMs,
      isHealthy: isHealthy ?? this.isHealthy,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        url,
        intervalMinutes,
        isEnabled,
        lastCheckedAt,
        lastStatusCode,
        lastDurationMs,
        isHealthy,
        errorMessage,
      ];
}
