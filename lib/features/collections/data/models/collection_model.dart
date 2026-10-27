import 'package:pocketping/features/request_builder/data/models/http_request_model.dart';
import '../../domain/entities/collection_entity.dart';

class CollectionModel {
  final String id;
  final String name;
  final String description;
  final List<HttpRequestModel> requests;
  final String createdAt;

  const CollectionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.requests,
    required this.createdAt,
  });

  factory CollectionModel.fromEntity(CollectionEntity entity) {
    return CollectionModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      requests: entity.requests.map((r) => HttpRequestModel.fromEntity(r)).toList(),
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  CollectionEntity toEntity() {
    return CollectionEntity.raw(
      id: id,
      name: name,
      description: description,
      requests: requests.map((r) => r.toEntity()).toList(),
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'requests': requests.map((r) => r.toMap()).toList(),
      'createdAt': createdAt,
    };
  }

  factory CollectionModel.fromMap(Map<dynamic, dynamic> map) {
    final requestsRaw = map['requests'] as List<dynamic>? ?? [];
    return CollectionModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Collection',
      description: map['description']?.toString() ?? '',
      requests: requestsRaw
          .map((e) => HttpRequestModel.fromMap(Map<dynamic, dynamic>.from(e as Map)))
          .toList(),
      createdAt: map['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
