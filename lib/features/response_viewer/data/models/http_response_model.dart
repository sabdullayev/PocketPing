import '../../domain/entities/http_response_entity.dart';

class HttpResponseModel {
  final int statusCode;
  final String statusMessage;
  final int durationMs;
  final int sizeBytes;
  final Map<String, List<String>> headers;
  final String bodyString;
  final bool isJson;
  final bool isError;
  final String? errorMessage;
  final String timestamp;

  const HttpResponseModel({
    required this.statusCode,
    required this.statusMessage,
    required this.durationMs,
    required this.sizeBytes,
    required this.headers,
    required this.bodyString,
    required this.isJson,
    required this.isError,
    this.errorMessage,
    required this.timestamp,
  });

  factory HttpResponseModel.fromEntity(HttpResponseEntity entity) {
    return HttpResponseModel(
      statusCode: entity.statusCode,
      statusMessage: entity.statusMessage,
      durationMs: entity.durationMs,
      sizeBytes: entity.sizeBytes,
      headers: entity.headers,
      bodyString: entity.bodyString,
      isJson: entity.isJson,
      isError: entity.isError,
      errorMessage: entity.errorMessage,
      timestamp: entity.timestamp.toIso8601String(),
    );
  }

  HttpResponseEntity toEntity() {
    return HttpResponseEntity(
      statusCode: statusCode,
      statusMessage: statusMessage,
      durationMs: durationMs,
      sizeBytes: sizeBytes,
      headers: headers,
      bodyString: bodyString,
      isJson: isJson,
      isError: isError,
      errorMessage: errorMessage,
      timestamp: DateTime.tryParse(timestamp) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'statusCode': statusCode,
      'statusMessage': statusMessage,
      'durationMs': durationMs,
      'sizeBytes': sizeBytes,
      'headers': headers,
      'bodyString': bodyString,
      'isJson': isJson,
      'isError': isError,
      'errorMessage': errorMessage,
      'timestamp': timestamp,
    };
  }

  factory HttpResponseModel.fromMap(Map<dynamic, dynamic> map) {
    final headersRaw = map['headers'] as Map<dynamic, dynamic>? ?? {};
    final headersParsed = <String, List<String>>{};
    headersRaw.forEach((k, v) {
      if (v is List) {
        headersParsed[k.toString()] = v.map((e) => e.toString()).toList();
      }
    });

    return HttpResponseModel(
      statusCode: (map['statusCode'] as num?)?.toInt() ?? 0,
      statusMessage: map['statusMessage']?.toString() ?? '',
      durationMs: (map['durationMs'] as num?)?.toInt() ?? 0,
      sizeBytes: (map['sizeBytes'] as num?)?.toInt() ?? 0,
      headers: headersParsed,
      bodyString: map['bodyString']?.toString() ?? '',
      isJson: map['isJson'] == true,
      isError: map['isError'] == true,
      errorMessage: map['errorMessage']?.toString(),
      timestamp: map['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
