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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/diagnose_background_v1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: constraints.maxHeight * 0.1,
                  right: constraints.maxWidth * 0.25,
                  left: constraints.maxWidth * 0.25,
                  bottom: constraints.maxHeight * 0.1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24.0,
                      horizontal: 36.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(96, 96, 96, 1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Text(
                      'Listen and answer the question',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
