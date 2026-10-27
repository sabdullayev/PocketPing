import '../../../../core/network/dio_client.dart';
import '../../../response_viewer/domain/entities/http_response_entity.dart';
import '../../domain/entities/http_request_entity.dart';
import '../../domain/repositories/request_repository.dart';

class RequestRepositoryImpl implements RequestRepository {
  final DioClient dioClient;

  RequestRepositoryImpl({required this.dioClient});

  @override
  Future<HttpResponseEntity> executeRequest(HttpRequestEntity request) {
    return dioClient.execute(request);
  }
}
