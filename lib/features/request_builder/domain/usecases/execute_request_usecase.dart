import '../../../response_viewer/domain/entities/http_response_entity.dart';
import '../entities/http_request_entity.dart';
import '../repositories/request_repository.dart';

class ExecuteRequestUseCase {
  final RequestRepository repository;

  ExecuteRequestUseCase(this.repository);

  Future<HttpResponseEntity> call(HttpRequestEntity request) {
    return repository.executeRequest(request);
  }
}
