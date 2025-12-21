import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../components/add_device_modal.dart';
import '../screens/settings_page.dart';
import '../services/notification_service.dart';
import '../services/socket_service.dart';
import '../services/alert_service.dart';
import '../screens/fire_alert_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SocketService socketService;

  // STATE variables
  List<Device> _devices = [];
  String? _selectedDeviceId;
  final Map<String, SensorData> _allSensorData = {};
  bool _showAddModal = false;
  bool _isLoading = true;

  Alert? _currentCriticalAlert; // Store the current critical alert
  SensorData? get current =>
      _selectedDeviceId != null ? _allSensorData[_selectedDeviceId] : null;

  // Convenience alias and selector for external use in this state
  SensorData? get currentSensorData => current;

  Device? get selectedDevice {
    if (_selectedDeviceId == null) return null;
    try {
      return _devices.firstWhere((d) => d.id == _selectedDeviceId);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    NotificationService.initialize(
      context,
      onNotificationTap: _handleNotificationTap,
    );

    _initApp(); // ✅ new
  }

  Future<void> _initApp() async {
    await _loadDevicesAndSelection(); // WAIT for devices
    _setupSocket(); // THEN connect socket
  }

  void _handleNotificationTap(Alert alert) {
    // Use the stored current alert if available, otherwise use the passed one
    final alertToUse = _currentCriticalAlert ?? alert;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FireAlertScreen(alert: alertToUse),
      ),
    );
  }

  // --- PERSISTENCE LOGIC (unchanged) ---
  Future<void> _loadDevicesAndSelection() async {
    final prefs = await SharedPreferences.getInstance();
    List<Device> loadedDevices = [];
    String? loadedSelectedId;

    try {
      final storedDevices = prefs.getString('devices');
      if (storedDevices != null) {
        final List<dynamic> list = jsonDecode(storedDevices);
        loadedDevices = list.map((item) => Device.fromJson(item)).toList();
      }
      loadedSelectedId = prefs.getString('selectedDeviceId');

      if (loadedSelectedId != null &&
          !loadedDevices.any((d) => d.id == loadedSelectedId)) {
        loadedSelectedId = null;
      }
      if (loadedSelectedId == null && loadedDevices.isNotEmpty) {
        loadedSelectedId = loadedDevices.first.id;
      }
    } catch (e) {
      print("Error loading data from SharedPreferences: $e");
    }

    setState(() {
      _devices = loadedDevices;
      _selectedDeviceId = loadedSelectedId;
      _isLoading = false;
    });
  }

  Future<void> _saveDevices(List<Device> updatedDevices) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('devices', jsonEncode(updatedDevices));
    setState(() => _devices = updatedDevices);
  }

  Future<void> _saveSelectedDeviceId(String? deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    if (deviceId != null) {
      await prefs.setString('selectedDeviceId', deviceId);
    } else {
      await prefs.remove('selectedDeviceId');
    }
    setState(() => _selectedDeviceId = deviceId);
  }

  // --- WEBSOCKET & DATA HANDLING ---
  void _setupSocket() {
    socketService = SocketService();

    socketService.onConnected = () => print("WebSocket Connected");
    socketService.onDisconnected = () => print("WebSocket Disconnected");

    socketService.onData = (data) {
      if (!mounted) return;

      print("Received sensor data: $data");

      final String deviceId = data['device_id'] as String;
      final String? incomingToken = data['pairingToken'] as String?;

      // Find if we already own this device
      final Device? ownedDevice = _devices.cast<Device?>().firstWhere(
        (d) => d?.id == deviceId,
        orElse: () => null,
      );

      // SECURITY CHECK: Only accept data from devices we own AND token matches
      if (ownedDevice == null ||
          ownedDevice.pairingToken == null ||
          ownedDevice.pairingToken != incomingToken) {
        print("Ignoring unowned or token-mismatched device: $deviceId");
        return; // Critical: ignore completely
      }

      // SUCCESS: This is OUR device → safe to process
      final incoming = SensorData(
        deviceId: deviceId,
        temperature: (data['temperature'] as num?)?.toDouble() ?? 0.0,
        humidity: (data['humidity'] as num?)?.toDouble() ?? 0.0,
        smoke: (data['smokeLevel'] as num?)?.toDouble() ?? 0.0,
        flameDetected: data['flameDetected'] as bool? ?? false,
        lastUpdated: DateTime.now(),
        deviceName: ownedDevice.name, // Use saved name (most reliable)
        ipAddress: data['ipAddress'] as String?,
      );

      // Critical alert detection
      if (incoming.flameDetected ||
          incoming.smoke > 800 ||
          incoming.temperature > 45) {
        final alert = Alert(
          deviceId: deviceId,
          deviceName: incoming.deviceName ?? ownedDevice.name,
          data: incoming,
          timestamp: DateTime.now(),
        );

        final String title = incoming.flameDetected && incoming.smoke > 800
            ? "Fire Detected"
            : incoming.flameDetected
            ? "Flame Detected"
            : "Smoke Detected";

        NotificationService.showFireNotification(
          title: "🔥 Fire Detected",
          body: "Immediate action required from ${incoming.deviceName}!",
          alert: alert,
        );

        // Optional: Store as current critical alert
        _currentCriticalAlert = alert;
      }

      // Update UI with fresh sensor data
      setState(() {
        _allSensorData[deviceId] = incoming;
      });

      // Optional: Auto-select this device if nothing is selected
      if (_selectedDeviceId == null || _selectedDeviceId!.isEmpty) {
        _saveSelectedDeviceId(deviceId);
      }
    };

    socketService.connect();
  }

  // --- DEVICE MANAGEMENT LOGIC (unchanged) ---

  Future<void> _handleDeviceAdded(Device newDevice) async {
    if (_devices.any((d) => d.id == newDevice.id)) return;

    final updatedDevices = [..._devices, newDevice];
    await _saveDevices(updatedDevices);

    // Only set as selected if nothing is selected yet, or if this is the only device
    if (_selectedDeviceId == null || _devices.isEmpty) {
      await _saveSelectedDeviceId(newDevice.id);
    }
  }

  void _onDeviceAdded(Map<String, String> device) {
    final newDevice = Device(
      id: device['id']!,
      name: device['name']!,
      pairingToken: device['pairingToken'], // ← THIS WAS MISSING!
    );
    _handleDeviceAdded(newDevice);
  }

  Future<void> _removeDevice(String deviceIdToRemove) async {
    // Get device data before removal for the forget command
    final deviceData = _allSensorData[deviceIdToRemove];
    final ipAddress = deviceData?.ipAddress;

    // 1. Optionally send forget command (handle errors gracefully)
    if (ipAddress != null && ipAddress.isNotEmpty) {
      print('Attempting to send forget command to device at IP: $ipAddress');
      try {
        final response = await http
            .post(
              Uri.parse('http://$ipAddress/api/forget-wifi'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({"forget": true}),
            )
            .timeout(const Duration(seconds: 5));

        print(
          "Forget command response: ${response.statusCode} ${response.body}",
        );
      } catch (e) {
        print('Forget command failed (this is OK if device is offline): $e');
      }
    }

    // 2. Update local state regardless of network command success
    final updatedDevices = _devices
        .where((d) => d.id != deviceIdToRemove)
        .toList();

    await _saveDevices(updatedDevices); // Persist to SharedPreferences
    _allSensorData.remove(deviceIdToRemove); // Clear sensor data

    // 3. Update selected device
    if (_selectedDeviceId == deviceIdToRemove) {
      final newSelectedId = updatedDevices.isNotEmpty
          ? updatedDevices.first.id
          : null;
      await _saveSelectedDeviceId(newSelectedId);
    }

    setState(() {}); // Trigger UI rebuild
  }

  // --- ALERT BUTTON LOGIC (unchanged) ---
  void _handleAlert() {
    if (currentSensorData != null && _selectedDeviceId != null) {
      AlertService().sendAlert(
        context,
        sensor: currentSensorData!,
        deviceId: _selectedDeviceId!,
      );
    }
  }

  void _openAddModal() {
    setState(() => _showAddModal = true);
  }

  void _closeAddModal() {
    setState(() => _showAddModal = false);
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset("assets/images/logo.png", height: 48),
              const SizedBox(width: 10),
              const Text(
                "SafeSpark",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Settings/Menu button
          GestureDetector(
            onTap: () {
              // 💡 ACTION: Navigate to SettingsPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.settings, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 15),
          const Text(
            "No Devices Added Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 125, 120, 147),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Connect your first sensor device to start monitoring.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _openAddModal,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("Add New Device"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 125, 120, 147),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 💡 Use a CircularProgressIndicator
          CircularProgressIndicator(color: Theme.of(context).primaryColor),
          const SizedBox(height: 20),
          Text(
            "Connecting to device and loading sensor data...",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _deviceDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDeviceId,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          hint: const Text("Select a Device"),
          onChanged: (String? newValue) {
            if (newValue != null) {
              _saveSelectedDeviceId(newValue);
            }
          },
          items: _devices.map<DropdownMenuItem<String>>((Device device) {
            return DropdownMenuItem<String>(
              value: device.id,
              child: Text(device.name, style: const TextStyle(fontSize: 16)),
            );
          }).toList(),
        ),
      ),
    );
  }

  // UPDATED: _sensorCard with info icon and popover functionality
  Widget _sensorCard({
    required String title,
    required String value,
    required String icon,
    required String infoText, // Added info text parameter
    bool highlight = false,
    bool grey = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: grey
            ? Colors.grey.shade100
            : highlight
            ? Colors.red.shade50
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: Colors.red.shade100,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
        border: Border.all(
          color: highlight ? Colors.red.shade400 : Colors.grey.shade200,
        ),
      ),
      child: Stack(
        children: [
          // Info icon positioned at top right
          Positioned(
            top: 8,
            right: 8,
            child: Tooltip(
              message: infoText,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(color: Colors.white, fontSize: 14),
              child: GestureDetector(
                onTap: () {
                  // Alternative: Show a dialog if you prefer over tooltip
                  _showInfoDialog(title, infoText);
                },
                child: Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),

          // Main content
          Row(
            children: [
              Image.asset(
                icon,
                height: 40,
                width: 40,
                color: highlight ? Colors.red.shade400 : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: highlight ? Colors.red.shade600 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Alternative method to show info in a dialog (more like React Native popover)
  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // --- WIDGET BUILD & DISPOSE (unchanged) ---

  @override
  Widget build(BuildContext context) {
    final bool hasDevice = _devices.isNotEmpty && _selectedDeviceId != null;
    final String lastUpdatedTime = current != null
        ? _formatTime(current!.lastUpdated)
        : _formatTime(DateTime.now());

    return Stack(
      children: [
        // Background
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 220,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8C79E6), Color(0xFFD87CB9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Main Scaffold/Content
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                _header(),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(26),
                      ),
                    ),
                    child: hasDevice
                        ? _mainContent(lastUpdatedTime)
                        : _emptyState(),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 💡 ADD THE ADD DEVICE MODAL TO THE STACK
        AddDeviceModal(
          visible: _showAddModal,
          onClose: _closeAddModal,
          onDeviceAdded: _onDeviceAdded,
        ),
      ],
    );
  }

  Widget _mainContent(String lastUpdatedTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Last updated + add button
        Row(
          children: [
            Text(
              "Last Updated: $lastUpdatedTime",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _openAddModal, // Triggers modal visibility
              child: Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 125, 120, 147),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: _deviceDropdown()),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                if (_selectedDeviceId != null) {
                  _removeDevice(_selectedDeviceId!);
                }
              },
              child: Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (_isLoading) // Show loading if data hasn't finished loading from prefs
          Expanded(child: _loadingIndicator())
        else if (current != null) ...[
          // Show sensor cards when data is available
          _sensorCard(
            title: "Temperature",
            value: "${current!.temperature.toStringAsFixed(1)}°C",
            icon: "assets/images/Temperature.png",
            infoText:
                "Normal: 20-26°C. High temps > 40°C can indicate fire risk.",
            highlight: current!.temperature > 40.0,
          ),
          const SizedBox(height: 14),
          _sensorCard(
            title: "Humidity",
            value: "${current!.humidity.toStringAsFixed(1)} %",
            icon: "assets/images/humidity.png",
            infoText:
                "Measures moisture in the air. Very low humidity can increase static electricity.",
            highlight: false,
          ),
          const SizedBox(height: 14),
          _sensorCard(
            title: "Smoke",
            value: "${current!.smoke.toStringAsFixed(0)} ppm",
            icon: "assets/images/cigarrete.png",
            infoText:
                "Detects smoke particles (ppm). Levels above 800 ppm are considered dangerous.",
            highlight: current!.smoke > 800,
          ),
          const SizedBox(height: 14),
          _sensorCard(
            title: "Flame",
            value: current!.flameDetected
                ? "Flame detected"
                : "No flame detected",
            icon: current!.flameDetected
                ? "assets/images/flame.png"
                : "assets/images/flame_gray.png",
            infoText:
                "This sensor looks for the infrared signature of a direct flame.",
            highlight: current!.flameDetected,
            grey: !current!.flameDetected,
          ),
        ] else
          // Show a placeholder if no sensor data is received yet
          const Expanded(
            child: Center(
              child: Text(
                "Waiting for initial sensor data from the device...",
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        const Spacer(),
        Center(
          child: GestureDetector(
            onTap: _handleAlert,
            child: Container(
              height: 95,
              width: 95,
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  "Alert",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  void dispose() {
    socketService.dispose();
    super.dispose();
  }
}
