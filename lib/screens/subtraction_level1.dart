import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SubtractionLevel1Screen extends StatefulWidget {
  final String title;
  final int number1;
  final int number2;
  final int correctAnswer;
  final IconData icon;

  const SubtractionLevel1Screen({
    super.key,
    required this.title,
    required this.number1,
    required this.number2,
    required this.correctAnswer,
    required this.icon,
  });

  @override
  _SubtractionLevel1ScreenState createState() =>
      _SubtractionLevel1ScreenState();
}

class _SubtractionLevel1ScreenState extends State<SubtractionLevel1Screen> {
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/subtraction_level1.png'),
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
                      fontSize: 28,
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
                    buildNumberBox(widget.number1, false, showNumber: true),
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
                    buildNumberBox(widget.number2, false, showNumber: true),
                  ],
                ),
                const SizedBox(height: 30),
                // Equal Sign
                const Text(
                  '=',
                  style: TextStyle(fontSize: 48, color: Colors.black),
                ),
                const SizedBox(height: 20),
                // Visualization of the Answer (With Crossed-Out Icons)
                buildNumberBox(widget.number1, true, showNumber: false),
                const SizedBox(height: 30),
                // Answer Selection Text
                const Text(
                  "Select the correct answer 😊",
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                const SizedBox(height: 20),
                // Answer Selection Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildAnswerButton(widget.correctAnswer - 1),
                    const SizedBox(width: 10),
                    buildAnswerButton(widget.correctAnswer),
                    const SizedBox(width: 10),
                    buildAnswerButton(widget.correctAnswer + 1),
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
                // Navigate to Activity 4 (SubtractionLevel1Screen with different values)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubtractionLevel1Screen(
                      title: "Activity 4 - Let's Subtract",
                      number1: 16,
                      number2: 6,
                      correctAnswer: 10,
                      icon: FontAwesomeIcons.mugHot, // Use balloon icon
                    ),
                  ),
                );
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
                        size: 48,
                        color: shouldCrossOut
                            ? Colors.red.withOpacity(0.5)
                            : Colors.green,
                      ),
                      if (shouldCrossOut)
                        const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 54,
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
        bool isCorrect = answer == widget.correctAnswer;
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
