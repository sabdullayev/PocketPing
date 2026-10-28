import '../../features/request_builder/domain/entities/http_method.dart';
import '../../features/request_builder/domain/entities/http_request_entity.dart';
import '../../features/request_builder/domain/entities/key_value_param.dart';
import '../../features/request_builder/domain/entities/request_body.dart';

class CurlParser {
  CurlParser._();

  static bool isCurl(String input) {
    final t = input.trim().toLowerCase();
    return t.startsWith('curl') &&
        (t.length == 4 || RegExp(r'''^curl[\s\t\r\n'"\-]''').hasMatch(t));
  }

  static HttpRequestEntity? parse(String curlCommand) {
    if (!isCurl(curlCommand)) return null;

    // Normalize smart/curved quotes from mobile keyboards
    String normalized = curlCommand
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('‘', "'")
        .replaceAll('’', "'");

    // Remove bash line continuations (\ + newline) and Windows (^ + newline)
    String cleaned = normalized
        .replaceAll(RegExp(r'\\\r?\n'), ' ')
        .replaceAll(RegExp(r'\^\r?\n'), ' ')
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // 1. Extract Method (-X, --request)
    HttpMethod method = HttpMethod.get;
    final methodMatch = RegExp(r'''(?:-X|--request)\s+['"]?([A-Za-z]+)['"]?''', caseSensitive: false)
        .firstMatch(cleaned);
    if (methodMatch != null) {
      method = HttpMethod.fromString(methodMatch.group(1)!);
    }

    // 2. Extract Headers (-H, --header)
    final List<KeyValueParam> headers = [];
    String? bearerToken;
    final headerRegex = RegExp(
      r"""(?:-H|--header)\s*(?:'([^']+)'|"([^"]+)"|([^\s'"]+))""",
      caseSensitive: false,
    );

    for (final match in headerRegex.allMatches(cleaned)) {
      final headerStr = match.group(1) ?? match.group(2) ?? match.group(3);
      if (headerStr != null && headerStr.contains(':')) {
        final colonIndex = headerStr.indexOf(':');
        final key = headerStr.substring(0, colonIndex).trim();
        final value = headerStr.substring(colonIndex + 1).trim();

        // Check for Bearer token
        if (key.toLowerCase() == 'authorization' && value.toLowerCase().startsWith('bearer ')) {
          bearerToken = value.substring(7).trim();
        } else {
          headers.add(KeyValueParam(key: key, value: value, isEnabled: true));
        }
      }
    }

    // 3. Extract Body (-d, --data, --data-raw, --data-binary, --data-urlencode)
    RequestBody body = const RequestBody();
    final bodyRegex = RegExp(
      r"""(?:-d|--data|--data-raw|--data-binary|--data-urlencode)\s*(?:'([\s\S]*?)'|"([\s\S]*?)")""",
      caseSensitive: false,
    );
    final bodyMatch = bodyRegex.firstMatch(cleaned);
    if (bodyMatch != null) {
      final content = bodyMatch.group(1) ?? bodyMatch.group(2) ?? '';
      final isJson = content.trim().startsWith('{') || content.trim().startsWith('[');
      body = RequestBody(
        type: isJson ? RequestBodyType.json : RequestBodyType.raw,
        rawContent: content,
      );
      if (methodMatch == null) {
        method = HttpMethod.post;
      }
    }

    // 4. Extract URL (Look for http/https URL)
    String url = '';
    final urlRegex = RegExp(r'''['"](https?://[^'"]+)['"]|(?<=\s|^)(https?://[^\s'"]+)''', caseSensitive: false);
    final urlMatch = urlRegex.firstMatch(cleaned);
    if (urlMatch != null) {
      url = urlMatch.group(1) ?? urlMatch.group(2) ?? '';
    } else {
      final tokens = cleaned.split(' ');
      for (int i = 1; i < tokens.length; i++) {
        final token = tokens[i].replaceAll("'", "").replaceAll('"', '');
        if (!token.startsWith('-') && (token.startsWith('http://') || token.startsWith('https://'))) {
          url = token;
          break;
        }
      }
    }

    // 5. Extract Query Parameters from URL
    final List<KeyValueParam> queryParams = [];
    String baseUrl = url;
    if (url.contains('?')) {
      final parts = url.split('?');
      baseUrl = parts[0];
      final queryString = parts.sublist(1).join('?');
      final queryPairs = queryString.split('&');
      for (final pair in queryPairs) {
        if (pair.isEmpty) continue;
        final kv = pair.split('=');
        final k = Uri.decodeQueryComponent(kv[0]);
        final v = kv.length > 1 ? Uri.decodeQueryComponent(kv[1]) : '';
        queryParams.add(KeyValueParam(key: k, value: v, isEnabled: true));
      }
    }

    return HttpRequestEntity(
      method: method,
      url: baseUrl,
      queryParams: queryParams,
      headers: headers,
      bearerToken: bearerToken,
      body: body,
    );
  }

  /// Exports an HttpRequestEntity as a standard executable cURL command
  static String toCurl(HttpRequestEntity request) {
    final buffer = StringBuffer('curl');
    buffer.write(' -X ${request.method.label}');

    final uri = request.toUri();
    final effectiveUrl = uri?.toString() ?? request.url;
    buffer.write(" '$effectiveUrl'");

    final headers = request.getEffectiveHeaders();
    headers.forEach((k, v) {
      buffer.write(" \\\n  -H '$k: $v'");
    });

    if (request.body.type == RequestBodyType.json && request.body.rawContent.trim().isNotEmpty) {
      final escaped = request.body.rawContent.replaceAll("'", r"'\''");
      buffer.write(" \\\n  -d '$escaped'");
    } else if (request.body.type == RequestBodyType.raw && request.body.rawContent.trim().isNotEmpty) {
      final escaped = request.body.rawContent.replaceAll("'", r"'\''");
      buffer.write(" \\\n  -d '$escaped'");
    }

    return buffer.toString();
  }
}
