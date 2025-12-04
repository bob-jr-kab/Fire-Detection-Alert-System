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

class _FireAlertScreenState extends State<FireAlertScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<Color?> _colorAnimation;

  String _emergencyNumber = '199';
  bool _isLoadingNumber = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyNumber();

    // Blinking animation: fast red ↔ dark red
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true); // This makes it blink forever

    _colorAnimation = ColorTween(
      begin: Colors.red.shade900,
      end: Colors.red.shade400,
    ).animate(_blinkController);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  Future<void> _loadEmergencyNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final number = prefs.getString("emergencyNumber");

    if (mounted) {
      setState(() {
        _emergencyNumber = number ?? '199';
        _isLoadingNumber = false;
      });
    }
  }

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: _emergencyNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not call $_emergencyNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _colorAnimation.value, // BLINKING BACKGROUND
          appBar: AppBar(
            title: const Text(
              "EMERGENCY ALERT",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white38, width: 2),
                ),
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Flashing fire icon
                    Container(
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: Image.asset(
                        'assets/images/fire.gif',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Blinking title
                    Text(
                      "CRITICAL FIRE DETECTED",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        shadows: const [
                          Shadow(
                            color: Colors.red,
                            blurRadius: 20,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "Immediate action required from '${widget.alert.deviceName}'!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.yellow.shade200,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ALERT BUTTON (Yellow - high contrast)
                    ElevatedButton.icon(
                      onPressed: () {
                        AlertService().sendAlert(
                          context,
                          sensor: widget.alert.data,
                          deviceId: widget.alert.deviceId,
                        );
                      },
                      icon: const Icon(
                        Icons.emergency,
                        size: 32,
                        color: Colors.black,
                      ),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 22),
                        child: Text(
                          "ALERT EMERGENCY SERVICES",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade600,
                        foregroundColor: Colors.black,
                        elevation: 12,
                        shadowColor: Colors.yellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CALL BUTTON (Green - visible on red)
                    ElevatedButton.icon(
                      onPressed: _isLoadingNumber ? null : _makePhoneCall,
                      icon: const Icon(Icons.call, size: 32),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        child: _isLoadingNumber
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "CALL $_emergencyNumber NOW",
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white54,
                                ),
                              ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen.shade600,
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "I Confirm It's Safe (Dismiss)",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
