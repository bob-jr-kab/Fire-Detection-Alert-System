// // lib/services/local_notification_service.dart

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class LocalNotificationService {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> init() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//           requestAlertPermission: true,
//           requestBadgePermission: true,
//           requestSoundPermission: true,
//         );

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//           android: initializationSettingsAndroid,
//           iOS: initializationSettingsIOS,
//         );

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);

//     // Create a high-importance channel for Android Fire Alerts
//     final AndroidNotificationChannel fireAlertChannel =
//         AndroidNotificationChannel(
//           'fire-alerts', // id
//           'Fire Alerts', // title
//           description: 'Critical alerts for flame and smoke detection.',
//           importance: Importance.max,
//           sound: const RawResourceAndroidNotificationSound('default'),
//           // FIX: Remove vibrationPattern and let system handle it
//           enableVibration: true,
//         );

//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(fireAlertChannel);
//   }

//   Future<void> showFireAlert({
//     required String deviceId,
//     required String deviceName,
//   }) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//           'fire-alerts',
//           'Fire Alerts',
//           channelDescription: 'Critical alerts for flame and smoke detection.',
//           importance: Importance.max,
//           priority: Priority.high,
//           ticker: 'ticker',
//           fullScreenIntent: true,
//           enableVibration: true, // Enable vibration without custom pattern
//         );

//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: DarwinNotificationDetails(
//         sound: 'default',
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       ),
//     );

//     await flutterLocalNotificationsPlugin.show(
//       0,
//       '🔥 Fire Alert!',
//       'Device $deviceName detected a flame!',
//       platformChannelSpecifics,
//       payload: deviceId,
//     );
//   }
// }
