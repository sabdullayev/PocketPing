import 'package:pocketping/features/request_builder/domain/entities/http_request_entity.dart';
import '../entities/collection_entity.dart';

abstract class CollectionsRepository {
  Future<List<CollectionEntity>> getCollections();
  Future<void> saveCollection(CollectionEntity collection);
  Future<void> deleteCollection(String id);
  Future<void> saveRequestToCollection(String collectionId, HttpRequestEntity request);
  Future<void> removeRequestFromCollection(String collectionId, String requestId);
}
