import 'package:equatable/equatable.dart';
import '../../domain/entities/monitor_target_entity.dart';

abstract class MonitorEvent extends Equatable {
  const MonitorEvent();

  @override
  List<Object?> get props => [];
}

class LoadMonitorTargetsEvent extends MonitorEvent {
  const LoadMonitorTargetsEvent();
}

class AddMonitorTargetEvent extends MonitorEvent {
  final String name;
  final String url;
  final int intervalMinutes;

  const AddMonitorTargetEvent({
    required this.name,
    required this.url,
    this.intervalMinutes = 15,
  });

  @override
  List<Object?> get props => [name, url, intervalMinutes];
}

class ToggleMonitorTargetEvent extends MonitorEvent {
  final String id;
  const ToggleMonitorTargetEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteMonitorTargetEvent extends MonitorEvent {
  final String id;
  const DeleteMonitorTargetEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class PingTargetEvent extends MonitorEvent {
  final MonitorTargetEntity target;
  const PingTargetEvent(this.target);

  @override
  List<Object?> get props => [target];
}

class PingAllTargetsEvent extends MonitorEvent {
  const PingAllTargetsEvent();
}
