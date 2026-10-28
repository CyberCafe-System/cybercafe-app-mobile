import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const CoffeeLanApp());
}

class CoffeeLanApp extends StatelessWidget {
  const CoffeeLanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The COFFEE LAN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C1E16),
          primary: const Color(0xFF2C1E16),
          secondary: const Color(0xFFB06B05),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
