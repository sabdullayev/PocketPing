import 'package:equatable/equatable.dart';

class HttpResponseEntity extends Equatable {
  final int statusCode;
  final String statusMessage;
  final int durationMs;
  final int sizeBytes;
  final Map<String, List<String>> headers;
  final String bodyString;
  final bool isJson;
  final bool isError;
  final String? errorMessage;
  final DateTime timestamp;

  HttpResponseEntity({
    required this.statusCode,
    required this.statusMessage,
    required this.durationMs,
    required this.sizeBytes,
    required this.headers,
    required this.bodyString,
    required this.isJson,
    this.isError = false,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  String get formattedDuration {
    if (durationMs < 1000) {
      return '$durationMs ms';
    } else {
      return '${(durationMs / 1000).toStringAsFixed(2)} s';
    }
  }

  @override
  List<Object?> get props => [
        statusCode,
        statusMessage,
        durationMs,
        sizeBytes,
        headers,
        bodyString,
        isJson,
        isError,
        errorMessage,
        timestamp,
      ];
}
