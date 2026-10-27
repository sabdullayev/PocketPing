import '../../../response_viewer/domain/entities/http_response_entity.dart';
import '../entities/http_request_entity.dart';

abstract class RequestRepository {
  Future<HttpResponseEntity> executeRequest(HttpRequestEntity request);
}
