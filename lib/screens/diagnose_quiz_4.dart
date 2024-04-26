import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnoseQuiz4Screen extends StatelessWidget {
  const DiagnoseQuiz4Screen({super.key});

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
