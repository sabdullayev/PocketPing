import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketping/features/request_builder/domain/entities/request_body.dart';
import 'package:pocketping/features/request_builder/presentation/widgets/body_tab_view.dart';
import 'package:pocketping/features/request_builder/presentation/widgets/fullscreen_body_editor_dialog.dart';

void main() {
  group('BodyTabView Layout & Overflow Tests', () {
    testWidgets('BodyTabView does not overflow on small screen width (320px)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 600));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BodyTabView(
              body: const RequestBody(
                type: RequestBodyType.json,
                rawContent: '{\n  "name": "test"\n}',
              ),
              onTypeChanged: (_) {},
              onContentChanged: (_) {},
              onFormatJson: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that ChoiceChips and Beautify button are present
      expect(find.text('JSON'), findsOneWidget);
      expect(find.text('Raw Text'), findsOneWidget);
      expect(find.text('Beautify'), findsOneWidget);

      // Verify Fullscreen icon is present
      expect(find.byIcon(Icons.fullscreen), findsOneWidget);

      // Verify editor is rendered
      expect(find.byType(TextField), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('BodyTabView opens FullscreenBodyEditorDialog on fullscreen tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BodyTabView(
              body: const RequestBody(
                type: RequestBodyType.json,
                rawContent: '{\n  "fullscreen": true\n}',
              ),
              onTypeChanged: (_) {},
              onContentChanged: (_) {},
              onFormatJson: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap fullscreen icon
      await tester.tap(find.byIcon(Icons.fullscreen));
      await tester.pumpAndSettle();

      // Verify FullscreenBodyEditorDialog is open
      expect(find.byType(FullscreenBodyEditorDialog), findsOneWidget);
      expect(find.text('Body (JSON)'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('BodyTabView does not overflow on standard phone width (360px)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BodyTabView(
              body: const RequestBody(
                type: RequestBodyType.json,
                rawContent: '{\n  "foo": "bar"\n}',
              ),
              onTypeChanged: (_) {},
              onContentChanged: (_) {},
              onFormatJson: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('JSON'), findsOneWidget);
      expect(find.text('Beautify'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
