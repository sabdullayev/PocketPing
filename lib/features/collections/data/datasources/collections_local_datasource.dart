import 'package:hive/hive.dart';
import '../../../request_builder/data/models/http_request_model.dart';
import '../models/collection_model.dart';

abstract class CollectionsLocalDataSource {
  Future<List<CollectionModel>> getCollections();
  Future<void> saveCollection(CollectionModel collection);
  Future<void> deleteCollection(String id);
  Future<void> saveRequestToCollection(String collectionId, HttpRequestModel request);
  Future<void> removeRequestFromCollection(String collectionId, String requestId);
}

class CollectionsLocalDataSourceImpl implements CollectionsLocalDataSource {
  static const String boxName = 'collections_box';

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  @override
  Future<List<CollectionModel>> getCollections() async {
    final box = await _getBox();
    final List<CollectionModel> collections = [];
    for (int i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw is Map) {
        try {
          collections.add(CollectionModel.fromMap(raw));
        } catch (_) {}
      }
    }
    return collections;
  }

  @override
  Future<void> saveCollection(CollectionModel collection) async {
    final box = await _getBox();
    int existingIdx = -1;
    for (int i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw is Map && raw['id'] == collection.id) {
        existingIdx = i;
        break;
      }
    }

    if (existingIdx >= 0) {
      await box.putAt(existingIdx, collection.toMap());
    } else {
      await box.add(collection.toMap());
    }
  }

  @override
  Future<void> deleteCollection(String id) async {
    final box = await _getBox();
    for (int i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw is Map && raw['id'] == id) {
        await box.deleteAt(i);
        break;
      }
    }
  }

  @override
  Future<void> saveRequestToCollection(String collectionId, HttpRequestModel request) async {
    final box = await _getBox();
    for (int i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw is Map && raw['id'] == collectionId) {
        final col = CollectionModel.fromMap(raw);
        final updatedRequests = List<HttpRequestModel>.from(col.requests)
          ..removeWhere((r) => r.id == request.id)
          ..add(request);
        final updatedCol = CollectionModel(
          id: col.id,
          name: col.name,
          description: col.description,
          requests: updatedRequests,
          createdAt: col.createdAt,
        );
        await box.putAt(i, updatedCol.toMap());
        break;
      }
    }
  }

  @override
  Future<void> removeRequestFromCollection(String collectionId, String requestId) async {
    final box = await _getBox();
    for (int i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw is Map && raw['id'] == collectionId) {
        final col = CollectionModel.fromMap(raw);
        final updatedRequests = List<HttpRequestModel>.from(col.requests)
          ..removeWhere((r) => r.id == requestId);
        final updatedCol = CollectionModel(
          id: col.id,
          name: col.name,
          description: col.description,
          requests: updatedRequests,
          createdAt: col.createdAt,
        );
        await box.putAt(i, updatedCol.toMap());
        break;
      }
    }
  }
}
