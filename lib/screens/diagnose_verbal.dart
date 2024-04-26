import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnoseVerbalScreen extends StatelessWidget {
  const DiagnoseVerbalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/diagnose_background_v1.png'),
            fit: BoxFit.cover,
          ),
        ),
      )),
    );
  }
}
