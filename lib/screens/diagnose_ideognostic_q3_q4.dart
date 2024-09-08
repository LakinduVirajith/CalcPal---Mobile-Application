import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'dart:async';
import 'dart:math';

import 'diagnose_ideognostic_last_ques.dart';

class DiagnoseIdeognosticType2Screen extends StatefulWidget {
  final int timeTaken;
  final int q1Answer;
  final int q2Answer;

  const DiagnoseIdeognosticType2Screen({
    super.key,
    required this.timeTaken,
    required this.q1Answer,
    required this.q2Answer,
  });

  @override
  _DiagnoseIdeognosticType2ScreenState createState() =>
      _DiagnoseIdeognosticType2ScreenState();
}

class _DiagnoseIdeognosticType2ScreenState
    extends State<DiagnoseIdeognosticType2Screen> {
  final List<int?> _answers = [null, null, null];
  late List<int> _availableDigits; // To store randomly chosen digits
  Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _generateRandomDigits();
    _stopwatch.start(); // Start stopwatch when entering Q3
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  void _generateRandomDigits() {
    final allDigits = List<int>.generate(9, (i) => i + 1);
    final random = Random();
    allDigits.shuffle(random); // Shuffle the list
    _availableDigits = allDigits.take(3).toList(); // Take first 3 digits
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 30),
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: Colors.grey.shade800.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Use the 3 digits below and make the largest number possible',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _availableDigits
                        .map((digit) => _buildDraggableDigit(digit))
                        .toList(),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        3, (index) => _buildDragTarget(index, _answers[index])),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () {
                      _stopwatch.stop();
                      _navigateToFourthQuestion(
                          context, _stopwatch.elapsedMilliseconds);
                    },
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

  void _navigateToFourthQuestion(BuildContext context, int elapsedTimeForQ3) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FourthQuestionScreen(
          timeTaken:
              widget.timeTaken, // Pass accumulated time taken for Q1 and Q2
          q1Answer: widget.q1Answer,
          q2Answer: widget.q2Answer,
          q3Answer: _validateAnswer(_answers),
          elapsedTimeForQ3: elapsedTimeForQ3, // Pass elapsed time for Q3
        ),
      ),
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
          _availableDigits.remove(receivedDigit);
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 80.0,
          height: 80.0,
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
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isDragging ? Colors.grey : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (!isDragging)
              const BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 4,
              ),
          ],
        ),
        child: Text(
          digit.toString(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class FourthQuestionScreen extends StatefulWidget {
  final int timeTaken;
  final int q1Answer;
  final int q2Answer;
  final int? q3Answer;
  final int elapsedTimeForQ3;

  const FourthQuestionScreen({
    super.key,
    required this.timeTaken,
    required this.q1Answer,
    required this.q2Answer,
    required this.q3Answer,
    required this.elapsedTimeForQ3,
  });

  @override
  _FourthQuestionScreenState createState() => _FourthQuestionScreenState();
}

class _FourthQuestionScreenState extends State<FourthQuestionScreen> {
  final List<int?> _answers = [null, null, null, null];
  late List<int> _availableDigits;
  Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _generateRandomDigits();
    _stopwatch.start(); // Start stopwatch when entering Q4
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  void _generateRandomDigits() {
    final allDigits = List<int>.generate(9, (i) => i + 1);
    final random = Random();
    allDigits.shuffle(random); // Shuffle the list
    _availableDigits = allDigits.take(4).toList(); // Take first 4 digits
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              width: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                color: Colors.grey.shade800.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Use these digits and make the largest number possible',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _availableDigits
                        .map((digit) => _buildDraggableDigit(digit))
                        .toList(),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        4, (index) => _buildDragTarget(index, _answers[index])),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () {
                      _stopwatch.stop();
                      _navigateToFinalScreen(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Submit',
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

  void _navigateToFinalScreen(BuildContext context) {
    final totalTimeForQ4 = _stopwatch.elapsedMilliseconds;
    final totalTime =
        widget.timeTaken + widget.elapsedTimeForQ3 + totalTimeForQ4;

    final q4Answer = _validateAnswer(_answers);

    print('Time taken for Q1 and Q2: ${widget.timeTaken}');
    print('Elapsed time for Q3: ${widget.elapsedTimeForQ3}');
    print('Elapsed time for Q4: $totalTimeForQ4');
    print('Total time taken: $totalTime');
    print('Q1 Answer: ${widget.q1Answer}');
    print('Q2 Answer: ${widget.q2Answer}');
    print('Q3 Answer: ${widget.q3Answer}');
    print('Q4 Answer: $q4Answer');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DiagnoseIdeognosticLastScreen(
          q1Answer: widget.q1Answer,
          q2Answer: widget.q2Answer,
          q3Answer: widget.q3Answer!,
          q4Answer: q4Answer,
          totalTime: totalTime, // Total time for all questions
        ),
      ),
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
          _availableDigits.remove(receivedDigit);
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 80,
          height: 80,
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
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isDragging ? Colors.grey : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (!isDragging)
              const BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
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

int _validateAnswer(List<int?> answers) {
  // Check if there are any null values
  if (answers.contains(null)) return 0;

  // Convert nullable integers to non-nullable integers
  final digits = List<int>.from(answers.whereType<int>());

  // Convert integers to strings and sort in descending order
  final sortedDigits = digits.map((e) => e.toString()).toList();
  sortedDigits.sort((a, b) => b.compareTo(a)); // Sort strings as numbers

  // Join the sorted strings to form the largest number
  final largestNumberStr = sortedDigits.join();
  final largestNumber = int.parse(largestNumberStr);

  // Convert original list to string and then to number
  final answerStr = digits.map((e) => e.toString()).join();
  final answer = int.parse(answerStr);

  return answer == largestNumber ? 1 : 0;
}
