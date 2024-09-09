import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calcpal/screens/diagnose_ideognostic_q3_q4.dart';
// import 'dart:async'; // Import for Timer
import 'dart:math';

class DiagnoseIdeognosticScreen extends StatefulWidget {
  const DiagnoseIdeognosticScreen({super.key});

  @override
  _DiagnoseIdeognosticScreenState createState() =>
      _DiagnoseIdeognosticScreenState();
}

class _DiagnoseIdeognosticScreenState extends State<DiagnoseIdeognosticScreen> {
  late Stopwatch _stopwatch; // To track time
  int _q1Answer =
      0; // To store the answer for question 1 (0 means incorrect, 1 means correct)

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch(); // Initialize stopwatch
    _stopwatch.start(); // Start the timer when the quiz begins
  }

  @override
  void dispose() {
    _stopwatch.stop(); // Stop the timer when the screen is disposed
    super.dispose();
  }

  // Method to navigate to the second question and store the answer
  void _navigateToNextQuestion(BuildContext context, bool isCorrect) {
    setState(() {
      _q1Answer = isCorrect ? 1 : 0; // Store if the answer is correct
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecondQuestionScreen(
          timeTaken:
              _stopwatch.elapsedMilliseconds, // Pass the time taken so far
          q1Answer: _q1Answer, // Pass whether the first answer was correct
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int randomNumber = Random().nextInt(4) + 1;

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
                    'Select the fraction showed by the image',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
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
                      'assets/images/ideognostic/ideo_q1_$randomNumber.png',
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
                        onPressed: () => _navigateToNextQuestion(context, true),
                      ),
                      const SizedBox(width: 20),
                      FractionButton(
                        numerator: '1',
                        denominator: '8',
                        onPressed: () =>
                            _navigateToNextQuestion(context, false),
                      ),
                      const SizedBox(width: 20),
                      FractionButton(
                        numerator: '3',
                        denominator: '8',
                        onPressed: () =>
                            _navigateToNextQuestion(context, false),
                      ),
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

class FractionButton extends StatelessWidget {
  final String numerator;
  final String denominator;
  final VoidCallback onPressed;
  final double fontSize;
  final double paddingVertical;
  final double paddingHorizontal;

  const FractionButton({
    required this.numerator,
    required this.denominator,
    required this.onPressed,
    this.fontSize = 24.0,
    this.paddingVertical = 20.0,
    this.paddingHorizontal = 30.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
            vertical: paddingVertical,
            horizontal: paddingHorizontal), // Button size
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
            style: TextStyle(
              fontSize: fontSize, // Font size
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
            style: TextStyle(
              fontSize: fontSize, // Font size
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
  final int timeTaken;
  final int q1Answer;

  const SecondQuestionScreen({
    required this.timeTaken,
    required this.q1Answer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    int randomNumber = Random().nextInt(4) + 1;

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
                      'assets/images/ideognostic/ideo_q2_$randomNumber.png',
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
                        paddingHorizontal: 24.0,
                        paddingVertical: 18.0,
                        fontSize: 18.0,
                        numerator: '1',
                        denominator: '4',
                        onPressed: () =>
                            _navigateToThirdQuestion(context, true),
                      ),
                      const SizedBox(width: 20),
                      FractionButton(
                        paddingHorizontal: 24.0,
                        paddingVertical: 18.0,
                        fontSize: 18.0,
                        numerator: '1',
                        denominator: '2',
                        onPressed: () =>
                            _navigateToThirdQuestion(context, false),
                      ),
                      const SizedBox(width: 20),
                      FractionButton(
                        paddingHorizontal: 24.0,
                        paddingVertical: 18.0,
                        fontSize: 18.0,
                        numerator: '3',
                        denominator: '4',
                        onPressed: () =>
                            _navigateToThirdQuestion(context, false),
                      ),
                      const SizedBox(width: 20),
                      FractionButton(
                        paddingHorizontal: 24.0,
                        paddingVertical: 18.0,
                        fontSize: 18.0,
                        numerator: '1',
                        denominator: '8',
                        onPressed: () =>
                            _navigateToThirdQuestion(context, false),
                      ),
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

  void _navigateToThirdQuestion(BuildContext context, bool isCorrect) {
    // Capture whether the second question was answered correctly and pass the data to the next screen
    int q2Answer = isCorrect ? 1 : 0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiagnoseIdeognosticType2Screen(
          timeTaken: timeTaken, // Pass the accumulated time taken
          q1Answer: q1Answer, // Pass whether the first question was correct
          q2Answer: q2Answer, // Pass whether the second question was correct
        ),
      ),
    );
  }
}
