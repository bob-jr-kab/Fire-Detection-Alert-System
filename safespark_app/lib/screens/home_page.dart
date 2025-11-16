import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../components/add_device_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ----------------------------
  // DEVICE + SENSOR DATA
  // ----------------------------
  final List<Device> _devices = [
    Device(id: 'D001', name: 'Living Room', roomName: ""),
    Device(id: 'D002', name: 'Kitchen', roomName: ""),
  ];

  String? _selectedDeviceId = 'D001';

  final Map<String, SensorData> _sensor = {
    'D001': SensorData(
      deviceId: 'D001',
      temperature: 38.7,
      humidity: 28.10,
      smoke: 145,
      flameDetected: false,
      lastUpdated: DateTime.now(),
      roomName: 'Living Room',
    ),
  };

  SensorData? get current =>
      _selectedDeviceId != null ? _sensor[_selectedDeviceId] : null;

  // ----------------------------
  // MODAL VISIBILITY
  // ----------------------------
  bool showAddModal = false;

  void _openAddModal() {
    setState(() => showAddModal = true);
  }

  void _closeAddModal() {
    setState(() => showAddModal = false);
  }

  // Add device callback from modal
  void _onDeviceAdded(Map<String, String> device) {
    setState(() {
      _devices.add(
        Device(id: device['id']!, name: device['name']!, roomName: ""),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // BACKGROUND GRADIENT
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

        // MAIN CONTENT
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // ---------------------------------------
                // HEADER
                // ---------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/images/logo.png", height: 48),
                      const SizedBox(width: 10),
                      const Text(
                        "SafeSpark",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),

                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/settings');
                        },

                        child: const Icon(
                          Icons.settings,
                          size: 26,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ---------------------------------------
                // WHITE CONTENT PANEL
                // ---------------------------------------
                Expanded(
                  child: Container(
                    width: double.infinity,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------------------------------------
                        // LAST UPDATED + ADD BUTTON (NEW)
                        // ---------------------------------------
                        Row(
                          children: [
                            Text(
                              "Last Updated: ${_formatTime(current!.lastUpdated)}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const Spacer(),

                            // ADD BUTTON MOVED HERE
                            GestureDetector(
                              onTap: _openAddModal,
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ---------------------------------------
                        // DROPDOWN + DELETE BUTTON
                        // ---------------------------------------
                        Row(
                          children: [
                            Expanded(child: _deviceDropdown()),
                            const SizedBox(width: 10),

                            // DELETE ICON
                            GestureDetector(
                              onTap: () {
                                print("DELETE device logic goes here");
                              },
                              child: Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ---------------------------------------
                        // SENSOR CARDS
                        // ---------------------------------------
                        _sensorCard(
                          title: "Temperature",
                          value: "${current!.temperature}°C",
                          icon: "assets/images/Temperature.png",
                          highlight: true,
                        ),
                        const SizedBox(height: 14),

                        _sensorCard(
                          title: "Humidity",
                          value: "${current!.humidity} %",
                          highlight: true,
                          icon: "assets/images/humidity.png",
                        ),
                        const SizedBox(height: 14),

                        _sensorCard(
                          title: "Smoke",
                          value: "${current!.smoke} ppm",
                          icon: "assets/images/cigarrete.png",
                          highlight: true,
                        ),
                        const SizedBox(height: 14),

                        _sensorCard(
                          title: "Flame",
                          value: current!.flameDetected
                              ? "Flame detected"
                              : "No flame detected",
                          icon: current!.flameDetected
                              ? "assets/images/flame.png"
                              : "assets/images/flame_gray.png", // use gray icon if no flame
                          highlight:
                              current!.flameDetected, // RED text if detected
                          grey:
                              !current!.flameDetected, // gray text if no flame
                        ),

                        const Spacer(),

                        // ---------------------------------------
                        // ALERT BUTTON
                        // ---------------------------------------
                        Center(
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

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ---------------------------------------
        // ADD DEVICE MODAL OVERLAY
        // ---------------------------------------
        AddDeviceModal(
          visible: showAddModal,
          onClose: _closeAddModal,
          onDeviceAdded: _onDeviceAdded,
        ),
      ],
    );
  }

  // ---------------------------------------
  // DROPDOWN
  // ---------------------------------------
  Widget _deviceDropdown() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDeviceId,
          isExpanded: true,
          items: _devices
              .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
              .toList(),
          onChanged: (val) => setState(() => _selectedDeviceId = val),
        ),
      ),
    );
  }

  // ---------------------------------------
  // SENSOR CARD
  // ---------------------------------------
  Widget _sensorCard({
    required String title,
    required String value,
    required String icon,
    bool highlight = false,
    bool grey = false,
  }) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEEF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(icon, height: 25),
                    const SizedBox(width: 10),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        color: highlight
                            ? Colors.red
                            : grey
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------
  // TIME FORMATTER
  // ---------------------------------------
  String _formatTime(DateTime dt) {
    return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
  }
}
