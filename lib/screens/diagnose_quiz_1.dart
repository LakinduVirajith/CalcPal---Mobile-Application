import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnoseQuiz1Screen extends StatelessWidget {
  const DiagnoseQuiz1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return const Placeholder();
  }
}
