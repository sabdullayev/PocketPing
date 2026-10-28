import 'package:equatable/equatable.dart';
import '../../domain/entities/environment_entity.dart';

abstract class EnvironmentsEvent extends Equatable {
  const EnvironmentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadEnvironmentsEvent extends EnvironmentsEvent {
  const LoadEnvironmentsEvent();
}

class SelectEnvironmentEvent extends EnvironmentsEvent {
  final String? id;
  const SelectEnvironmentEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SaveEnvironmentEvent extends EnvironmentsEvent {
  final EnvironmentEntity environment;
  const SaveEnvironmentEvent(this.environment);

  @override
  List<Object?> get props => [environment];
}

class DeleteEnvironmentEvent extends EnvironmentsEvent {
  final String id;
  const DeleteEnvironmentEvent(this.id);

  @override
  List<Object?> get props => [id];
}
