import 'package:equatable/equatable.dart';
import '../../domain/entities/environment_entity.dart';

abstract class EnvironmentsState extends Equatable {
  const EnvironmentsState();

  @override
  List<Object?> get props => [];
}

class EnvironmentsInitialState extends EnvironmentsState {
  const EnvironmentsInitialState();
}

class EnvironmentsLoadingState extends EnvironmentsState {
  const EnvironmentsLoadingState();
}

class EnvironmentsLoadedState extends EnvironmentsState {
  final List<EnvironmentEntity> environments;
  final EnvironmentEntity? selectedEnvironment;

  const EnvironmentsLoadedState({
    required this.environments,
    this.selectedEnvironment,
  });

  @override
  List<Object?> get props => [environments, selectedEnvironment];
}

class EnvironmentsErrorState extends EnvironmentsState {
  final String message;

  const EnvironmentsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
