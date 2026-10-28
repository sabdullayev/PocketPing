import 'package:flutter_test/flutter_test.dart';
import 'package:pocketping/features/request_builder/domain/entities/http_request_entity.dart';
import 'package:pocketping/features/request_builder/domain/repositories/request_repository.dart';
import 'package:pocketping/features/request_builder/domain/usecases/execute_request_usecase.dart';
import 'package:pocketping/features/request_builder/presentation/bloc/request_builder_bloc.dart';
import 'package:pocketping/features/request_builder/presentation/bloc/request_builder_event.dart';
import 'package:pocketping/features/response_viewer/domain/entities/http_response_entity.dart';

class FakeRequestRepository implements RequestRepository {
  @override
  Future<HttpResponseEntity> executeRequest(HttpRequestEntity request) async {
    return HttpResponseEntity(
      statusCode: 200,
      statusMessage: 'OK',
      durationMs: 10,
      sizeBytes: 100,
      headers: {},
      bodyString: '{}',
      isJson: true,
      isError: false,
    );
  }
}

void main() {
  late RequestBuilderBloc bloc;

  setUp(() {
    bloc = RequestBuilderBloc(
      executeRequestUseCase: ExecuteRequestUseCase(FakeRequestRepository()),
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('RequestBuilderBloc URL & QueryParams Sync Tests', () {
    test('extracts query params when URL with query string is entered', () async {
      bloc.add(const ChangeUrlEvent('https://api.example.com/items?page=0&size=500'));
      await expectLater(
        bloc.stream,
        emits(predicate<dynamic>((s) {
          return s.request.url == 'https://api.example.com/items' &&
              s.request.queryParams.length == 2 &&
              s.request.queryParams[0].key == 'page' &&
              s.request.queryParams[0].value == '0' &&
              s.request.queryParams[1].key == 'size' &&
              s.request.queryParams[1].value == '500';
        })),
      );
    });

    test('clears all query params when URL is cleared (empty string)', () async {
      // First set URL with params
      bloc.add(const ChangeUrlEvent('https://api.example.com/items?page=0&size=500'));
      await bloc.stream.first;

      // Now clear URL
      bloc.add(const ChangeUrlEvent(''));
      final state = await bloc.stream.first;

      expect(state.request.url, '');
      expect(state.request.queryParams, isEmpty);
    });

    test('replaces previous query params when new URL with different query string is entered', () async {
      // Set initial URL with params
      bloc.add(const ChangeUrlEvent('https://old.com?old_param=123'));
      await bloc.stream.first;

      // Set new URL with different params
      bloc.add(const ChangeUrlEvent('https://new.com/api?new_key=new_val'));
      final state = await bloc.stream.first;

      expect(state.request.url, 'https://new.com/api');
      expect(state.request.queryParams.length, 1);
      expect(state.request.queryParams[0].key, 'new_key');
      expect(state.request.queryParams[0].value, 'new_val');
    });
  });
}
