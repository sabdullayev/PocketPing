import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/history_usecases.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoryUseCase getHistoryUseCase;
  final SaveHistoryItemUseCase saveHistoryItemUseCase;
  final DeleteHistoryItemUseCase deleteHistoryItemUseCase;
  final ClearHistoryUseCase clearHistoryUseCase;

  HistoryBloc({
    required this.getHistoryUseCase,
    required this.saveHistoryItemUseCase,
    required this.deleteHistoryItemUseCase,
    required this.clearHistoryUseCase,
  }) : super(const HistoryInitialState()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<AddHistoryItemEvent>(_onAddHistoryItem);
    on<DeleteHistoryItemEvent>(_onDeleteHistoryItem);
    on<ClearHistoryEvent>(_onClearHistory);
  }

  Future<void> _onLoadHistory(LoadHistoryEvent event, Emitter<HistoryState> emit) async {
    emit(const HistoryLoadingState());
    try {
      final items = await getHistoryUseCase();
      emit(HistoryLoadedState(items));
    } catch (e) {
      emit(HistoryErrorState(e.toString()));
    }
  }

  Future<void> _onAddHistoryItem(AddHistoryItemEvent event, Emitter<HistoryState> emit) async {
    try {
      await saveHistoryItemUseCase(event.item);
      final items = await getHistoryUseCase();
      emit(HistoryLoadedState(items));
    } catch (e) {
      emit(HistoryErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteHistoryItem(DeleteHistoryItemEvent event, Emitter<HistoryState> emit) async {
    try {
      await deleteHistoryItemUseCase(event.id);
      final items = await getHistoryUseCase();
      emit(HistoryLoadedState(items));
    } catch (e) {
      emit(HistoryErrorState(e.toString()));
    }
  }

  Future<void> _onClearHistory(ClearHistoryEvent event, Emitter<HistoryState> emit) async {
    try {
      await clearHistoryUseCase();
      emit(const HistoryLoadedState([]));
    } catch (e) {
      emit(HistoryErrorState(e.toString()));
    }
  }
}
