import 'package:calcpal/screens/login.dart';
import 'package:calcpal/themes/color_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp()); // ROOT WIDGET
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalcPal Application',
      theme: colorTheme,
      home: const LoginScreen(), // LOGIN SCREEN
    );
  }
}
