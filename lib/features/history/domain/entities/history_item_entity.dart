import 'package:equatable/equatable.dart';
import 'package:pocketping/features/request_builder/domain/entities/http_request_entity.dart';
import 'package:pocketping/features/response_viewer/domain/entities/http_response_entity.dart';

class HistoryItemEntity extends Equatable {
  final String id;
  final HttpRequestEntity request;
  final HttpResponseEntity response;
  final DateTime executedAt;

  const HistoryItemEntity({
    required this.id,
    required this.request,
    required this.response,
    required this.executedAt,
  });

  @override
  List<Object?> get props => [id, request, response, executedAt];
}
