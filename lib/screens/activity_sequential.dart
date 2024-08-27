import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActivitySequentialScreen extends StatelessWidget {
  const ActivitySequentialScreen({super.key});

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
