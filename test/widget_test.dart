import 'package:flutter_test/flutter_test.dart';
import 'package:pocketping/app.dart';
import 'package:pocketping/core/di/injection_container.dart';

void main() {
  testWidgets('PocketPing smoke test', (WidgetTester tester) async {
    await initDependencies();
    await tester.pumpWidget(const PocketPingApp());

    expect(find.text('PocketPing'), findsOneWidget);
    expect(find.text('cURL'), findsOneWidget);
  });
}
