import 'package:equatable/equatable.dart';
import '../../../request_builder/domain/entities/http_request_entity.dart';

abstract class CollectionsEvent extends Equatable {
  const CollectionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCollectionsEvent extends CollectionsEvent {
  const LoadCollectionsEvent();
}

class CreateCollectionEvent extends CollectionsEvent {
  final String name;
  final String description;

  const CreateCollectionEvent({required this.name, this.description = ''});

  @override
  List<Object?> get props => [name, description];
}

class DeleteCollectionEvent extends CollectionsEvent {
  final String id;
  const DeleteCollectionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class AddRequestToCollectionEvent extends CollectionsEvent {
  final String collectionId;
  final HttpRequestEntity request;

  const AddRequestToCollectionEvent({
    required this.collectionId,
    required this.request,
  });

  @override
  List<Object?> get props => [collectionId, request];
}

class RemoveRequestFromCollectionEvent extends CollectionsEvent {
  final String collectionId;
  final String requestId;

  const RemoveRequestFromCollectionEvent({
    required this.collectionId,
    required this.requestId,
  });

  @override
  List<Object?> get props => [collectionId, requestId];
}
