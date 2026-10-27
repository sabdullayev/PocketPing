import 'package:equatable/equatable.dart';
import '../../domain/entities/history_item_entity.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitialState extends HistoryState {
  const HistoryInitialState();
}

class HistoryLoadingState extends HistoryState {
  const HistoryLoadingState();
}

class HistoryLoadedState extends HistoryState {
  final List<HistoryItemEntity> items;

  const HistoryLoadedState(this.items);

  @override
  List<Object?> get props => [items];
}

class HistoryErrorState extends HistoryState {
  final String message;

  const HistoryErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
