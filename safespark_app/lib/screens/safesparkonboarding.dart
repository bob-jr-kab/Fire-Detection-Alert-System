import 'package:flutter/material.dart';

// --- 1. Data Model for Onboarding Steps ---
class OnboardingStepData {
  final String title;
  final String description;
  final IconData
  icon; // Using icons instead of image assets for simplicity in a single file environment
  final Color iconColor;

  OnboardingStepData({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });
}

// --- 2. Main Onboarding Widget (State Management and PageView) ---
class SafeSparkOnboarding extends StatefulWidget {
  const SafeSparkOnboarding({super.key});

  @override
  State<SafeSparkOnboarding> createState() => _SafeSparkOnboardingState();
}

class _SafeSparkOnboardingState extends State<SafeSparkOnboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStepData> steps = [
    OnboardingStepData(
      title: 'Multi-Sensor Protection',
      description:
          'Our system uses three advanced sensors (Flame, Smoke, and Temperature) for rapid and accurate fire detection, minimizing false alarms.',
      icon: Icons.sensors,
      iconColor: const Color(0xFFD97FB8),
    ),
    OnboardingStepData(
      title: 'Real-Time Mobile Alerts',
      description:
          'Receive instant notifications directly on your phone via WebSockets, giving you critical seconds to react to any emergency.',
      icon: Icons.notifications_active,
      iconColor: const Color(0xFF8B7FD9),
    ),
    // The final step content is handled by OnboardingEndPage, but we keep its index here.
  ];

  void _nextPage() {
    if (_currentPage < steps.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // --- Reusable Button Widget ---
  Widget _buildNextButton(bool isLastStep) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Material(
        color: isLastStep ? Colors.red : const Color(0xFF8B7FD9),
        borderRadius: BorderRadius.circular(12),
        elevation: 4,
        child: InkWell(
          onTap: () {
            if (isLastStep) {
              // Navigate to the main application when the final button is pressed
              Navigator.pushNamed(context, '/home');
            } else {
              _nextPage();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 52,
            alignment: Alignment.center,
            child: Text(
              isLastStep ? 'Get Started' : 'Next',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Page Indicator Dots ---
  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: _currentPage == index ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Colors.white
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

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
            children: <Widget>[
              // Header with Title and Indicators
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: Column(
                  children: [
                    const Text(
                      'SafeSpark',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        steps.length + 1, // +1 for the final page
                        (index) => _buildPageIndicator(index),
                      ),
                    ),
                  ],
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(), // Controlled by buttons
                  controller: _pageController,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: steps.length + 1, // 2 steps + 1 final page
                  itemBuilder: (context, index) {
                    if (index < steps.length) {
                      return OnboardingPage(
                        step: steps[index],
                        isLastStep: false,
                        nextButton: _buildNextButton(false),
                      );
                    } else {
                      // Final page (uses the provided layout)
                      return OnboardingEndPage(
                        nextButton: _buildNextButton(true),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 3. Reusable Widget for Onboarding Steps 1 and 2 ---
class OnboardingPage extends StatelessWidget {
  final OnboardingStepData step;
  final bool isLastStep;
  final Widget nextButton;

  const OnboardingPage({
    super.key,
    required this.step,
    required this.isLastStep,
    required this.nextButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Content Panel (Top half is gradient, content is centered)
        Expanded(
          flex: 2,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(step.icon, size: 80, color: step.iconColor),
                  const SizedBox(height: 30),
                  Text(
                    step.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    step.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom Button Area (White background simulation)
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100, // Minimal height to show the button
              decoration: const BoxDecoration(
                color: Colors.transparent, // Simulate the white panel starting
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: nextButton,
            ),
          ),
        ),
      ],
    );
  }
}

// --- 4. Final Onboarding Page (Modified LandingPage) ---
class OnboardingEndPage extends StatelessWidget {
  final Widget nextButton;
  const OnboardingEndPage({super.key, required this.nextButton});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with Logo (Retained the original structure for the top half)
        Expanded(
          flex: 2,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // NOTE: Using a placeholder icon as 'assets/images/logo.png' is not available here.
                Image.asset('assets/images/logo.png', height: 80),
                // const Text(
                //   'SafeSpark',
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontSize: 20,
                //     fontWeight: FontWeight.bold,
                //     letterSpacing: 1.2,
                //   ),
                // ),
              ],
            ),
          ),
        ),

        // Main Content Panel (The white panel from the original code)
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: const BorderRadius.all(Radius.circular(30)),
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
                left: 24.0,
                top: 20,
                right: 24,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Top content (image + texts + NEW ATTRIBUTION)
                  Column(
                    children: [
                      // NOTE: Using a placeholder icon as 'assets/images/representation.png' is not available here.
                      // Image.asset(
                      //   'assets/images/representation.png',

                      //   height: 50,

                      //   fit: BoxFit.contain,
                      // ),
                      const SizedBox(height: 12),
                      const Text(
                        '24/7 Fire Monitoring Ready',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(221, 51, 51, 51),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // const Text(
                      //   'Real-time monitoring and instant alerts\nto keep you and your family safe.',
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: Colors.grey,
                      //     height: 1.5,
                      //   ),
                      // ),
                      const SizedBox(height: 24),
                      // --- NEW: Project Attribution ---
                      const Text(
                        'Developed by Students of Computer Information Systems',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8B7FD9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // List of students
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text(
                            'JUNIOR KABONGO',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            'CHADRACK ELOMBOLA LONKONGI',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            'VICPRAISE ADAMS',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            'OSINACHI MICHAEL UGWU',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Supervisor information
                      const Text(
                        'Supervised by: Prof. Dr. Nadire ÇAVUŞ.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B7FD9),
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),

                  // Bottom button pinned to the bottom of the white panel
                  nextButton,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
// For testing purposes, we wrap the SafeSparkOnboarding with a MaterialApp if it is the entry point
// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SafeSpark Onboarding',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => const SafeSparkOnboarding(),
//         '/home': (context) => const Scaffold(body: Center(child: Text("Home Screen"))),
//       },
//     );
//   }
// }
