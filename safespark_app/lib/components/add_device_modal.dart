import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Helper function definition for input decoration (if missing)
InputDecoration inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
  );
}

class AddDeviceModal extends StatefulWidget {
  final bool visible;
  final VoidCallback onClose;
  final Function(Map<String, String>) onDeviceAdded;

  const AddDeviceModal({
    super.key,
    required this.visible,
    required this.onClose,
    required this.onDeviceAdded,
  });

  @override
  State<AddDeviceModal> createState() => _AddDeviceModalState();
}

class _AddDeviceModalState extends State<AddDeviceModal> {
  int step = 1;

  final TextEditingController deviceName = TextEditingController();
  final TextEditingController homeSsid = TextEditingController();
  final TextEditingController homePassword = TextEditingController();

  bool loading = false;
  String errorMessage = "";
  bool isOpenNetwork = false; // NEW: Track if it's an open network

  // Constants for robust connectivity (CPD workaround)
  static const int _maxRetries = 3;
  static const Duration _initialDelay = Duration(seconds: 3);
  static const Duration _connectTimeout = Duration(seconds: 5);
  static const Duration _retryDelay = Duration(seconds: 1);

  static const String espIp = "192.168.4.1";

  void resetState() {
    setState(() {
      step = 1;
      deviceName.clear();
      homeSsid.clear();
      homePassword.clear();
      loading = false;
      errorMessage = "";
      isOpenNetwork = false; // Reset open network flag
    });
  }

  Future<void> sendCredentials() async {
    if (deviceName.text.trim().isEmpty || homeSsid.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Please fill Device Name and SSID fields.";
      });
      return;
    }

    // Only require password if it's NOT an open network
    if (!isOpenNetwork && homePassword.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Please enter Wi-Fi password for secured networks.";
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = "";
    });

    // 1. Initial Delay (Crucial for allowing OS routing to stabilize)
    await Future.delayed(_initialDelay);

    // Prepare form body - password is optional
    final Map<String, String> formBody = {
      "ssid": homeSsid.text.trim(),
      "deviceName": deviceName.text.trim(),
    };

    // Only add password if it's provided (not an open network)
    if (!isOpenNetwork && homePassword.text.trim().isNotEmpty) {
      formBody["password"] = homePassword.text.trim();
    }

    String finalErrorMessage =
        "Could not connect to the ESP32 (192.168.4.1). Ensure your phone is connected to the SafeSpark Wi-Fi network and try again.";
    bool success = false;

    // 2. Retry Loop
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      print('Attempting POST to ESP32, attempt $attempt...');
      print('Sending data: ${formBody.toString()}');

      try {
        final response = await http
            .post(
              Uri.parse("http://$espIp/config"),
              headers: {"Content-Type": "application/x-www-form-urlencoded"},
              body: formBody,
            )
            .timeout(_connectTimeout);

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result["deviceId"] != null) {
            widget.onDeviceAdded({
              "id": result["deviceId"],
              "name": deviceName.text.trim(),
            });
            success = true;
            setState(() => step = 3);
            break; // Success! Exit the loop.
          } else {
            // Server responded 200 but missing data (ESP32 logic error)
            finalErrorMessage =
                "Device successfully received credentials but did not return a valid Device ID. Check ESP32 logic.";
            break;
          }
        } else {
          // Server responded with an error HTTP status code
          final result = jsonDecode(response.body);
          finalErrorMessage =
              "Server responded with HTTP error ${response.statusCode}: ${result["message"] ?? 'Unknown error'}.";
        }
      } on TimeoutException {
        finalErrorMessage =
            "Connection timed out after multiple attempts. Is the device fully powered on?";
      } on SocketException {
        // This is the primary error from cellular fallback/no route to host
        finalErrorMessage =
            "Connection failed. Please verify you are connected to the SafeSpark Wi-Fi network.";
      } catch (e) {
        finalErrorMessage = "An unexpected error occurred: $e";
      }

      // Delay before next retry, only if not the last attempt
      if (!success && attempt < _maxRetries) {
        await Future.delayed(_retryDelay);
      }
    }

    // Final UI state update
    setState(() {
      loading = false;
      if (!success) {
        errorMessage = finalErrorMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return Stack(
      children: [
        // 🔥 BLURRED BACKGROUND
        Positioned.fill(
          child: GestureDetector(
            onTap: () {}, // prevents closing on outside tap
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
          ),
        ),

        // 🔥 MODAL WITH MATERIAL WRAP
        Center(
          child: Material(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(25),
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxHeight: 600),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // CLOSE BUTTON
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.grey,
                        size: 28,
                      ),
                      onPressed: () {
                        widget.onClose(); // Call external close
                        resetState(); // Reset internal state
                      },
                    ),
                  ),

                  // MODAL CONTENT
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Add New Device",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // STEP 1
                      if (step == 1) ...[
                        const Text(
                          "Step 1: Power on your new SafeSpark device.\n\nIt will create a Wi-Fi network like \"SafeSpark_ESP_XXXX\".\n\nConnect your phone to this network.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => setState(() => step = 2),
                          child: const Text("I'm Connected to ESP's Wi-Fi"),
                        ),
                      ],

                      // STEP 2
                      if (step == 2) ...[
                        const Text(
                          "Step 2: Enter your network details and device name.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 15),

                        TextField(
                          controller: deviceName,
                          decoration: inputDecoration(
                            "Device Name (e.g., Kitchen)",
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: homeSsid,
                          decoration: inputDecoration(
                            "Wi-Fi Network Name (SSID)",
                          ),
                        ),
                        const SizedBox(height: 12),

                        // NEW: Open network checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: isOpenNetwork,
                              onChanged: (value) {
                                setState(() {
                                  isOpenNetwork = value ?? false;
                                  // Clear password when switching to open network
                                  if (isOpenNetwork) {
                                    homePassword.clear();
                                  }
                                });
                              },
                            ),
                            const Text("This is an open network (no password)"),
                          ],
                        ),

                        // Only show password field if it's NOT an open network
                        if (!isOpenNetwork) ...[
                          TextField(
                            controller: homePassword,
                            decoration: inputDecoration("Wi-Fi Password"),
                            obscureText: true,
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              errorMessage,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: loading ? null : sendCredentials,
                          child: Text(
                            loading
                                ? "Sending..."
                                : "Send Credentials to Device",
                          ),
                        ),
                      ],

                      // STEP 3
                      if (step == 3) ...[
                        const Text(
                          "Success! Your device received the network credentials.\n\nReconnect your phone to your normal network.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            widget.onClose(); // Call external close
                            resetState(); // Reset state for next use
                          },
                          child: const Text("Done"),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
