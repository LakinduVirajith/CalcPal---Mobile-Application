import 'package:calcpal/screens/division_level1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MultiplicationLevel1Screen extends StatefulWidget {
  final int number1;
  final int number2;
  final String title;
  final IconData icon;

  const MultiplicationLevel1Screen({
    super.key,
    required this.number1,
    required this.number2,
    required this.title,
    required this.icon,
  });

  @override
  _MultiplicationLevel1ScreenState createState() =>
      _MultiplicationLevel1ScreenState();
}

class _MultiplicationLevel1ScreenState
    extends State<MultiplicationLevel1Screen> {
  late int correctAnswer;
  late Color iconColor;

  @override
  void initState() {
    super.initState();
    correctAnswer = widget.number1 * widget.number2;

    // Set the icon color based on the title
    if (widget.title.contains('5')) {
      iconColor = Colors.blue;
    } else if (widget.title.contains('6')) {
      iconColor = Colors.orange;
    } else {
      iconColor = Colors.green;
    }
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
                  navigateToNextActivity(); // Call this function only if the answer is correct
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

  void navigateToNextActivity() {
    if (widget.title.contains('5')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiplicationLevel1Screen(
            number1: 4, // Set appropriate number1 for Activity 6
            number2: 3, // Set appropriate number2 for Activity 6
            title:
                '6 : Let\'s Multiply - Select the correct answer 😊', // Set the new title
            icon: FontAwesomeIcons.book, // Set the appropriate icon
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DivisionLevel1Screen(
            number1: 10, // Set appropriate number1 for the next activity
            number2: 2, // Set appropriate number2 for the next activity
            title:
                '7 : - Let\'s Divide - Select the correct answer 😊', // Set the new title
            icon: FontAwesomeIcons.flag, // Set the appropriate icon
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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/operational_activities/multiplication_level1.png'),
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
                    buildNumberBox(widget.number1),
                    const SizedBox(width: 20),
                    // Multiplication Sign and Second Number
                    Text(
                      'x ${widget.number2}',
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Equal Sign
                    const Text(
                      '=',
                      style: TextStyle(fontSize: 48, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Answer Visualization (Separated by a Border)
                buildAnswerBox(widget.number1, widget.number2),
                const SizedBox(height: 20),
                // Answer Selection Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildAnswerButton(correctAnswer - widget.number2),
                    const SizedBox(width: 10),
                    buildAnswerButton(correctAnswer),
                    const SizedBox(width: 10),
                    buildAnswerButton(correctAnswer + widget.number2),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build number box with icons
  Widget buildNumberBox(int number) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            children: List.generate(number, (index) {
              return Icon(
                widget.icon, // Use the icon from the widget
                size: 25,
                color: iconColor, // Use the color set in initState
              );
            }),
          ),
        ),
      ],
    );
  }

  // Helper function to build answer visualization box
  Widget buildAnswerBox(int number1, int number2) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Wrap(
        spacing: 10.0, // Add spacing between the segments
        children: List.generate(number2, (index) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.black,
                width: 2,
              ), // Border around each part
            ),
            child: Wrap(
              children: List.generate(number1, (index) {
                return Icon(
                  widget.icon, // Use the icon from the widget
                  size: 25,
                  color: iconColor, // Use the color set in initState
                );
              }),
            ),
          );
        }),
      ),
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
