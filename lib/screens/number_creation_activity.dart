import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Import for Stopwatch
import 'dart:math';
import '../screens/activity_ideognostic.dart';

class NumberCreationActivityScreen extends StatefulWidget {
  const NumberCreationActivityScreen({super.key});

  @override
  _NumberCreationActivityScreenState createState() =>
      _NumberCreationActivityScreenState();
}

class _NumberCreationActivityScreenState
    extends State<NumberCreationActivityScreen> {
  final PageController _pageController = PageController();
  final List<bool> _isCorrectAnswers = [];
  final List<int> _retryCounts = [];
  int _completedExercises = 0; // Track the number of completed exercises
  Stopwatch _stopwatch = Stopwatch(); // Stopwatch to track time

  @override
  void initState() {
    super.initState();
    _initializeResults();
    _stopwatch.start(); // Start the stopwatch
  }

  void _initializeResults() {
    _isCorrectAnswers.clear();
    _retryCounts.clear();
    for (int i = 0; i < 4; i++) {
      _isCorrectAnswers.add(false);
      _retryCounts.add(0);
    }
  }

  void _updateResults(int index, bool isCorrect, int retryCount) {
    setState(() {
      _isCorrectAnswers[index] = isCorrect;
      _retryCounts[index] = retryCount;
      _completedExercises++;

      // Check if all exercises are completed
      if (_completedExercises == 4) {
        _stopwatch.stop(); // Stop the stopwatch
        _printResults();
      }
    });
  }

  void _printResults() {
    print(
        'Time taken: ${_stopwatch.elapsed.inSeconds} seconds'); // Print elapsed time
    for (int i = 0; i < _isCorrectAnswers.length; i++) {
      print(
          'Exercise ${i + 1}: Correct - ${_isCorrectAnswers[i]}, Retries - ${_retryCounts[i]}');
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
      body: PageView(
        controller: _pageController,
        children: List.generate(4, (index) {
          final int exerciseNumber = index + 1;
          final String backgroundImagePath =
              'assets/images/ideognostic_activities/numbercre_$exerciseNumber.png';
          return NumberCreationExerciseScreen(
            numberOfDigits: exerciseNumber == 1 || exerciseNumber == 2
                ? 2
                : (exerciseNumber == 3 ? 3 : 4),
            exerciseTitle: _getExerciseTitle(exerciseNumber),
            isLargestNumber:
                exerciseNumber != 2, // Logic to determine largest or smallest
            backgroundImagePath: backgroundImagePath,
            pageController: _pageController,
            onExerciseCompleted: (bool isCorrect, int retryCount) {
              _updateResults(index, isCorrect, retryCount);
            },
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
  final Function(bool isCorrect, int retryCount) onExerciseCompleted;

  const NumberCreationExerciseScreen({
    super.key,
    required this.numberOfDigits,
    required this.exerciseTitle,
    required this.isLargestNumber,
    required this.backgroundImagePath,
    required this.pageController,
    required this.onExerciseCompleted,
  });

  @override
  _NumberCreationExerciseScreenState createState() =>
      _NumberCreationExerciseScreenState();
}

class _NumberCreationExerciseScreenState
    extends State<NumberCreationExerciseScreen> {
  late List<int?> _answers;
  late List<int> _availableDigits;
  late List<int> _correctAnswer;
  int _retryCount = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeExercise();
  }

  void _initializeExercise() {
    _answers = List.filled(widget.numberOfDigits, null);
    _availableDigits = _generateAvailableDigits(widget.numberOfDigits);

    // Sort _correctAnswer based on whether it's the largest or smallest number
    _correctAnswer = _availableDigits.take(widget.numberOfDigits).toList()
      ..sort((a, b) => widget.isLargestNumber ? b - a : a - b);
  }

  List<int> _generateAvailableDigits(int count) {
    // Generate a list of random digits between 0 and 9
    return List<int>.generate(count, (_) => _random.nextInt(10));
  }

  void _checkAnswer() {
    if (_answers.every((element) => element != null) &&
        _answers.join() == _correctAnswer.join()) {
      widget.onExerciseCompleted(true, _retryCount);
      _showSuccessDialog();
    } else {
      _retryCount++;
      if (_retryCount < 3) {
        _showRetryDialog();
      } else {
        widget.onExerciseCompleted(false, _retryCount);
        _showCorrectAnswerDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: const Text('Correct! 🎉'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not Quite Right'),
        content: const Text('Let\'s try again!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _initializeExercise(); // Reset the screen
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showCorrectAnswerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Correct Answer'),
        content: Text('The correct answer is ${_correctAnswer.join()}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
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
                    fontSize: 20,
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceEvenly, // Adjust alignment as needed
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _checkAnswer,
                        child: const Text('Submit'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => ActivityIdeognosticScreen(),
                            ),
                          );
                        },
                        child: const Text('Back'),
                      ),
                    ],
                  ),
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
      childWhenDragging: _buildDigitBox(digit, opacity: 0.5),
    );
  }

  Widget _buildDragTarget(int index) {
    return DragTarget<int>(
      onAccept: (digit) {
        setState(() {
          _answers[index] = digit;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return _buildDigitBox(
          _answers[index] ?? 0,
          isEmpty: _answers[index] == null,
        );
      },
    );
  }

  Widget _buildDigitBox(int digit,
      {bool isDragging = false, double opacity = 1.0, bool isEmpty = false}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isEmpty ? Colors.grey : Colors.blue,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: Text(
          isEmpty ? '' : digit.toString(),
          style: TextStyle(
            fontSize: 24,
            color: isEmpty ? Colors.black.withOpacity(0.5) : Colors.white,
          ),
        ),
      ),
    );
  }
}
