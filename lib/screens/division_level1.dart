import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DivisionLevel1Screen extends StatefulWidget {
  final int number1;
  final int number2;
  final String title;
  final IconData icon;

  const DivisionLevel1Screen({
    super.key,
    required this.number1,
    required this.number2,
    required this.title,
    required this.icon,
  });

  @override
  _DivisionLevel1ScreenState createState() => _DivisionLevel1ScreenState();
}

class _DivisionLevel1ScreenState extends State<DivisionLevel1Screen> {
  late int correctAnswer;
  late Color iconColor;

  @override
  void initState() {
    super.initState();
    // Set the correct answer based on the division of number1 by number2
    correctAnswer = (widget.number1 / widget.number2).round();

    // Set the icon color based on the title
    if (widget.title.contains('Activity 5')) {
      iconColor = Colors.blue;
    } else if (widget.title.contains('Activity 6')) {
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DivisionLevel1Screen(
          number1: 20, // Set appropriate number1 for the next activity
          number2: 5, // Set appropriate number2 for the next activity
          title: 'Activity 2 - Let\'s Divide', // Set the new title
          icon: FontAwesomeIcons.flag, // Set the appropriate icon
        ),
      ),
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
                image: AssetImage('assets/images/division_level1.png'),
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
                    buildNumberBox(widget.number1),
                    const SizedBox(width: 20),
                    // Division Sign and Second Number
                    Text(
                      '÷ ${widget.number2}',
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Equal Sign
                const Text(
                  '=',
                  style: TextStyle(fontSize: 48, color: Colors.black),
                ),
                const SizedBox(height: 20),
                // Answer Visualization (With Line Separators)
                buildAnswerBox(widget.number1, widget.number2),
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
              onPressed:
                  navigateToNextActivity, // Navigate to the next activity
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
                size: 48,
                color: iconColor, // Use the color set in initState
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$number',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Helper function to build centered answer visualization box with vertical lines
  Widget buildAnswerBox(int number1, int number2) {
    int segmentSize =
        number1 ~/ number2; // Calculate how many icons per segment

    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        // Width is adjusted based on the content (icons and dividers)
        width: segmentSize *
            number2 *
            54.0, // Calculate width based on icon and divider space
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(number1, (index) {
            // Check if a vertical line should be added after the segment
            bool isDivider =
                (index + 1) % segmentSize == 0 && index != number1 - 1;

            return Row(
              children: [
                Icon(
                  widget.icon,
                  size: 48,
                  color: iconColor,
                ),
                // Add a vertical line after the segment, but not after the last icon
                if (isDivider)
                  Container(
                    width: 2,
                    height: 60,
                    color: Colors.black,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
              ],
            );
          }),
        ),
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

// Define the DivisionLevel2Screen
class DivisionLevel2Screen extends StatefulWidget {
  final int number1;
  final int number2;
  final String title;
  final IconData icon;

  const DivisionLevel2Screen({
    super.key,
    required this.number1,
    required this.number2,
    required this.title,
    required this.icon,
  });

  @override
  _DivisionLevel2ScreenState createState() => _DivisionLevel2ScreenState();
}

class _DivisionLevel2ScreenState extends State<DivisionLevel2Screen> {
  @override
  Widget build(BuildContext context) {
    // Reuse the DivisionLevel1Screen layout with different values
    return DivisionLevel1Screen(
      number1: widget.number1,
      number2: widget.number2,
      title: widget.title,
      icon: widget.icon,
    );
  }
}
