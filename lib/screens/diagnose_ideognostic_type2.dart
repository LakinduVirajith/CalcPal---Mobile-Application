import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../widgets/drag_drop_widgets.dart';
import 'diagnose_ideognostic_type3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  int questionNumber = 3;
  late int q3Answer;
  late List<int?> _answers; // Adjusted to reset dynamically
  late List<int> _availableDigits; // To store randomly chosen digits
  Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start(); // Start stopwatch when entering Q3

    // Initialize the state for Q3
    _initializeQuestion();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  void _initializeQuestion() {
    setState(() {
      // Set the number of digits and reset answers accordingly
      int numberOfDigits = questionNumber == 3 ? 3 : 4;
      _answers = List<int?>.filled(numberOfDigits, null);
      _availableDigits = _generateRandomDigits(numberOfDigits);
    });
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width *
                    0.65, // 70% of screen width
                maxHeight: MediaQuery.of(context).size.height *
                    0.90, // 80% of screen height
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      questionNumber == 3
                          ? AppLocalizations.of(context)!
                              .ideognosticQuestionType2_largest
                          : AppLocalizations.of(context)!
                              .ideognosticQuestionType2_smallest,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _availableDigits
                          .map((digit) =>
                              CommonWidgets.buildDraggableDigit(digit))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _answers.length,
                        (index) => CommonWidgets.buildDragTarget(
                          index: index,
                          currentDigit: _answers[index],
                          onAccept: (int receivedDigit) {
                            setState(() {
                              _answers[index] = receivedDigit;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _navigateToNextQuestion();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.nextBtnText,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _navigateToNextQuestion() {
    if (questionNumber == 3) {
      setState(() {
        questionNumber = 4;
        q3Answer = _validateAnswer(_answers, 3); // For Q3
        _initializeQuestion(); // Reset for Q4
      });
    } else if (questionNumber == 4) {
      _stopwatch.stop(); // Stop the stopwatch for the final question
      int elapsedTime = _stopwatch.elapsedMilliseconds;

      // Validate answers for both Q3 and Q4
      int q4Answer = _validateAnswer(_answers, 4); // For Q4

      // Navigate to the last question
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiagnoseIdeognosticLastScreen(
            timeTaken: widget.timeTaken + elapsedTime,
            q1Answer: widget.q1Answer,
            q2Answer: widget.q2Answer,
            q3Answer: q3Answer,
            q4Answer: q4Answer,
          ),
        ),
      );
    }
  }

  int _validateAnswer(List<int?> answers, int numberOfDigits) {
    // Check if there are any null values in the provided answers
    if (answers.contains(null)) return 0;

    // Convert nullable integers to non-nullable integers
    final digits = List<int>.from(answers.whereType<int>());

    // Ensure the number of digits matches the expected count
    if (digits.length != numberOfDigits) return 0;

    // Sort digits based on the question logic
    List<int> correctDigits = List.from(digits);
    if (numberOfDigits == 3) {
      // For Q3: Sort descending to make the largest number
      correctDigits.sort((a, b) => b.compareTo(a));
    } else if (numberOfDigits == 4) {
      // For Q4: Sort ascending to make the smallest number
      correctDigits.sort();
    }

    // Convert sorted correct digits into a number
    final correctAnswer =
        int.parse(correctDigits.map((e) => e.toString()).join());

    // Convert the original digits (as provided by the user) into a number
    final providedAnswer = int.parse(answers.map((e) => e.toString()).join());

    // Return 1 if the provided answer matches the correct answer, otherwise 0
    return correctAnswer == providedAnswer ? 1 : 0;
  }

  List<int> _generateRandomDigits(int number) {
    final allDigits = List<int>.generate(9, (i) => i + 1);
    allDigits.shuffle(Random()); // Shuffle the list
    return allDigits.take(number).toList();
  }
}
