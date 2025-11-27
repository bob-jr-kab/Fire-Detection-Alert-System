import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final String Function() onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textScale;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    // 1. Initialize the AnimationController
    _controller = AnimationController(
      vsync: this, // 'this' is the SingleTickerProviderStateMixin
      duration: const Duration(milliseconds: 1500), // Choose a duration
    );

    // 2. Initialize the Animations using the controller and Curvess
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _textScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // 3. Start the animation
    _controller.forward();

    // Prevent immediate call
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      final nextRouteName = widget.onComplete();
      // Use pushReplacementNamed to prevent going back to splash
      Navigator.of(context).pushReplacementNamed(nextRouteName);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8C79E6),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                ScaleTransition(
                  scale: _logoScale,
                  child: Opacity(
                    opacity: _logoOpacity.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        "assets/images/logo.png",
                        height: 130,
                        width: 130,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if image fails to load
                          return Container(
                            width: 130,
                            height: 130,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.security,
                              size: 60,
                              color: Color(0xFF8C79E6),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Animated Text
                ScaleTransition(
                  scale: _textScale,
                  child: Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        const Text(
                          "SafeSpark",
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedOpacity(
                          opacity: _textOpacity.value,
                          duration: const Duration(milliseconds: 500),
                          child: const Text(
                            "Smart Fire Safety",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Loading indicator (appears last)
                AnimatedOpacity(
                  opacity: _textOpacity.value,
                  duration: const Duration(milliseconds: 500),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
