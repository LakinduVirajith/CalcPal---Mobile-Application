import 'package:flutter/material.dart';

final colorTheme = ThemeData(
  primaryColor: const Color.fromRGBO(37, 219, 171, 1),
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.teal,
    accentColor: Colors.deepOrangeAccent,
    errorColor: Colors.red,
    brightness: Brightness.light,
  ),
  fontFamily: 'Inter',
  useMaterial3: true,
);
