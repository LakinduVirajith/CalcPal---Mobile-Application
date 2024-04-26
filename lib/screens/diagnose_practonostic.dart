import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnosePractonosticScreen extends StatelessWidget {
  const DiagnosePractonosticScreen({super.key});

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
