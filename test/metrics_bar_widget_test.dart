import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketping/features/response_viewer/domain/entities/http_response_entity.dart';
import 'package:pocketping/features/response_viewer/presentation/widgets/metrics_bar_widget.dart';

void main() {
  group('MetricsBarWidget Close Button and Layout Tests', () {
    testWidgets('Renders status code, time, size, and close button', (tester) async {
      bool closed = false;
      final response = HttpResponseEntity(
        statusCode: 404,
        statusMessage: 'Not Found',
        headers: const {'content-type': ['application/json']},
        bodyString: '{}',
        durationMs: 1980,
        sizeBytes: 2,
        isJson: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricsBarWidget(
              response: response,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify status, time, size
      expect(find.text('404 Not Found'), findsOneWidget);
      expect(find.text('1.98 s'), findsOneWidget);
      expect(find.text('2 B'), findsOneWidget);

      // Verify close button is present
      final closeBtnFinder = find.byKey(const Key('close_response_button'));
      expect(closeBtnFinder, findsOneWidget);

      // Tap close button
      await tester.tap(closeBtnFinder);
      await tester.pump();

      expect(closed, isTrue);
    });

    testWidgets('Does not render close button when onClose is null', (tester) async {
      final response = HttpResponseEntity(
        statusCode: 200,
        statusMessage: 'OK',
        headers: const {},
        bodyString: 'ok',
        durationMs: 250,
        sizeBytes: 2,
        isJson: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricsBarWidget(
              response: response,
              onClose: null,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('close_response_button')), findsNothing);
    });

    testWidgets('Does not overflow even on narrow 300px screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(300, 600));

      final response = HttpResponseEntity(
        statusCode: 500,
        statusMessage: 'Internal Server Error',
        headers: const {},
        bodyString: 'error',
        durationMs: 3500,
        sizeBytes: 15400,
        isJson: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricsBarWidget(
              response: response,
              onClose: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('close_response_button')), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });
  });
}
