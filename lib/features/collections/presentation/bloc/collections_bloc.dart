import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/collection_entity.dart';
import '../../domain/usecases/collections_usecases.dart';
import 'collections_event.dart';
import 'collections_state.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final GetCollectionsUseCase getCollectionsUseCase;
  final SaveCollectionUseCase saveCollectionUseCase;
  final DeleteCollectionUseCase deleteCollectionUseCase;
  final SaveRequestToCollectionUseCase saveRequestToCollectionUseCase;
  final RemoveRequestFromCollectionUseCase removeRequestFromCollectionUseCase;

  CollectionsBloc({
    required this.getCollectionsUseCase,
    required this.saveCollectionUseCase,
    required this.deleteCollectionUseCase,
    required this.saveRequestToCollectionUseCase,
    required this.removeRequestFromCollectionUseCase,
  }) : super(const CollectionsInitialState()) {
    on<LoadCollectionsEvent>(_onLoadCollections);
    on<CreateCollectionEvent>(_onCreateCollection);
    on<DeleteCollectionEvent>(_onDeleteCollection);
    on<AddRequestToCollectionEvent>(_onAddRequestToCollection);
    on<RemoveRequestFromCollectionEvent>(_onRemoveRequestFromCollection);
  }

  Future<void> _onLoadCollections(LoadCollectionsEvent event, Emitter<CollectionsState> emit) async {
    emit(const CollectionsLoadingState());
    try {
      final items = await getCollectionsUseCase();
      emit(CollectionsLoadedState(items));
    } catch (e) {
      emit(CollectionsErrorState(e.toString()));
    }
  }

  Future<void> _onCreateCollection(CreateCollectionEvent event, Emitter<CollectionsState> emit) async {
    try {
      final newCol = CollectionEntity(
        name: event.name.trim().isEmpty ? 'Untitled Collection' : event.name.trim(),
        description: event.description.trim(),
      );
      await saveCollectionUseCase(newCol);
      final items = await getCollectionsUseCase();
      emit(CollectionsLoadedState(items));
    } catch (e) {
      emit(CollectionsErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteCollection(DeleteCollectionEvent event, Emitter<CollectionsState> emit) async {
    try {
      await deleteCollectionUseCase(event.id);
      final items = await getCollectionsUseCase();
      emit(CollectionsLoadedState(items));
    } catch (e) {
      emit(CollectionsErrorState(e.toString()));
    }
  }

  Future<void> _onAddRequestToCollection(
      AddRequestToCollectionEvent event, Emitter<CollectionsState> emit) async {
    try {
      await saveRequestToCollectionUseCase(event.collectionId, event.request);
      final items = await getCollectionsUseCase();
      emit(CollectionsLoadedState(items));
    } catch (e) {
      emit(CollectionsErrorState(e.toString()));
    }
  }

  Future<void> _onRemoveRequestFromCollection(
      RemoveRequestFromCollectionEvent event, Emitter<CollectionsState> emit) async {
    try {
      await removeRequestFromCollectionUseCase(event.collectionId, event.requestId);
      final items = await getCollectionsUseCase();
      emit(CollectionsLoadedState(items));
    } catch (e) {
      emit(CollectionsErrorState(e.toString()));
    }
  }
}
