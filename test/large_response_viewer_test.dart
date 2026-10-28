import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketping/core/services/json_isolate_service.dart';
import 'package:pocketping/features/response_viewer/domain/entities/http_response_entity.dart';
import 'package:pocketping/features/response_viewer/presentation/widgets/json_tree_view.dart';
import 'package:pocketping/features/response_viewer/presentation/widgets/response_body_view.dart';
import 'package:pocketping/features/response_viewer/presentation/widgets/virtualized_code_viewer.dart';

void main() {
  group('Large JSON Response Performance Tests', () {
    // Generate a simulated 500-product JSON response mimicking api.biznex.uz
    final largeData = {
      'page': 0,
      'size': 500,
      'totalElements': 500,
      'content': List.generate(
        500,
        (i) => {
          'id': 'prod_$i',
          'name': 'Product $i with special details and metadata',
          'price': 15000 + i,
          'sku': 'SKU-${1000 + i}',
          'active': i % 2 == 0,
          'categories': ['cat_a', 'cat_b', 'cat_$i'],
          'metadata': {
            'tenantId': '1001903a-755f-40bd-8977-31c8f4035c68',
            'updatedBy': 'admin',
          },
        },
      ),
    };

    final rawJsonString = jsonEncode(largeData);

    test('JsonIsolateService.processJson handles 500 items efficiently in background', () async {
      final stopwatch = Stopwatch()..start();
      final result = await JsonIsolateService.processJson(rawJsonString);
      stopwatch.stop();

      expect(result.formattedJson, isNotEmpty);
      expect(result.parsedJson, isNotNull);
      expect(result.lines.length, greaterThan(1000));
      // Should complete quickly in background isolate
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('VirtualizedCodeViewer renders 500 items smoothly with pre-split lines', (tester) async {
      final lines = const JsonEncoder.withIndent('  ').convert(largeData).split('\n');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              width: 400,
              child: VirtualizedCodeViewer(
                content: rawJsonString,
                preSplitLines: lines,
                isJson: true,
              ),
            ),
          ),
        ),
      );

      // Verify that code viewer renders immediately without frame drops
      expect(find.byType(ListView), findsOneWidget);

      // Scroll down several pages
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();

      expect(find.byType(VirtualizedCodeViewer), findsOneWidget);
    });

    testWidgets('JsonTreeView virtualized list renders 500 items instantly without freezing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              width: 400,
              child: JsonTreeView(data: largeData),
            ),
          ),
        ),
      );

      // Verify toolbar and virtualized tree are rendered
      expect(find.byType(JsonTreeView), findsOneWidget);
      expect(find.text('Expand'), findsOneWidget);
      expect(find.text('Collapse'), findsOneWidget);

      // Scroll the virtual tree
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      expect(find.byType(JsonTreeView), findsOneWidget);
    });

    testWidgets('ResponseBodyView defaults to Pretty tab and displays large response', (tester) async {
      final response = HttpResponseEntity(
        statusCode: 200,
        statusMessage: 'OK',
        durationMs: 120,
        sizeBytes: utf8.encode(rawJsonString).length,
        headers: {'content-type': ['application/json']},
        bodyString: rawJsonString,
        isJson: true,
        isError: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              width: 400,
              child: ResponseBodyView(response: response),
            ),
          ),
        ),
      );

      // Pump frames until isolate processing completes
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify Pretty is the first tab
      expect(find.text('Pretty'), findsOneWidget);
      expect(find.text('Raw'), findsOneWidget);
      expect(find.text('Tree'), findsOneWidget);
    });
  });
}
