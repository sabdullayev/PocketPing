import '../../../request_builder/data/models/http_request_model.dart';
import '../../../request_builder/domain/entities/http_request_entity.dart';
import '../../domain/entities/collection_entity.dart';
import '../../domain/repositories/collections_repository.dart';
import '../datasources/collections_local_datasource.dart';
import '../models/collection_model.dart';

class CollectionsRepositoryImpl implements CollectionsRepository {
  final CollectionsLocalDataSource localDataSource;

  CollectionsRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CollectionEntity>> getCollections() async {
    final models = await localDataSource.getCollections();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveCollection(CollectionEntity collection) async {
    final model = CollectionModel.fromEntity(collection);
    await localDataSource.saveCollection(model);
  }

  @override
  Future<void> deleteCollection(String id) async {
    await localDataSource.deleteCollection(id);
  }

  @override
  Future<void> saveRequestToCollection(String collectionId, HttpRequestEntity request) async {
    final model = HttpRequestModel.fromEntity(request);
    await localDataSource.saveRequestToCollection(collectionId, model);
  }

  @override
  Future<void> removeRequestFromCollection(String collectionId, String requestId) async {
    await localDataSource.removeRequestFromCollection(collectionId, requestId);
  }
}
