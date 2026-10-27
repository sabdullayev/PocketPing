import 'package:equatable/equatable.dart';
import '../../domain/entities/http_request_entity.dart';
import '../../../response_viewer/domain/entities/http_response_entity.dart';

class RequestBuilderState extends Equatable {
  final HttpRequestEntity request;
  final bool isLoading;
  final HttpResponseEntity? response;
  final String? errorMessage;
  final String? infoMessage;

  const RequestBuilderState({
    required this.request,
    this.isLoading = false,
    this.response,
    this.errorMessage,
    this.infoMessage,
  });

  factory RequestBuilderState.initial() {
    return RequestBuilderState(
      request: HttpRequestEntity(),
    );
  }

  RequestBuilderState copyWith({
    HttpRequestEntity? request,
    bool? isLoading,
    HttpResponseEntity? response,
    String? errorMessage,
    String? infoMessage,
    bool clearResponse = false,
    bool clearInfo = false,
    bool clearError = false,
  }) {
    return RequestBuilderState(
      request: request ?? this.request,
      isLoading: isLoading ?? this.isLoading,
      response: clearResponse ? null : (response ?? this.response),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [request, isLoading, response, errorMessage, infoMessage];
}
