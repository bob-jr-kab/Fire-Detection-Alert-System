import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8B7FD9), Color(0xFFD97FB8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Back Button
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Image.asset('assets/images/logo.png', height: 80),
                      const Text(
                        'SafeSpark',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),

                  child: Container(
                    padding: EdgeInsets.only(
                      left: 10.0,
                      top: 0,
                      right: 10,
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Top content (image + texts)
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            Image.asset(
                              'assets/images/representation.png',
                              height: 300,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '24/7 Fire Monitoring ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(221, 86, 81, 81),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Real-time monitoring and instant alerts\nto keep you and your family safe',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),

                        // Bottom button pinned to the bottom of the white panel
                        Material(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 4,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/home');
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              alignment: Alignment.center,
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
