import 'dart:convert';
import 'dart:isolate';

class JsonIsolateService {
  /// Formats raw JSON string into pretty indented JSON without blocking the UI thread
  static Future<String> formatJson(String rawJson) async {
    if (rawJson.trim().isEmpty) return '';
    try {
      return await Isolate.run(() {
        final decoded = jsonDecode(rawJson);
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(decoded);
      });
    } catch (_) {
      return rawJson;
    }
  }

  /// Parses JSON string to dynamic Map or List in a background isolate
  static Future<dynamic> parseJson(String rawJson) async {
    if (rawJson.trim().isEmpty) return null;
    try {
      return await Isolate.run(() {
        return jsonDecode(rawJson);
      });
    } catch (_) {
      return null;
    }
  }
}
