// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// NOTE: Please replace this URL with the correct, current URL for your ngrok tunnel
final String _socketUrl = dotenv.env['API_URL'] ?? '';

// --- SensorData and Device Models (Now consolidated here) ---
class Alert {
  final String deviceId;
  final String deviceName;
  final SensorData data;
  final DateTime timestamp;

  const Alert({
    required this.deviceId,
    required this.deviceName,
    required this.data,
    required this.timestamp,
  });
}

class SensorData {
  final String deviceId;
  final double temperature;
  final double humidity;
  final double smoke;
  final bool flameDetected;
  final DateTime lastUpdated;
  final String? deviceName;
  final String? ipAddress;

  SensorData({
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    required this.smoke,
    required this.flameDetected,
    required this.lastUpdated,
    this.deviceName,
    this.ipAddress,
  });

  factory SensorData.fromWebSocketJson(Map<String, dynamic> json) {
    return SensorData(
      deviceId: json['device_id'] ?? json['deviceId'] ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      smoke: (json['smokeLevel'] as num?)?.toDouble() ?? 0.0,
      flameDetected: json['flameDetected'] as bool? ?? false,
      lastUpdated: DateTime.now(),
      deviceName: json['device_name'] as String?,
      ipAddress: json['ipAddress'] as String?,
    );
  }
}

class Device {
  final String id;
  final String name;

  Device({required this.id, required this.name});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(id: json['id'] as String, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

// --- Actual Socket Service Implementation ---

class SocketService {
  late IO.Socket socket;

  void Function()? onConnected;
  void Function()? onDisconnected;
  void Function(Map<String, dynamic>)? onData;

  SocketService() {
    // 1. Configure the Socket.IO client
    socket = IO.io(
      _socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // Use only WebSockets
          .disableAutoConnect() // Don't connect yet
          .setExtraHeaders({'ngrok-skip-browser-warning': 'true'}) // For ngrok
          .build(),
    );
  }

  void connect() {
    // 2. Set up connection handlers
    socket.onConnect((_) {
      debugPrint('WebSocket Connected successfully to $_socketUrl');
      if (onConnected != null) onConnected!();
    });

    socket.onDisconnect((_) {
      debugPrint('WebSocket Disconnected');
      if (onDisconnected != null) onDisconnected!();
    });

    socket.onError((error) {
      debugPrint('WebSocket Error: $error');
    });

    // 3. Listen for the 'sensor-data' event broadcast from the server
    socket.on('sensor-data', (data) {
      // Data received is typically a Map/JSON object
      if (data != null && onData != null) {
        // Ensure data is parsed correctly if it comes as a string (though usually it's a Map)
        if (data is String) {
          try {
            onData!(jsonDecode(data) as Map<String, dynamic>);
          } catch (e) {
            debugPrint('Failed to parse incoming socket data: $e');
          }
        } else if (data is Map) {
          onData!(Map<String, dynamic>.from(data));
        }
      }
    });

    // 4. Start the connection
    socket.connect();
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
  }
}
