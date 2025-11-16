class SensorData {
  final String deviceId;
  final double temperature;
  final double humidity;
  final double smoke;
  final bool flameDetected;
  final DateTime lastUpdated;
  final String roomName;

  SensorData({
    required this.deviceId,

    required this.temperature,
    required this.humidity,
    required this.smoke,
    required this.flameDetected,
    required this.lastUpdated,
    this.roomName = 'New room',
  });

  SensorData copyWith({
    String? deviceId,
    double? temperature,
    double? humidity,
    double? smoke,
    bool? flameDetected,
    DateTime? lastUpdated,
    String? roomName,
  }) {
    return SensorData(
      deviceId: deviceId ?? this.deviceId,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      smoke: smoke ?? this.smoke,
      flameDetected: flameDetected ?? this.flameDetected,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      roomName: roomName ?? this.roomName,
    );
  }
}

class Device {
  final String id;
  final String name;
  final String roomName;
  final bool isConnected;

  Device({
    required this.id,
    required this.name,
    required this.roomName,
    this.isConnected = false,
  });
}
