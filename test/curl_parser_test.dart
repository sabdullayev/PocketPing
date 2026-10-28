import 'package:flutter_test/flutter_test.dart';
import 'package:pocketping/core/utils/curl_parser.dart';
import 'package:pocketping/features/request_builder/domain/entities/http_method.dart';
import 'package:pocketping/features/request_builder/domain/entities/request_body.dart';

void main() {
  group('CurlParser Tests', () {
    test('Correctly identifies curl command', () {
      expect(CurlParser.isCurl('curl https://api.example.com'), isTrue);
      expect(CurlParser.isCurl('curl -X POST https://api.example.com'), isTrue);
      expect(CurlParser.isCurl('http://api.example.com'), isFalse);
    });

    test('Parses simple GET command with query parameters', () {
      const curl = 'curl "https://api.example.com/users?page=2&limit=10"';
      final req = CurlParser.parse(curl);

      expect(req, isNotNull);
      expect(req!.method, HttpMethod.get);
      expect(req.url, 'https://api.example.com/users');
      expect(req.queryParams.length, 2);
      expect(req.queryParams[0].key, 'page');
      expect(req.queryParams[0].value, '2');
      expect(req.queryParams[1].key, 'limit');
      expect(req.queryParams[1].value, '10');
    });

    test('Parses POST command with Authorization Bearer and JSON body', () {
      const curl = '''
      curl -X POST https://api.example.com/login \\
        -H "Content-Type: application/json" \\
        -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.token" \\
        -d '{"username":"dev","password":"123"}'
      ''';

      final req = CurlParser.parse(curl);

      expect(req, isNotNull);
      expect(req!.method, HttpMethod.post);
      expect(req.url, 'https://api.example.com/login');
      expect(req.bearerToken, 'eyJhbGciOiJIUzI1NiJ9.token');
      expect(req.body.type, RequestBodyType.json);
      expect(req.body.rawContent, '{"username":"dev","password":"123"}');
    });

    test('Parses Swagger / OpenAPI cURL format with quoted GET and --location', () {
      const curl = '''curl -X 'GET' \\
  'https://api.biznex.uz/api/v1/back-office/products?page=0&size=500' \\
  -H 'accept: application/json' \\
  -H 'Authorization: Bearer my_token' ''';
      final req = CurlParser.parse(curl);
      expect(req, isNotNull);
      expect(req!.method, HttpMethod.get);
      expect(req.url, 'https://api.biznex.uz/api/v1/back-office/products');
      expect(req.bearerToken, 'my_token');
      expect(req.queryParams.length, 2);
    });

    test('toCurl exports request to executable cURL command', () {
      final req = CurlParser.parse('''curl -X GET "https://api.example.com/items?page=1" -H "Accept: application/json" -H "Authorization: Bearer test_tok"''');
      expect(req, isNotNull);
      final exported = CurlParser.toCurl(req!);
      expect(exported, contains("curl -X GET 'https://api.example.com/items?page=1'"));
      expect(exported, contains("-H 'Authorization: Bearer test_tok'"));
    });
  });
}
