import 'package:flutter/material.dart';
import 'screens/safesparkonboarding.dart';
import 'screens/home_page.dart';
import 'screens/settings_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    var materialApp = MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeSpark',
      initialRoute: '/home',
      routes: {
        '/landing': (context) => const SafeSparkOnboarding(),
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
    return materialApp;
  }
}
