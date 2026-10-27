import 'package:equatable/equatable.dart';
import 'package:pocketping/features/request_builder/domain/entities/http_request_entity.dart';
import 'package:uuid/uuid.dart';

class CollectionEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<HttpRequestEntity> requests;
  final DateTime createdAt;

  CollectionEntity({
    String? id,
    required this.name,
    this.description = '',
    List<HttpRequestEntity>? requests,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        requests = requests ?? const [],
        createdAt = createdAt ?? DateTime.now();

  const CollectionEntity.raw({
    required this.id,
    required this.name,
    required this.description,
    required this.requests,
    required this.createdAt,
  });

  CollectionEntity copyWith({
    String? id,
    String? name,
    String? description,
    List<HttpRequestEntity>? requests,
    DateTime? createdAt,
  }) {
    return CollectionEntity.raw(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      requests: requests ?? this.requests,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, description, requests, createdAt];
}
