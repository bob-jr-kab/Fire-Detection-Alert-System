import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Call this in initState before using notifications
  static Future<void> initialize(BuildContext context) async {
    // Request runtime permission (Android 13+)
    final status = await Permission.notification.request();
    if (!status.isGranted) {
      print("⚠️ Notification permission not granted");
    }

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('notification'); // no @drawable/ prefix

    final InitializationSettings settings = InitializationSettings(
      android: androidInit,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        Navigator.of(context).pushNamed('/fire-alert');
      },
    );

    print("✅ Notification plugin initialized");
  }

  static Future<void> showFireNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'firesafety_alerts',
          'Fire Alerts',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          color: Colors.red,
          icon: 'notification', // Must exist in drawable folder
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(1, title, body, details);
    print("🚨 Notification shown: $title");
  }
}
