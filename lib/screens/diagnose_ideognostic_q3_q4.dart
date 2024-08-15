import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calcpal/screens/diagnose_ideognostic_last_ques.dart';

class DiagnoseIdeognosticType2Screen extends StatefulWidget {
  const DiagnoseIdeognosticType2Screen({super.key});

  @override
  _DiagnoseIdeognosticType2ScreenState createState() =>
      _DiagnoseIdeognosticType2ScreenState();
}

class _DiagnoseIdeognosticType2ScreenState
    extends State<DiagnoseIdeognosticType2Screen> {
  final List<int?> _answers = [null, null, null]; // Tracks dropped digits
  final List<int> _availableDigits = [8, 9, 3]; // Tracks available digits

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
                  vertical: 40, horizontal: 30), // Increased padding
              width: MediaQuery.of(context).size.width * 0.7, // Increased width
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
                    'Use the 3 digits below and make the largest number possible',
                    style: TextStyle(
                      fontSize: 30, // Increased font size
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                      height: 40), // Increased space between text and digits
                  // Draggable Digits for Question 3
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _availableDigits
                        .map((digit) => _buildDraggableDigit(digit))
                        .toList(),
                  ),
                  const SizedBox(
                      height: 40), // Increased space between digits and targets
                  // Target Areas for Question 3
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        3, (index) => _buildDragTarget(index, _answers[index])),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => _navigateToFourthQuestion(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToFourthQuestion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FourthQuestionScreen()),
    );
  }

  Widget _buildDraggableDigit(int digit) {
    return Draggable<int>(
      data: digit,
      child: _buildDigitBox(digit),
      feedback: _buildDigitBox(digit, isDragging: true),
      childWhenDragging: _buildDigitBox(digit, isDragging: true, opacity: 0.5),
    );
  }

  Widget _buildDragTarget(int index, int? currentDigit) {
    return DragTarget<int>(
      onAccept: (receivedDigit) {
        setState(() {
          _answers[index] = receivedDigit;
          _availableDigits.remove(receivedDigit); // Remove used digit
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.blue,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              currentDigit?.toString() ?? '',
              style: const TextStyle(
                fontSize: 40, // Increased font size
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

class FourthQuestionScreen extends StatefulWidget {
  const FourthQuestionScreen({super.key});

  @override
  _FourthQuestionScreenState createState() => _FourthQuestionScreenState();
}

class _FourthQuestionScreenState extends State<FourthQuestionScreen> {
  final List<int?> _answers = [null, null, null, null]; // Tracks dropped digits
  final List<int> _availableDigits = [7, 2, 5, 4]; // Tracks available digits

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
                  vertical: 40, horizontal: 30), // Increased padding
              width: MediaQuery.of(context).size.width * 0.7, // Increased width
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
                    'Use the 4 digits below and make the largest number possible',
                    style: TextStyle(
                      fontSize: 30, // Increased font size
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                      height: 40), // Increased space between text and digits
                  // Draggable Digits for Question 4
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _availableDigits
                        .map((digit) => _buildDraggableDigit(digit))
                        .toList(),
                  ),
                  const SizedBox(
                      height: 40), // Increased space between digits and targets
                  // Target Areas for Question 4
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        4, (index) => _buildDragTarget(index, _answers[index])),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => _navigateToFifthQuestion(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToFifthQuestion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const DiagnoseIdeognosticLastScreen()),
    );
  }

  Widget _buildDraggableDigit(int digit) {
    return Draggable<int>(
      data: digit,
      child: _buildDigitBox(digit),
      feedback: _buildDigitBox(digit, isDragging: true),
      childWhenDragging: _buildDigitBox(digit, isDragging: true, opacity: 0.5),
    );
  }

  Widget _buildDragTarget(int index, int? currentDigit) {
    return DragTarget<int>(
      onAccept: (receivedDigit) {
        setState(() {
          _answers[index] = receivedDigit;
          _availableDigits.remove(receivedDigit); // Remove used digit
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.blue,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              currentDigit?.toString() ?? '',
              style: const TextStyle(
                fontSize: 40, // Increased font size
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildDigitBox(int digit,
    {bool isDragging = false, double opacity = 1}) {
  return Opacity(
    opacity: opacity,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDragging ? Colors.grey : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          if (!isDragging)
            BoxShadow(
              color: Colors.black26,
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
        ],
      ),
      child: Text(
        digit.toString(),
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
