import 'package:flutter/material.dart';

class FireAlertScreen extends StatelessWidget {
  const FireAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fire Alert"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              "Fire Detected",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            const Text(
              "A fire has been detected in your home.\n"
              "Please check and evacuate immediately.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                // Call emergency service logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 30,
                ),
              ),
              child: const Text(
                "Alert Emergency Services",
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // Call button logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 30,
                ),
              ),
              child: const Icon(Icons.call, size: 30, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
