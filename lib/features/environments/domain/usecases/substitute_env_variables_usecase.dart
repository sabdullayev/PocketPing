import 'package:pocketping/features/request_builder/domain/entities/http_request_entity.dart';
import 'package:pocketping/features/request_builder/domain/entities/key_value_param.dart';
import '../entities/environment_entity.dart';

class SubstituteEnvVariablesUseCase {
  HttpRequestEntity call(HttpRequestEntity request, EnvironmentEntity? activeEnvironment) {
    if (activeEnvironment == null || activeEnvironment.variables.isEmpty) {
      return request;
    }

    final enabledVars = activeEnvironment.variables
        .where((v) => v.isEnabled && v.key.trim().isNotEmpty)
        .toList();

    if (enabledVars.isEmpty) return request;

    // Sort by key length descending so longer variable names get matched first
    enabledVars.sort((a, b) => b.key.trim().length.compareTo(a.key.trim().length));

    String replaceAllIn(String input) {
      String result = input;
      for (final v in enabledVars) {
        final key = RegExp.escape(v.key.trim());
        // Matches both {{key}} and {key}, with optional spaces like {{ key }} or { key }
        final regex = RegExp(r'\{\{?\s*' + key + r'\s*\}\}?');
        result = result.replaceAll(regex, v.value);
      }
      return result;
    }

    // 1. URL
    final updatedUrl = replaceAllIn(request.url);

    // 2. Query Parameters
    final updatedParams = request.queryParams.map((p) {
      return p.copyWith(
        key: replaceAllIn(p.key),
        value: replaceAllIn(p.value),
      );
    }).toList();

    // 3. Headers
    final updatedHeaders = request.headers.map((h) {
      return h.copyWith(
        key: replaceAllIn(h.key),
        value: replaceAllIn(h.value),
      );
    }).toList();

    // 4. Bearer Token
    final updatedToken = request.bearerToken != null ? replaceAllIn(request.bearerToken!) : null;

    // 5. Body
    final updatedBody = request.body.copyWith(
      rawContent: replaceAllIn(request.body.rawContent),
      formDataFields: request.body.formDataFields.map((f) {
        return KeyValueParam.raw(
          id: f.id,
          key: replaceAllIn(f.key),
          value: replaceAllIn(f.value),
          isEnabled: f.isEnabled,
        );
      }).toList(),
    );

    return request.copyWith(
      url: updatedUrl,
      queryParams: updatedParams,
      headers: updatedHeaders,
      bearerToken: updatedToken,
      body: updatedBody,
    );
  }
}
