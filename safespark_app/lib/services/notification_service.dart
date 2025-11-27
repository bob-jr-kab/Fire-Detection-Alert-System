import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/socket_service.dart';
// import '../screens/fire_alert_screen.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static BuildContext? _context;
  static Function(Alert)? _onNotificationTap;
  static Alert? _currentRealAlert;

  /// Call this in initState before using notifications
  static Future<void> initialize(
    BuildContext context, {
    Function(Alert)? onNotificationTap,
    Alert? currentAlert, // Optional: pass current alert directly
  }) async {
    _context = context;
    _onNotificationTap = onNotificationTap;

    if (currentAlert != null) {
      _currentRealAlert = currentAlert;
    }

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
        // Use the stored REAL alert data
        if (_currentRealAlert != null) {
          print("🎯 Using REAL alert data for notification tap");
          _onNotificationTap!(_currentRealAlert!);
        } else {
          // Fallback
          print("⚠️ No real alert data available, using fallback");
          final fallbackAlert = Alert(
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
          _onNotificationTap!(fallbackAlert);
        }
      },
    );
  }

  static void updateCurrentAlert(Alert alert) {
    _currentRealAlert = alert;
  }

  static Future<void> showFireNotification({
    required String title,
    required String body,
    Alert? alert,
  }) async {
    if (alert != null) {
      updateCurrentAlert(alert);
    }

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
  }
}
