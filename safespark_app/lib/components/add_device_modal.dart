import 'dart:convert';
import 'dart:ui'; // 👈 Needed for blur
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  static const String ESP_IP = "192.168.4.1";

  void resetState() {
    step = 1;
    deviceName.clear();
    homeSsid.clear();
    homePassword.clear();
    loading = false;
    errorMessage = "";
  }

  Future<void> sendCredentials() async {
    if (deviceName.text.trim().isEmpty ||
        homeSsid.text.trim().isEmpty ||
        homePassword.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Please fill all fields: Device Name, SSID, Password.";
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = "";
    });

    try {
      final formBody = {
        "ssid": homeSsid.text.trim(),
        "password": homePassword.text.trim(),
        "deviceName": deviceName.text.trim(),
      };

      final response = await http.post(
        Uri.parse("http://$ESP_IP/config"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: formBody,
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (result["deviceId"] != null) {
          widget.onDeviceAdded({
            "id": result["deviceId"],
            "name": deviceName.text.trim(),
          });
          setState(() => step = 3);
        } else {
          setState(
            () => errorMessage = "Device did not return an ID. Try again.",
          );
        }
      } else {
        setState(
          () => errorMessage =
              "Failed to send config to ESP32: ${result["message"]}",
        );
      }
    } catch (e) {
      setState(() {
        errorMessage =
            "Could not connect to ESP32. Make sure you're connected to its Wi-Fi.";
      });
    } finally {
      setState(() => loading = false);
    }
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
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ),
        ),

        // 🔥 MODAL WITH MATERIAL WRAP (fixes TextField error)
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
                        widget.onClose();
                        setState(() => resetState());
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
                          "Step 1: Power on your new SafeSpark device.\n\nIt will create a Wi-Fi network like “SafeSpark_ESP_XXXX”.\n\nConnect your phone to this network.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => setState(() => step = 2),
                          child: const Text("I'm Connected to ESP’s Wi-Fi"),
                        ),
                      ],

                      // STEP 2
                      if (step == 2) ...[
                        const Text(
                          "Step 2: Enter your home Wi-Fi details and device name.",
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
                          decoration: inputDecoration("Your Home Wi-Fi SSID"),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: homePassword,
                          decoration: inputDecoration(
                            "Your Home Wi-Fi Password",
                          ),
                          obscureText: true,
                        ),

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
                          "Success! Your device received the Wi-Fi credentials.\n\nReconnect your phone to your normal Wi-Fi.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            widget.onClose();
                            setState(() => resetState());
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

  InputDecoration inputDecoration(String placeholder) {
    return InputDecoration(
      hintText: placeholder,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
