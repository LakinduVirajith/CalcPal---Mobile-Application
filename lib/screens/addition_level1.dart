import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:calcpal/screens/subtraction_level1.dart';

class OperationalLevel1Screen extends StatefulWidget {
  const OperationalLevel1Screen({super.key});

  @override
  _OperationalLevel1ScreenState createState() =>
      _OperationalLevel1ScreenState();
}

class _OperationalLevel1ScreenState extends State<OperationalLevel1Screen> {
  int number1 = Random().nextInt(5) + 1; // Random number between 1 and 5
  int number2 = Random().nextInt(5) + 1; // Random number between 1 and 5
  int correctAnswer = 0;
  bool isActivity1 = true;

  @override
  void initState() {
    super.initState();
    correctAnswer = number1 + number2;
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
                  moveToNextActivity(); // Call this function only if the answer is correct
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

  void moveToNextActivity() {
    setState(() {
      if (isActivity1) {
        // Move to Activity 2
        number1 = 5;
        number2 = Random().nextInt(4) + 6; // Random number between 6 and 10
        correctAnswer = number1 + number2;
        isActivity1 = false;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubtractionLevel1Screen(
              title:
                  "3 : Let's Subtract $number1 - $number2", // Set the title for Activity 4
              number1: 5, // Set the first number for subtraction
              number2: Random().nextInt(4) + 1, // Random number between 1 and 4
              icon: FontAwesomeIcons.leaf,
            ),
          ),
        );
      }
    });
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
                image: AssetImage(
                    'assets/images/operational_activities/operational_level1.png'),
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
                    isActivity1
                        ? "1 : Let's Add $number1 + $number2"
                        : "2 : Let's Add $number1 + $number2",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Number and Apples/Sweets Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // First Number and Apples/Sweets
                    buildNumberBox(number1, showNumber: false),
                    const SizedBox(width: 20),
                    // Plus Sign
                    const Text(
                      '+',
                      style: TextStyle(fontSize: 48, color: Colors.black),
                    ),
                    const SizedBox(width: 20),
                    // Second Number and Apples/Sweets
                    buildNumberBox(number2, showNumber: false),
                    const SizedBox(height: 30),
                    // Equal Sign
                    const Text(
                      '=',
                      style: TextStyle(fontSize: 48, color: Colors.black),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // Visualization of the Correct Answer (Without Number)
                buildNumberBox(correctAnswer, showNumber: false),
                const SizedBox(height: 30),

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

  // Helper function to build number box with apples/sweets and optional number
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
              // Apples/Sweets
              Wrap(
                children: List.generate(number, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      isActivity1
                          ? FontAwesomeIcons.appleAlt
                          : FontAwesomeIcons.candyCane,
                      size: 30,
                      color: isActivity1 ? Colors.red : Colors.purple,
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
