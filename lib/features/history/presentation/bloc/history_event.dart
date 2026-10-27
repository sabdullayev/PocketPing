import 'package:equatable/equatable.dart';
import '../../domain/entities/history_item_entity.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistoryEvent extends HistoryEvent {
  const LoadHistoryEvent();
}

class AddHistoryItemEvent extends HistoryEvent {
  final HistoryItemEntity item;
  const AddHistoryItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class DeleteHistoryItemEvent extends HistoryEvent {
  final String id;
  const DeleteHistoryItemEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearHistoryEvent extends HistoryEvent {
  const ClearHistoryEvent();
}
