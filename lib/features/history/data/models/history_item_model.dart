import '../../../request_builder/data/models/http_request_model.dart';
import '../../../response_viewer/data/models/http_response_model.dart';
import '../../domain/entities/history_item_entity.dart';

class HistoryItemModel {
  final String id;
  final HttpRequestModel request;
  final HttpResponseModel response;
  final String executedAt;

  const HistoryItemModel({
    required this.id,
    required this.request,
    required this.response,
    required this.executedAt,
  });

  factory HistoryItemModel.fromEntity(HistoryItemEntity entity) {
    return HistoryItemModel(
      id: entity.id,
      request: HttpRequestModel.fromEntity(entity.request),
      response: HttpResponseModel.fromEntity(entity.response),
      executedAt: entity.executedAt.toIso8601String(),
    );
  }

  HistoryItemEntity toEntity() {
    return HistoryItemEntity(
      id: id,
      request: request.toEntity(),
      response: response.toEntity(),
      executedAt: DateTime.tryParse(executedAt) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'request': request.toMap(),
      'response': response.toMap(),
      'executedAt': executedAt,
    };
  }

  factory HistoryItemModel.fromMap(Map<dynamic, dynamic> map) {
    return HistoryItemModel(
      id: map['id']?.toString() ?? '',
      request: HttpRequestModel.fromMap(Map<dynamic, dynamic>.from(map['request'] as Map)),
      response: HttpResponseModel.fromMap(Map<dynamic, dynamic>.from(map['response'] as Map)),
      executedAt: map['executedAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
