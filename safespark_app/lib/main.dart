import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/safesparkonboarding.dart';
import 'screens/home_page.dart';
import 'screens/settings_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add error handling for dotenv
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
  }

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isFirstInstall = true;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isFirstInstall = prefs.getBool('isFirstInstall') ?? true;

      if (mounted) {
        setState(() {
          _isFirstInstall = isFirstInstall;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _getNextRouteAfterSplash() {
    return _isFirstInstall ? '/landing' : '/home';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF8C79E6),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  height: 80,
                  width: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.security,
                        size: 40,
                        color: Color(0xFF8C79E6),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      // Error state
      return MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF8C79E6),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'App Initialization Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _initializeApp,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeSpark',
      theme: ThemeData(
        primaryColor: const Color(0xFF8C79E6),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF8C79E6),
          secondary: Color(0xFFD87CB9),
        ),
      ),
      home: SplashScreen(onComplete: _getNextRouteAfterSplash),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/landing':
            return MaterialPageRoute(
              builder: (_) => const SafeSparkOnboarding(),
            );
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomePage());
          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsPage());
          default:
            // Handle unexpected route names gracefully
            return MaterialPageRoute(builder: (_) => const HomePage());
        }
      },
      // Add a fallback for unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const HomePage());
      },
    );
  }
}
