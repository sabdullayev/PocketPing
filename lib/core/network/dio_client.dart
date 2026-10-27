import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../../features/request_builder/domain/entities/http_request_entity.dart';
import '../../features/request_builder/domain/entities/request_body.dart';
import '../../features/response_viewer/domain/entities/http_response_entity.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 15),
        responseType: ResponseType.plain, // Raw string so we can measure exact bytes & parse in isolate
        validateStatus: (status) => true, // Don't throw for 4xx/5xx, return response
      ),
    );

    // Bypass SSL certificate check (essential for dev/self-signed mobile testing)
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  }

  Future<HttpResponseEntity> execute(HttpRequestEntity request) async {
    final uri = request.toUri();
    if (uri == null || uri.toString().isEmpty) {
      return HttpResponseEntity(
        statusCode: 0,
        statusMessage: 'Invalid URL',
        durationMs: 0,
        sizeBytes: 0,
        headers: {},
        bodyString: 'Error: The provided URL is invalid or malformed.',
        isJson: false,
        isError: true,
        errorMessage: 'Invalid URL',
      );
    }

    final stopwatch = Stopwatch()..start();
    try {
      dynamic data;
      if (request.body.type == RequestBodyType.json && request.body.rawContent.trim().isNotEmpty) {
        try {
          data = jsonDecode(request.body.rawContent);
        } catch (_) {
          // If invalid JSON, send as raw string
          data = request.body.rawContent;
        }
      } else if (request.body.type == RequestBodyType.raw) {
        data = request.body.rawContent;
      } else if (request.body.type == RequestBodyType.formData) {
        final formDataMap = <String, dynamic>{};
        for (final field in request.body.formDataFields) {
          if (field.isEnabled && field.key.isNotEmpty) {
            formDataMap[field.key] = field.value;
          }
        }
        data = FormData.fromMap(formDataMap);
      }

      final response = await _dio.requestUri(
        uri,
        data: data,
        options: Options(
          method: request.method.label,
          headers: request.getEffectiveHeaders(),
        ),
      );

      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;

      final bodyString = response.data?.toString() ?? '';
      final sizeBytes = utf8.encode(bodyString).length;

      // Extract response headers
      final headersMap = <String, List<String>>{};
      response.headers.forEach((name, values) {
        headersMap[name] = values;
      });

      final isJson = _checkIsJson(bodyString, response.headers.value('content-type'));

      return HttpResponseEntity(
        statusCode: response.statusCode ?? 200,
        statusMessage: response.statusMessage ?? 'OK',
        durationMs: duration,
        sizeBytes: sizeBytes,
        headers: headersMap,
        bodyString: bodyString,
        isJson: isJson,
        isError: (response.statusCode ?? 200) >= 400,
      );
    } on DioException catch (e) {
      stopwatch.stop();
      return _mapDioException(e, stopwatch.elapsedMilliseconds);
    } catch (e) {
      stopwatch.stop();
      return HttpResponseEntity(
        statusCode: 0,
        statusMessage: 'Client Error',
        durationMs: stopwatch.elapsedMilliseconds,
        sizeBytes: 0,
        headers: {},
        bodyString: e.toString(),
        isJson: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  bool _checkIsJson(String body, String? contentType) {
    if (contentType != null && contentType.toLowerCase().contains('application/json')) {
      return true;
    }
    final trimmed = body.trim();
    if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
      try {
        jsonDecode(trimmed);
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  HttpResponseEntity _mapDioException(DioException e, int elapsedMs) {
    final response = e.response;
    if (response != null) {
      final bodyString = response.data?.toString() ?? '';
      final headersMap = <String, List<String>>{};
      response.headers.forEach((name, values) {
        headersMap[name] = values;
      });

      return HttpResponseEntity(
        statusCode: response.statusCode ?? 0,
        statusMessage: response.statusMessage ?? e.type.name,
        durationMs: elapsedMs,
        sizeBytes: utf8.encode(bodyString).length,
        headers: headersMap,
        bodyString: bodyString,
        isJson: _checkIsJson(bodyString, response.headers.value('content-type')),
        isError: true,
        errorMessage: e.message,
      );
    }

    String errorMsg = e.message ?? 'Network connection error';
    if (e.type == DioExceptionType.connectionTimeout) {
      errorMsg = 'Connection timed out after 15 seconds';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      errorMsg = 'Response receive timed out after 20 seconds';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMsg = 'No internet connection or host unreachable';
    }

    return HttpResponseEntity(
      statusCode: 0,
      statusMessage: e.type.name,
      durationMs: elapsedMs,
      sizeBytes: utf8.encode(errorMsg).length,
      headers: {},
      bodyString: errorMsg,
      isJson: false,
      isError: true,
      errorMessage: errorMsg,
    );
  }
}
