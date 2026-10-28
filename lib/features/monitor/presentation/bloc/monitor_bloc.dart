import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/monitor_target_entity.dart';
import '../../domain/usecases/monitor_usecases.dart';
import 'monitor_event.dart';
import 'monitor_state.dart';

class MonitorBloc extends Bloc<MonitorEvent, MonitorState> {
  final GetMonitorTargetsUseCase getMonitorTargetsUseCase;
  final SaveMonitorTargetUseCase saveMonitorTargetUseCase;
  final DeleteMonitorTargetUseCase deleteMonitorTargetUseCase;
  final PingTargetUseCase pingTargetUseCase;

  MonitorBloc({
    required this.getMonitorTargetsUseCase,
    required this.saveMonitorTargetUseCase,
    required this.deleteMonitorTargetUseCase,
    required this.pingTargetUseCase,
  }) : super(const MonitorInitialState()) {
    on<LoadMonitorTargetsEvent>(_onLoadTargets);
    on<AddMonitorTargetEvent>(_onAddTarget);
    on<ToggleMonitorTargetEvent>(_onToggleTarget);
    on<DeleteMonitorTargetEvent>(_onDeleteTarget);
    on<PingTargetEvent>(_onPingTarget);
    on<PingAllTargetsEvent>(_onPingAllTargets);
  }

  Future<void> _onLoadTargets(LoadMonitorTargetsEvent event, Emitter<MonitorState> emit) async {
    emit(const MonitorLoadingState());
    try {
      final targets = await getMonitorTargetsUseCase();
      emit(MonitorLoadedState(targets));
    } catch (e) {
      emit(MonitorErrorState(e.toString()));
    }
  }

  Future<void> _onAddTarget(AddMonitorTargetEvent event, Emitter<MonitorState> emit) async {
    try {
      final newTarget = MonitorTargetEntity(
        name: event.name.trim().isEmpty ? 'Server' : event.name.trim(),
        url: event.url.trim(),
        intervalMinutes: event.intervalMinutes,
      );
      await saveMonitorTargetUseCase(newTarget);
      final targets = await getMonitorTargetsUseCase();
      emit(MonitorLoadedState(targets));
    } catch (e) {
      emit(MonitorErrorState(e.toString()));
    }
  }

  Future<void> _onToggleTarget(ToggleMonitorTargetEvent event, Emitter<MonitorState> emit) async {
    try {
      final targets = await getMonitorTargetsUseCase();
      final target = targets.firstWhere((t) => t.id == event.id);
      final updated = target.copyWith(isEnabled: !target.isEnabled);
      await saveMonitorTargetUseCase(updated);
      final updatedTargets = await getMonitorTargetsUseCase();
      emit(MonitorLoadedState(updatedTargets));
    } catch (e) {
      emit(MonitorErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteTarget(DeleteMonitorTargetEvent event, Emitter<MonitorState> emit) async {
    try {
      await deleteMonitorTargetUseCase(event.id);
      final targets = await getMonitorTargetsUseCase();
      emit(MonitorLoadedState(targets));
    } catch (e) {
      emit(MonitorErrorState(e.toString()));
    }
  }

  Future<void> _onPingTarget(PingTargetEvent event, Emitter<MonitorState> emit) async {
    final currentTargets = (state is MonitorLoadedState)
        ? (state as MonitorLoadedState).targets
        : await getMonitorTargetsUseCase();

    emit(MonitorLoadedState(currentTargets, pingingTargetId: event.target.id));
    try {
      await pingTargetUseCase(event.target);
      final updatedTargets = await getMonitorTargetsUseCase();
      emit(MonitorLoadedState(updatedTargets));
    } catch (e) {
      emit(MonitorErrorState(e.toString()));
    }
  }

  Future<void> _onPingAllTargets(PingAllTargetsEvent event, Emitter<MonitorState> emit) async {
    final targets = await getMonitorTargetsUseCase();
    for (final target in targets) {
      if (target.isEnabled) {
        emit(MonitorLoadedState(targets, pingingTargetId: target.id));
        await pingTargetUseCase(target);
      }
    }
    final updated = await getMonitorTargetsUseCase();
    emit(MonitorLoadedState(updated));
  }
}
