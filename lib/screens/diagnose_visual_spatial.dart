import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnoseVisualSpatialScreen extends StatelessWidget {
  const DiagnoseVisualSpatialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      // dafd
    ]);

    return Scaffold(
      body: SafeArea(
        child: Container(),
      ),
    );
  }
}
