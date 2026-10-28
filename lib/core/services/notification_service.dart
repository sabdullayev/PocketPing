import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);
    _isInitialized = true;
  }

  Future<void> showServerDownAlert({
    required String serverName,
    required String url,
    required int statusCode,
    String? error,
  }) async {
    final statusText = statusCode > 0 ? 'HTTP $statusCode' : (error ?? 'Connection Failed');

    const androidDetails = AndroidNotificationDetails(
      'pocketping_alerts',
      'Server Alerts',
      channelDescription: 'Notifications for down or unreachable servers',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _notificationsPlugin.show(
      id: id,
      title: '🚨 Server "$serverName" is DOWN!',
      body: 'Status: $statusText ($url)',
      notificationDetails: notificationDetails,
    );
  }
}
