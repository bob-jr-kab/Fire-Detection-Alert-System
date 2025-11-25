import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/socket_service.dart';

class AlertService {
  final String _serverUrl = dotenv.env['API_URL'] ?? '';

  /// Call this from anywhere:
  /// AlertService().sendAlert(context, sensorData, deviceId);
  Future<void> sendAlert(
    BuildContext context, {
    required SensorData sensor,
    required String deviceId,
  }) async {
    try {
      // 1. Load user info
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString("name") ?? "Unknown User";
      final apartment = prefs.getString("apartment") ?? "N/A";
      final address = prefs.getString("address") ?? "N/A";
      final district = prefs.getString("district") ?? "N/A";

      final lon = prefs.getDouble("longitude");
      final lat = prefs.getDouble("latitude");

      if (lon == null || lat == null) {
        _show(context, "❌ Location data is missing. Enable GPS.");
        return;
      }

      final payload = {
        "location": [lon, lat],
        "address": {
          "apartment": apartment,
          "street": address,
          "district": district,
        },
        "temperature": sensor.temperature,
        "smokeLevel": sensor.smoke.toString(),
        "device_id": deviceId,
        "name": name,
        "humidity": sensor.humidity,
        "flameDetected": sensor.flameDetected,
        if (sensor.deviceName != null) "device_name": sensor.deviceName,
        if (sensor.ipAddress != null) "ipAddress": sensor.ipAddress,
      };

      print("Sending alert: $payload");

      final response = await http.post(
        Uri.parse("$_serverUrl/api/fire-alerts/confirm-alert"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode(payload),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _show(context, "🔥 Alert sent successfully!");
      } else {
        _show(context, "❌ ${result['message'] ?? 'Could not send the alert.'}");
      }
    } catch (e) {
      print("Alert error: $e");
      _show(context, "❌ Network Error. Check your internet connection.");
    }
  }

  void _show(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
