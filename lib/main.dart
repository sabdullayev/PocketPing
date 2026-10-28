import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/services/background_ping_service.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await NotificationService.instance.initialize();
  await BackgroundPingService.initialize();
  runApp(const PocketPingApp());
}
