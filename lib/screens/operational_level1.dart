import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OperationalLevel1Screen extends StatefulWidget {
  const OperationalLevel1Screen({super.key});

  @override
  _OperationalLevel1ScreenState createState() =>
      _OperationalLevel1ScreenState();
}

class _OperationalLevel1ScreenState extends State<OperationalLevel1Screen> {
  final int number1 = 3;
  final int number2 = 4;
  final int correctAnswer = 7;

  void showFeedback(bool isCorrect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: isCorrect
              ? const Icon(Icons.check_circle, color: Colors.green, size: 50)
              : const Icon(Icons.error, color: Colors.red, size: 50),
          content: Text(
            isCorrect ? 'Correct! 🎉' : 'Try Again!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        );
      },
    );
  }

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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/operational_level1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title Text
                const Text(
                  "Let's Add!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                // Number and Apples Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // First Number and Apples
                    buildNumberBox(number1, showNumber: true),
                    const SizedBox(width: 20),
                    // Plus Sign
                    const Text(
                      '+',
                      style: TextStyle(fontSize: 48, color: Colors.black),
                    ),
                    const SizedBox(width: 20),
                    // Second Number and Apples
                    buildNumberBox(number2, showNumber: true),
                  ],
                ),
                const SizedBox(height: 30),
                // Equal Sign
                const Text(
                  '=',
                  style: TextStyle(fontSize: 48, color: Colors.black),
                ),
                const SizedBox(height: 20),
                // Visualization of the Correct Answer (Without Number)
                buildNumberBox(correctAnswer, showNumber: false),
                const SizedBox(height: 30),
                // Answer Selection Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildAnswerButton(6),
                    const SizedBox(width: 10),
                    buildAnswerButton(7),
                    const SizedBox(width: 10),
                    buildAnswerButton(8),
                  ],
                ),
              ],
            ),
          ),
          // Next Button at the bottom right
          Positioned(
            bottom: 30,
            right: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              onPressed: () {
                // Define the action for the next button here
              },
              child: const Text(
                'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build number box with apples and optional number
  Widget buildNumberBox(int number, {required bool showNumber}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Apples
              Wrap(
                children: List.generate(number, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Icon(
                      FontAwesomeIcons.appleAlt,
                      size: 48,
                      color: Colors.red, // or any color you prefer
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        // Conditionally Display Number
        if (showNumber) const SizedBox(height: 10),
        if (showNumber)
          Text(
            '$number',
            style: const TextStyle(fontSize: 32, color: Colors.black),
          ),
      ],
    );
  }

  // Helper function to build answer buttons
  Widget buildAnswerButton(int answer) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.black,
      ),
      onPressed: () {
        bool isCorrect = answer == correctAnswer;
        showFeedback(isCorrect);
      },
      child: Text(
        '$answer',
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}
