import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/environments_usecases.dart';
import 'environments_event.dart';
import 'environments_state.dart';

class EnvironmentsBloc extends Bloc<EnvironmentsEvent, EnvironmentsState> {
  final GetEnvironmentsUseCase getEnvironmentsUseCase;
  final SaveEnvironmentUseCase saveEnvironmentUseCase;
  final DeleteEnvironmentUseCase deleteEnvironmentUseCase;
  final SelectEnvironmentUseCase selectEnvironmentUseCase;

  EnvironmentsBloc({
    required this.getEnvironmentsUseCase,
    required this.saveEnvironmentUseCase,
    required this.deleteEnvironmentUseCase,
    required this.selectEnvironmentUseCase,
  }) : super(const EnvironmentsInitialState()) {
    on<LoadEnvironmentsEvent>(_onLoadEnvironments);
    on<SelectEnvironmentEvent>(_onSelectEnvironment);
    on<SaveEnvironmentEvent>(_onSaveEnvironment);
    on<DeleteEnvironmentEvent>(_onDeleteEnvironment);
  }

  Future<void> _onLoadEnvironments(
      LoadEnvironmentsEvent event, Emitter<EnvironmentsState> emit) async {
    emit(const EnvironmentsLoadingState());
    try {
      final items = await getEnvironmentsUseCase();
      final selected = items.where((e) => e.isSelected).firstOrNull;
      emit(EnvironmentsLoadedState(environments: items, selectedEnvironment: selected));
    } catch (e) {
      emit(EnvironmentsErrorState(e.toString()));
    }
  }

  Future<void> _onSelectEnvironment(
      SelectEnvironmentEvent event, Emitter<EnvironmentsState> emit) async {
    try {
      await selectEnvironmentUseCase(event.id);
      final items = await getEnvironmentsUseCase();
      final selected = items.where((e) => e.isSelected).firstOrNull;
      emit(EnvironmentsLoadedState(environments: items, selectedEnvironment: selected));
    } catch (e) {
      emit(EnvironmentsErrorState(e.toString()));
    }
  }

  Future<void> _onSaveEnvironment(
      SaveEnvironmentEvent event, Emitter<EnvironmentsState> emit) async {
    try {
      await saveEnvironmentUseCase(event.environment);
      final items = await getEnvironmentsUseCase();
      final selected = items.where((e) => e.isSelected).firstOrNull;
      emit(EnvironmentsLoadedState(environments: items, selectedEnvironment: selected));
    } catch (e) {
      emit(EnvironmentsErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteEnvironment(
      DeleteEnvironmentEvent event, Emitter<EnvironmentsState> emit) async {
    try {
      await deleteEnvironmentUseCase(event.id);
      final items = await getEnvironmentsUseCase();
      final selected = items.where((e) => e.isSelected).firstOrNull;
      emit(EnvironmentsLoadedState(environments: items, selectedEnvironment: selected));
    } catch (e) {
      emit(EnvironmentsErrorState(e.toString()));
    }
  }
}
