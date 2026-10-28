import 'package:flutter_test/flutter_test.dart';
import 'package:pocketping/features/history/data/models/history_item_model.dart';
import 'package:pocketping/features/history/domain/entities/history_item_entity.dart';
import 'package:pocketping/features/request_builder/domain/entities/http_method.dart';
import 'package:pocketping/features/request_builder/domain/entities/http_request_entity.dart';
import 'package:pocketping/features/response_viewer/domain/entities/http_response_entity.dart';

void main() {
  test('HistoryItemModel serialization test', () {
    final entity = HistoryItemEntity(
      id: 'test_123',
      request: HttpRequestEntity(
        method: HttpMethod.post,
        url: 'https://jsonplaceholder.typicode.com/posts',
      ),
      response: HttpResponseEntity(
        statusCode: 200,
        statusMessage: 'OK',
        durationMs: 45,
        sizeBytes: 120,
        headers: {'content-type': ['application/json']},
        bodyString: '{"success": true}',
        isJson: true,
      ),
      executedAt: DateTime.now(),
    );

    final model = HistoryItemModel.fromEntity(entity);
    final map = model.toMap();
    final restoredModel = HistoryItemModel.fromMap(map);
    final restoredEntity = restoredModel.toEntity();

    expect(restoredEntity.id, entity.id);
    expect(restoredEntity.request.url, entity.request.url);
    expect(restoredEntity.response.statusCode, 200);
    expect(restoredEntity.response.headers['content-type'], ['application/json']);
  });
}
