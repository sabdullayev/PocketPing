import 'package:flutter_test/flutter_test.dart';
import 'package:pocketping/features/environments/domain/entities/environment_entity.dart';
import 'package:pocketping/features/environments/domain/entities/environment_variable.dart';
import 'package:pocketping/features/environments/domain/usecases/substitute_env_variables_usecase.dart';
import 'package:pocketping/features/request_builder/domain/entities/http_method.dart';
import 'package:pocketping/features/request_builder/domain/entities/http_request_entity.dart';
import 'package:pocketping/features/request_builder/domain/entities/key_value_param.dart';
import 'package:pocketping/features/request_builder/domain/entities/request_body.dart';

void main() {
  group('SubstituteEnvVariablesUseCase Tests', () {
    final useCase = SubstituteEnvVariablesUseCase();

    final testEnv = EnvironmentEntity(
      name: 'Test Environment',
      variables: [
        EnvironmentVariable(key: 'base_url', value: 'https://api.mytest.com'),
        EnvironmentVariable(key: 'token', value: 'secret_jwt_token_456'),
        EnvironmentVariable(key: 'user_id', value: '42'),
      ],
      isSelected: true,
    );

    test('Substitutes variables in URL, headers, and body', () {
      final request = HttpRequestEntity(
        method: HttpMethod.post,
        url: '{{base_url}}/users/{{user_id}}',
        bearerToken: '{{token}}',
        queryParams: [
          KeyValueParam(key: 'uid', value: '{{user_id}}', isEnabled: true),
        ],
        body: const RequestBody(
          type: RequestBodyType.json,
          rawContent: '{"userId": "{{user_id}}", "auth": "{{token}}"}',
        ),
      );

      final substituted = useCase(request, testEnv);

      expect(substituted.url, 'https://api.mytest.com/users/42');
      expect(substituted.bearerToken, 'secret_jwt_token_456');
      expect(substituted.queryParams.first.value, '42');
      expect(substituted.body.rawContent, '{"userId": "42", "auth": "secret_jwt_token_456"}');
    });

    test('Leaves request untouched if environment is null', () {
      final request = HttpRequestEntity(
        url: '{{base_url}}/items',
      );

      final substituted = useCase(request, null);
      expect(substituted.url, '{{base_url}}/items');
    });
  });
}
