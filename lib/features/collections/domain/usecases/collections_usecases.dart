import 'package:pocketping/features/request_builder/domain/entities/http_request_entity.dart';
import '../entities/collection_entity.dart';
import '../repositories/collections_repository.dart';

class GetCollectionsUseCase {
  final CollectionsRepository repository;
  GetCollectionsUseCase(this.repository);

  Future<List<CollectionEntity>> call() => repository.getCollections();
}

class SaveCollectionUseCase {
  final CollectionsRepository repository;
  SaveCollectionUseCase(this.repository);

  Future<void> call(CollectionEntity collection) => repository.saveCollection(collection);
}

class DeleteCollectionUseCase {
  final CollectionsRepository repository;
  DeleteCollectionUseCase(this.repository);

  Future<void> call(String id) => repository.deleteCollection(id);
}

class SaveRequestToCollectionUseCase {
  final CollectionsRepository repository;
  SaveRequestToCollectionUseCase(this.repository);

  Future<void> call(String collectionId, HttpRequestEntity request) =>
      repository.saveRequestToCollection(collectionId, request);
}

class RemoveRequestFromCollectionUseCase {
  final CollectionsRepository repository;
  RemoveRequestFromCollectionUseCase(this.repository);

  Future<void> call(String collectionId, String requestId) =>
      repository.removeRequestFromCollection(collectionId, requestId);
}
