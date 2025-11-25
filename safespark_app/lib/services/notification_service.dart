import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/socket_service.dart';
import '../screens/fire_alert_screen.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static BuildContext? _context;
  static Function(Alert)? _onNotificationTap;

  /// Call this in initState before using notifications
  static Future<void> initialize(
    BuildContext context, {
    Function(Alert)? onNotificationTap,
  }) async {
    _context = context;
    _onNotificationTap = onNotificationTap;

    // Request runtime permission (Android 13+)
    final status = await Permission.notification.request();
    if (!status.isGranted) {
      print("⚠️ Notification permission not granted");
    }

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('notification');

    final InitializationSettings settings = InitializationSettings(
      android: androidInit,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Create a mock alert for the notification tap
        final alert = Alert(
          deviceId: 'notification_device',
          deviceName: 'Fire Detection System',
          data: SensorData(
            deviceId: 'notification_device',
            temperature: 45.0,
            humidity: 30.0,
            smoke: 700.0,
            flameDetected: true,
            lastUpdated: DateTime.now(),
            deviceName: 'Fire Detection System',
          ),
          timestamp: DateTime.now(),
        );

        // Use the callback or navigate directly
        if (_onNotificationTap != null) {
          _onNotificationTap!(alert);
        } else if (_context != null && _context!.mounted) {
          Navigator.of(_context!).push(
            MaterialPageRoute(
              builder: (context) => FireAlertScreen(alert: alert),
            ),
          );
        }
      },
    );

    print("✅ Notification plugin initialized");
  }

  static Future<void> showFireNotification({
    required String title,
    required String body,
    Alert? alert, // Optional alert data
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'firesafety_alerts',
          'Fire Alerts',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          color: Colors.red,
          icon: 'notification',
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(1, title, body, details);
    print("🚨 Notification shown: $title");
  }
}
