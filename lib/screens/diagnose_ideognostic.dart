import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnoseIdeognosticScreen extends StatelessWidget {
  const DiagnoseIdeognosticScreen({super.key});

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
      MaterialPageRoute(builder: (context) => const ThirdQuestionScreen()),
    );
  }
}

// Third Question Screen
class ThirdQuestionScreen extends StatefulWidget {
  const ThirdQuestionScreen({super.key});

  @override
  _ThirdQuestionScreenState createState() => _ThirdQuestionScreenState();
}

class _ThirdQuestionScreenState extends State<ThirdQuestionScreen> {
  List<int> digits = [8, 9, 3];
  List<int?> selectedDigits = [null, null, null];

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
                    'Use the 3 digits below and make the largest number possible',
                    style: TextStyle(
                      fontSize: 30, // Increased font size
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                      height: 40), // Increased space between text and digits
                  // Draggable Digits
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: digits
                        .map((digit) => _buildDraggableDigit(digit))
                        .toList(),
                  ),
                  const SizedBox(
                      height: 40), // Increased space between digits and targets
                  // Target Areas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        List.generate(3, (index) => _buildDragTarget(index)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableDigit(int digit) {
    return Draggable<int>(
      data: digit,
      child: _buildDigitBox(digit),
      feedback: _buildDigitBox(digit, isDragging: true),
      childWhenDragging: _buildDigitBox(digit, isDragging: false),
    );
  }

  Widget _buildDigitBox(int digit, {bool isDragging = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30), // Increased padding
      decoration: BoxDecoration(
        color: isDragging ? Colors.grey : Colors.black, // Original box is black
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        digit.toString(),
        style: const TextStyle(
          fontSize: 40, // Increased font size
          fontWeight: FontWeight.bold,
          color: Colors.white, // Text color white
        ),
      ),
    );
  }

  Widget _buildDragTarget(int index) {
    return DragTarget<int>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(30), // Increased padding
          decoration: BoxDecoration(
            color: Colors.white, // Target box is white
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            selectedDigits[index]?.toString() ?? '',
            style: const TextStyle(
              fontSize: 40, // Increased font size
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
      onAccept: (digit) {
        setState(() {
          selectedDigits[index] = digit;
        });
      },
      onWillAccept: (digit) {
        // Allow dragging within target boxes for rearranging
        if (selectedDigits.contains(digit)) {
          int currentIndex = selectedDigits.indexOf(digit);
          selectedDigits[currentIndex] = null;
        }
        return true;
      },
    );
  }
}
