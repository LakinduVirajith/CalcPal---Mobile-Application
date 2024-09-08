import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:calcpal/screens/multiplication_level1.dart';
import 'dart:math';

class SubtractionLevel1Screen extends StatefulWidget {
  final String title;
  final int number1;
  final int number2;
  final IconData icon;
  final bool isActivity4;

  const SubtractionLevel1Screen({
    super.key,
    required this.title,
    required this.number1,
    required this.number2,
    required this.icon,
    this.isActivity4 = false,
  });

  @override
  _SubtractionLevel1ScreenState createState() =>
      _SubtractionLevel1ScreenState();
}

class _SubtractionLevel1ScreenState extends State<SubtractionLevel1Screen> {
  late int correctAnswer;

  @override
  void initState() {
    super.initState();
    correctAnswer = widget.number1 - widget.number2;
  }

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
                if (isCorrect) {
                  moveToNextActivity(
                      context,
                      widget
                          .isActivity4); // Call this function only if the answer is correct
                }
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

  void moveToNextActivity(BuildContext context, bool isActivity4) {
    if (isActivity4) {
      // Navigate to MultiplicationScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiplicationLevel1Screen(
            number1: 3,
            number2: 2,
            title: "5 : Let's Multiply - Select the correct answer 😊",
            icon: FontAwesomeIcons.book,
          ),
        ),
      );
    } else {
      // Navigate to Activity 4 (Subtraction)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubtractionLevel1Screen(
            title: "4 : Let's Subtract",
            number1: Random().nextInt(4) + 6, // Random number between 6 and 15
            number2: Random().nextInt(6) + 1, // Random number between 1 and 6
            icon: FontAwesomeIcons.mugHot,
            isActivity4: true, // Set flag to true for Activity 4
          ),
        ),
      );
    }
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/operational_activities/subtraction_level1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title Text on Top Left
                Positioned(
                  top: 20,
                  left: 20,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Number and Icons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // First Number and Icons
                    buildNumberBox(widget.number1, false, showNumber: false),
                    const SizedBox(width: 20),
                    // Subtraction Sign
                    const Text(
                      '-',
                      style: TextStyle(
                        fontSize: 48,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Second Number and Icons
                    buildNumberBox(widget.number2, false, showNumber: false),
                    const SizedBox(height: 30),
                    // Equal Sign
                    const Text(
                      '=',
                      style: TextStyle(fontSize: 48, color: Colors.black),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // Visualization of the Answer (With Crossed-Out Icons)
                buildNumberBox(widget.number1, true, showNumber: false),
                const SizedBox(height: 20),
                // Answer Selection Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildAnswerButton(correctAnswer - 1),
                    const SizedBox(width: 10),
                    buildAnswerButton(correctAnswer),
                    const SizedBox(width: 10),
                    buildAnswerButton(correctAnswer + 1),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build number box with icons and optional number
  Widget buildNumberBox(int number, bool crossedOut,
      {required bool showNumber}) {
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
              // Icons with Crossed-Out Option
              Wrap(
                children: List.generate(number, (index) {
                  bool shouldCrossOut =
                      crossedOut && index >= (widget.number1 - widget.number2);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        size: 30,
                        color: shouldCrossOut
                            ? Colors.red.withOpacity(0.5)
                            : Colors.green,
                      ),
                      if (shouldCrossOut)
                        const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 35,
                        ),
                    ],
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
            style: const TextStyle(fontSize: 20, color: Colors.black),
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
