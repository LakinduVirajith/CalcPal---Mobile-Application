import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberCreationActivityScreen extends StatefulWidget {
  const NumberCreationActivityScreen({super.key});

  @override
  _NumberCreationActivityScreenState createState() =>
      _NumberCreationActivityScreenState();
}

class _NumberCreationActivityScreenState
    extends State<NumberCreationActivityScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: List.generate(4, (index) {
          final int exerciseNumber = index + 1;
          final String backgroundImagePath =
              'assets/images/background_exercise$exerciseNumber.png';
          return NumberCreationExerciseScreen(
            numberOfDigits: exerciseNumber == 1 || exerciseNumber == 2
                ? 2
                : (exerciseNumber == 3 ? 3 : 4),
            exerciseTitle: _getExerciseTitle(exerciseNumber),
            isLargestNumber:
                exerciseNumber != 2, // Logic to determine largest or smallest
            backgroundImagePath: backgroundImagePath,
            pageController: _pageController,
          );
        }),
      ),
    );
  }

  String _getExerciseTitle(int exerciseNumber) {
    switch (exerciseNumber) {
      case 1:
        return 'Create the Largest 2-Digit Number';
      case 2:
        return 'Create the Smallest 2-Digit Number';
      case 3:
        return 'Create the Largest 3-Digit Number';
      case 4:
        return 'Create the Largest 4-Digit Number';
      default:
        return '';
    }
  }
}

class NumberCreationExerciseScreen extends StatefulWidget {
  final int numberOfDigits;
  final String exerciseTitle;
  final bool isLargestNumber;
  final String backgroundImagePath;
  final PageController pageController;

  const NumberCreationExerciseScreen({
    super.key,
    required this.numberOfDigits,
    required this.exerciseTitle,
    required this.isLargestNumber,
    required this.backgroundImagePath,
    required this.pageController,
  });

  @override
  _NumberCreationExerciseScreenState createState() =>
      _NumberCreationExerciseScreenState();
}

class _NumberCreationExerciseScreenState
    extends State<NumberCreationExerciseScreen> {
  late List<int?> _answers;
  late List<int> _availableDigits;

  @override
  void initState() {
    super.initState();
    _answers = List.filled(widget.numberOfDigits, null);
    _availableDigits = _generateAvailableDigits(widget.numberOfDigits);
    _availableDigits.sort((a, b) => widget.isLargestNumber ? b - a : a - b);
  }

  List<int> _generateAvailableDigits(int count) {
    return List<int>.generate(count, (index) => (index + 1) % 10);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(widget.backgroundImagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              color: Colors.grey.shade800.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.exerciseTitle,
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _availableDigits
                      .map((digit) => _buildDraggableDigit(digit))
                      .toList(),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.numberOfDigits,
                      (index) => _buildDragTarget(index)),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    widget.pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildDragTarget(int index) {
    return DragTarget<int>(
      onAccept: (receivedDigit) {
        setState(() {
          _answers[index] = receivedDigit;
          _availableDigits.remove(receivedDigit);
        });
      },
      onWillAccept: (receivedDigit) {
        return receivedDigit != _answers[index];
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
              _answers[index]?.toString() ?? '',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
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
}
