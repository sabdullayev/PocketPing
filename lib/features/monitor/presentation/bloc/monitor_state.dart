import 'package:equatable/equatable.dart';
import '../../domain/entities/monitor_target_entity.dart';

abstract class MonitorState extends Equatable {
  const MonitorState();

  @override
  List<Object?> get props => [];
}

class MonitorInitialState extends MonitorState {
  const MonitorInitialState();
}

class MonitorLoadingState extends MonitorState {
  const MonitorLoadingState();
}

class MonitorLoadedState extends MonitorState {
  final List<MonitorTargetEntity> targets;
  final String? pingingTargetId;

  const MonitorLoadedState(this.targets, {this.pingingTargetId});

  @override
  List<Object?> get props => [targets, pingingTargetId];
}

class MonitorErrorState extends MonitorState {
  final String message;

  const MonitorErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
