import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnoseOperationalScreen extends StatelessWidget {
  const DiagnoseOperationalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: SafeArea(
        child: Container(),
      ),
    );
  }
}
