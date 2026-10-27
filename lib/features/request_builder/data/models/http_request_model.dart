import '../../domain/entities/http_method.dart';
import '../../domain/entities/http_request_entity.dart';
import '../../domain/entities/key_value_param.dart';
import '../../domain/entities/request_body.dart';

class HttpRequestModel {
  final String id;
  final String name;
  final String method;
  final String url;
  final List<Map<String, dynamic>> queryParams;
  final List<Map<String, dynamic>> headers;
  final String? bearerToken;
  final Map<String, dynamic> body;
  final String createdAt;

  const HttpRequestModel({
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

  factory HttpRequestModel.fromEntity(HttpRequestEntity entity) {
    return HttpRequestModel(
      id: entity.id,
      name: entity.name,
      method: entity.method.label,
      url: entity.url,
      queryParams: entity.queryParams
          .map((p) => {
                'id': p.id,
                'key': p.key,
                'value': p.value,
                'isEnabled': p.isEnabled,
              })
          .toList(),
      headers: entity.headers
          .map((h) => {
                'id': h.id,
                'key': h.key,
                'value': h.value,
                'isEnabled': h.isEnabled,
              })
          .toList(),
      bearerToken: entity.bearerToken,
      body: {
        'type': entity.body.type.name,
        'rawContent': entity.body.rawContent,
      },
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  HttpRequestEntity toEntity() {
    RequestBodyType bodyType = RequestBodyType.none;
    for (final t in RequestBodyType.values) {
      if (t.name == body['type']) {
        bodyType = t;
        break;
      }
    }

    return HttpRequestEntity.raw(
      id: id,
      name: name,
      method: HttpMethod.fromString(method),
      url: url,
      queryParams: queryParams
          .map((p) => KeyValueParam.raw(
                id: p['id']?.toString() ?? '',
                key: p['key']?.toString() ?? '',
                value: p['value']?.toString() ?? '',
                isEnabled: p['isEnabled'] == true,
              ))
          .toList(),
      headers: headers
          .map((h) => KeyValueParam.raw(
                id: h['id']?.toString() ?? '',
                key: h['key']?.toString() ?? '',
                value: h['value']?.toString() ?? '',
                isEnabled: h['isEnabled'] == true,
              ))
          .toList(),
      bearerToken: bearerToken,
      body: RequestBody(
        type: bodyType,
        rawContent: body['rawContent']?.toString() ?? '',
      ),
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'method': method,
      'url': url,
      'queryParams': queryParams,
      'headers': headers,
      'bearerToken': bearerToken,
      'body': body,
      'createdAt': createdAt,
    };
  }

  factory HttpRequestModel.fromMap(Map<dynamic, dynamic> map) {
    return HttpRequestModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Request',
      method: map['method']?.toString() ?? 'GET',
      url: map['url']?.toString() ?? '',
      queryParams: (map['queryParams'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      headers: (map['headers'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      bearerToken: map['bearerToken']?.toString(),
      body: map['body'] != null ? Map<String, dynamic>.from(map['body'] as Map) : {},
      createdAt: map['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
