import 'dart:convert';
import 'dart:isolate';

class ProcessedJsonResult {
  final String formattedJson;
  final dynamic parsedJson;
  final List<String> lines;

  const ProcessedJsonResult({
    required this.formattedJson,
    required this.parsedJson,
    required this.lines,
  });
}

class JsonIsolateService {
  /// Processes raw JSON in a single background isolate:
  /// Decodes once, generates indented pretty JSON, and pre-splits lines.
  /// Completely offloads CPU-intensive JSON work from the UI thread.
  static Future<ProcessedJsonResult> processJson(String rawJson) async {
    if (rawJson.trim().isEmpty) {
      return const ProcessedJsonResult(formattedJson: '', parsedJson: null, lines: []);
    }
    try {
      return await Isolate.run(() {
        final decoded = jsonDecode(rawJson);
        const encoder = JsonEncoder.withIndent('  ');
        final formatted = encoder.convert(decoded);
        final lines = formatted.split('\n');
        return ProcessedJsonResult(
          formattedJson: formatted,
          parsedJson: decoded,
          lines: lines,
        );
      });
    } catch (_) {
      final lines = rawJson.split('\n');
      return ProcessedJsonResult(
        formattedJson: rawJson,
        parsedJson: null,
        lines: lines,
      );
    }
  }

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
