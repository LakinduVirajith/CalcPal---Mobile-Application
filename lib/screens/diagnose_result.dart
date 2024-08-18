import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnoseResultScreen extends StatelessWidget {
  const DiagnoseResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // RETRIEVE THE ARGUMENTS PASSED FROM THE PREVIOUS SCREEN
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // EXTRACT INDIVIDUAL VALUES FROM THE ARGUMENTS MAP
    final String diagnoseType = arguments['diagnoseType'];
    final int totalScore = arguments['totalScore'];
    final int elapsedTime = arguments['elapsedTime'];

    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return const Placeholder();
  }
}
