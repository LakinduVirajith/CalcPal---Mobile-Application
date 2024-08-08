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
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/diagnose_op_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content with Grey Box
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: Colors.grey.shade800
                    .withOpacity(0.8), // Semi-transparent grey color
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Question Text
                  const Text(
                    'Select the correct answer for -',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Expression
                  const Text(
                    '30 + 5',
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OptionButton(label: '45', onPressed: () {}),
                      const SizedBox(width: 20),
                      OptionButton(label: '35', onPressed: () {}),
                      const SizedBox(width: 20),
                      OptionButton(label: '30', onPressed: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const OptionButton({
    required this.label,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
