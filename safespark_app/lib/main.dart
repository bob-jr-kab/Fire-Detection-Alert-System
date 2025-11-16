import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/home_page.dart';
import 'screens/settings_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeSpark',
      initialRoute: '/landing',
      routes: {
        '/landing': (context) => const LandingPage(),
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
