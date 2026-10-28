import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:pocketping/app.dart';
import 'package:pocketping/core/di/injection_container.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = Directory.systemTemp.createTempSync('pocketping_test');
    await initDependencies(hivePath: tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('PocketPing smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PocketPingApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('PocketPing'), findsOneWidget);
    expect(find.text('cURL'), findsOneWidget);
    expect(find.text('Ping'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Collections'), findsOneWidget);
    expect(find.text('Monitor'), findsOneWidget);
  });
}
