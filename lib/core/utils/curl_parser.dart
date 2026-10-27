import '../../features/request_builder/domain/entities/http_method.dart';
import '../../features/request_builder/domain/entities/http_request_entity.dart';
import '../../features/request_builder/domain/entities/key_value_param.dart';
import '../../features/request_builder/domain/entities/request_body.dart';

class CurlParser {
  CurlParser._();

  static bool isCurl(String input) {
    return input.trim().toLowerCase().startsWith('curl ');
  }

  static HttpRequestEntity? parse(String curlCommand) {
    if (!isCurl(curlCommand)) return null;

    // Remove line continuation slashes and newlines
    String cleaned = curlCommand
        .replaceAll('\\\r\n', ' ')
        .replaceAll('\\\n', ' ')
        .replaceAll('\\\r', ' ')
        .replaceAll('\\', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // 1. Extract Method
    HttpMethod method = HttpMethod.get;
    final methodMatch = RegExp(r'(?:-X|--request)\s+([A-Za-z]+)', caseSensitive: false).firstMatch(cleaned);
    if (methodMatch != null) {
      method = HttpMethod.fromString(methodMatch.group(1)!);
    }

    // 2. Extract Headers
    final List<KeyValueParam> headers = [];
    String? bearerToken;
    final headerRegex = RegExp(r"(?:-H|--header)\s+(?:'([^']+)'|" '"([^"]+)")');
    for (final match in headerRegex.allMatches(cleaned)) {
      final headerStr = match.group(1) ?? match.group(2);
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

    // 3. Extract Body (-d, --data, --data-raw)
    RequestBody body = const RequestBody();
    final bodyRegex = RegExp(r"(?:-d|--data|--data-raw)\s+(?:'([\s\S]*?)'|" r'"([\s\S]*?)")');
    final bodyMatch = bodyRegex.firstMatch(cleaned);
    if (bodyMatch != null) {
      final content = bodyMatch.group(1) ?? bodyMatch.group(2) ?? '';
      final isJson = content.trim().startsWith('{') || content.trim().startsWith('[');
      body = RequestBody(
        type: isJson ? RequestBodyType.json : RequestBodyType.raw,
        rawContent: content,
      );
      // If no explicit method was given, data implies POST
      if (methodMatch == null) {
        method = HttpMethod.post;
      }
    }

    // 4. Extract URL (Look for http/https URL)
    String url = '';
    final urlRegex = RegExp(r'''(?:'|")(https?://[^'"]+)(?:'|")|(?<=\s)(https?://[^\s]+)''');
    final urlMatch = urlRegex.firstMatch(cleaned);
    if (urlMatch != null) {
      url = urlMatch.group(1) ?? urlMatch.group(2) ?? '';
    } else {
      // Fallback: look for argument that doesn't start with '-' and isn't curl
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
}
