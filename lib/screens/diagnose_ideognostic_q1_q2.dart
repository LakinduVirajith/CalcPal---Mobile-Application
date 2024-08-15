import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calcpal/screens/diagnose_ideognostic_q3_q4.dart';

class DiagnoseIdeognosticType1Screen extends StatelessWidget {
  const DiagnoseIdeognosticType1Screen({super.key});

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
                image: AssetImage('assets/images/diagnose_id_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content with Grey Box
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 30, horizontal: 20), // Reduced side padding
              width: MediaQuery.of(context).size.width * 0.5, // Adjusted width
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
                    'Select the fraction showed by the image below',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Fraction Image
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/q1_img.png',
                      height: 100,
                      width: 100,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FractionButton(
                          numerator: '1',
                          denominator: '2',
                          onPressed: () => _navigateToNextQuestion(context)),
                      const SizedBox(width: 20),
                      FractionButton(
                          numerator: '1',
                          denominator: '8',
                          onPressed: () => _navigateToNextQuestion(context)),
                      const SizedBox(width: 20),
                      FractionButton(
                          numerator: '3',
                          denominator: '8',
                          onPressed: () => _navigateToNextQuestion(context)),
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

  void _navigateToNextQuestion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SecondQuestionScreen()),
    );
  }
}

class FractionButton extends StatelessWidget {
  final String numerator;
  final String denominator;
  final VoidCallback onPressed;

  const FractionButton({
    required this.numerator,
    required this.denominator,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            vertical: 20, horizontal: 30), // Button size
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            numerator,
            style: const TextStyle(
              fontSize: 24, // Font size
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            height: 2,
            width: 40,
            color: Colors.white,
          ),
          Text(
            denominator,
            style: const TextStyle(
              fontSize: 24, // Font size
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Second Question Screen
class SecondQuestionScreen extends StatelessWidget {
  const SecondQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/diagnose_id_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content with Grey Box
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 30, horizontal: 20), // Reduced side padding
              width: MediaQuery.of(context).size.width * 0.5, // Adjusted width
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
                    'Select the fraction showed by the image below',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Fraction Image
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/q1_img.png',
                      height: 100,
                      width: 100,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FractionButton(
                          numerator: '1',
                          denominator: '4',
                          onPressed: () => _navigateToThirdQuestion(context)),
                      const SizedBox(width: 20),
                      FractionButton(
                          numerator: '1',
                          denominator: '2',
                          onPressed: () => _navigateToThirdQuestion(context)),
                      const SizedBox(width: 20),
                      FractionButton(
                          numerator: '3',
                          denominator: '4',
                          onPressed: () => _navigateToThirdQuestion(context)),
                      const SizedBox(width: 20),
                      FractionButton(
                          numerator: '1',
                          denominator: '8',
                          onPressed: () => _navigateToThirdQuestion(context)),
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

  void _navigateToThirdQuestion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const DiagnoseIdeognosticType2Screen()),
    );
  }
}
