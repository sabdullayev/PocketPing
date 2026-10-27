import 'package:equatable/equatable.dart';
import '../../domain/entities/collection_entity.dart';

abstract class CollectionsState extends Equatable {
  const CollectionsState();

  @override
  List<Object?> get props => [];
}

class CollectionsInitialState extends CollectionsState {
  const CollectionsInitialState();
}

class CollectionsLoadingState extends CollectionsState {
  const CollectionsLoadingState();
}

class CollectionsLoadedState extends CollectionsState {
  final List<CollectionEntity> collections;

  const CollectionsLoadedState(this.collections);

  @override
  List<Object?> get props => [collections];
}

class CollectionsErrorState extends CollectionsState {
  final String message;

  const CollectionsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
