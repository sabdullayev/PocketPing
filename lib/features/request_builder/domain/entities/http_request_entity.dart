import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'http_method.dart';
import 'key_value_param.dart';
import 'request_body.dart';

class HttpRequestEntity extends Equatable {
  final String id;
  final String name;
  final HttpMethod method;
  final String url;
  final List<KeyValueParam> queryParams;
  final List<KeyValueParam> headers;
  final String? bearerToken;
  final RequestBody body;
  final DateTime createdAt;

  HttpRequestEntity({
    String? id,
    this.name = 'New Request',
    this.method = HttpMethod.get,
    this.url = 'https://jsonplaceholder.typicode.com/todos/1',
    List<KeyValueParam>? queryParams,
    List<KeyValueParam>? headers,
    this.bearerToken,
    this.body = const RequestBody(),
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        queryParams = queryParams ?? const [],
        headers = headers ?? const [],
        createdAt = createdAt ?? DateTime.now();

  const HttpRequestEntity.raw({
    required this.id,
    required this.name,
    required this.method,
    required this.url,
    required this.queryParams,
    required this.headers,
    this.bearerToken,
    required this.body,
    required this.createdAt,
  });

  /// Builds a Uri with query parameters enabled
  Uri? toUri() {
    try {
      final base = Uri.parse(url.trim());
      final Map<String, String> queryMap = Map.from(base.queryParameters);
      for (final param in queryParams) {
        if (param.isEnabled && param.key.trim().isNotEmpty) {
          queryMap[param.key.trim()] = param.value;
        }
      }
      return base.replace(queryParameters: queryMap.isEmpty ? null : queryMap);
    } catch (_) {
      return null;
    }
  }

  /// Headers map combining custom headers and optional Bearer Token
  Map<String, String> getEffectiveHeaders() {
    final map = <String, String>{};
    for (final h in headers) {
      if (h.isEnabled && h.key.trim().isNotEmpty) {
        map[h.key.trim()] = h.value;
      }
    }
    if (bearerToken != null && bearerToken!.trim().isNotEmpty) {
      final clean = bearerToken!.trim();
      final tokenOnly = clean.toLowerCase().startsWith('bearer ')
          ? clean.substring(7).trim()
          : clean;
      map['Authorization'] = 'Bearer $tokenOnly';
    }
    if (body.type == RequestBodyType.json && !map.containsKey('Content-Type')) {
      map['Content-Type'] = 'application/json';
    }
    return map;
  }

  HttpRequestEntity copyWith({
    String? id,
    String? name,
    HttpMethod? method,
    String? url,
    List<KeyValueParam>? queryParams,
    List<KeyValueParam>? headers,
    String? bearerToken,
    RequestBody? body,
    DateTime? createdAt,
  }) {
    return HttpRequestEntity.raw(
      id: id ?? this.id,
      name: name ?? this.name,
      method: method ?? this.method,
      url: url ?? this.url,
      queryParams: queryParams ?? this.queryParams,
      headers: headers ?? this.headers,
      bearerToken: bearerToken ?? this.bearerToken,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        method,
        url,
        queryParams,
        headers,
        bearerToken,
        body,
        createdAt,
      ];
}
