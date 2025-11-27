import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/alert_service.dart';
import '../services/socket_service.dart';

class FireAlertScreen extends StatefulWidget {
  final Alert alert;

  const FireAlertScreen({super.key, required this.alert});

  @override
  State<FireAlertScreen> createState() => _FireAlertScreenState();
}

class _FireAlertScreenState extends State<FireAlertScreen> {
  // Default to a generic emergency number until SharedPreferences loads
  String _emergencyNumber = '199';
  bool _isLoadingNumber = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyNumber();
  }

  /// Loads the user-defined emergency number from SharedPreferences.
  Future<void> _loadEmergencyNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final number = prefs.getString("emergencyNumber");

    if (mounted) {
      setState(() {
        // Use the stored number or default to '911'
        _emergencyNumber = number ?? '199';
        _isLoadingNumber = false;
      });
    }
  }

  /// Opens the phone dialer with the loaded emergency number.
  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: _emergencyNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch dialer for $_emergencyNumber.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the most critical sensor data for display
    final SensorData data = widget.alert.data;
    final bool isCritical =
        data.flameDetected || data.smoke > 680 || data.temperature > 45;

    // Choose colors based on the severity, using red heavily
    final Color primaryColor = isCritical
        ? Colors.red.shade900
        : Colors.red.shade700;
    final Color confirmColor = Colors.yellow.shade600;
    final Color callColor = Colors.lightGreen.shade600;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text(
          "EMERGENCY ALERT",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white38),
            ),
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon and Main Title (Centered at the Top of the Container)
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 100,
                ),
                const SizedBox(height: 10),

                const Text(
                  "CRITICAL FIRE DETECTED",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 20),

                // Device and Location Info
                Text(
                  "Immediate action required! Detection from '${widget.alert.deviceName}'.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade100, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // 1. ALERT EMERGENCY SERVICES BUTTON (Confirms and Notifies - uses HomePage logic)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    // Calls the centralized service logic from the homepage
                    onPressed: () {
                      AlertService().sendAlert(
                        context,
                        sensor: widget.alert.data,
                        deviceId: widget.alert.deviceId,
                      );
                    },
                    icon: const Icon(
                      Icons.emergency,
                      size: 28,
                      color: Colors.black87,
                    ),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        "Alert Emergency Services",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. CALL EMERGENCY BUTTON (Opens Dialer with stored number)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingNumber ? null : _makePhoneCall,
                    icon: const Icon(Icons.call, size: 28, color: Colors.white),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: _isLoadingNumber
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Call $_emergencyNumber Now",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: callColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Dismiss Button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "I Confirm It's Safe (Dismiss Alert)",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
