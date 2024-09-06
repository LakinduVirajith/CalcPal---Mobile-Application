import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/operational_question.dart';
import '../services/operational_service.dart';

class DiagnoseOperationalScreen extends StatefulWidget {
  const DiagnoseOperationalScreen({super.key});

  @override
  _DiagnoseOperationalScreenState createState() =>
      _DiagnoseOperationalScreenState();
}

class _DiagnoseOperationalScreenState extends State<DiagnoseOperationalScreen> {
  OperationalQuestion? _questionData; // Changed this to OperationalQuestion?
  int _currentQuestionNumber = 1;
  bool _isAnswerSubmitted = false;
  List<bool> _answersCorrect = [];
  int _totalScore = 0;
  late Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _fetchQuestion();
  }

  Future<void> _fetchQuestion() async {
    _stopwatch.start();

    // Create an instance of OperationalService
    final operationalService = OperationalService();

    // Fetch the question data and assign it to _questionData
    _questionData = await operationalService
        .fetchOperationalQuestion(_currentQuestionNumber);

    // Update the UI after fetching the question
    setState(() {
      _isAnswerSubmitted =
          false; // Reset answer submitted state when fetching a new question
    });
  }

  void _submitAnswer(int selectedAnswer) {
    setState(() {
      _isAnswerSubmitted = true;

      if (_questionData != null &&
          selectedAnswer == _questionData!.correctAnswer) {
        _totalScore++;
        _answersCorrect.add(true);
      } else {
        _answersCorrect.add(false);
      }

      if (_currentQuestionNumber < 5) {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _currentQuestionNumber++;
            _fetchQuestion();
          });
        });
      } else {
        _stopwatch.stop();
        // Store or process the total score and time taken here
        print('Total Score: $_totalScore');
        print('Time Taken: ${_stopwatch.elapsed.inSeconds} seconds');
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
      body: _questionData == null
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching
          : Stack(
              children: [
                // Background Image
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/diagnose_op_background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: Text(
                      '$_currentQuestionNumber',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Content with Grey Box
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 40),
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800
                          .withOpacity(0.8), // Semi-transparent grey color
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 50),
                        // Question Text
                        Text(
                          'Select the correct answer for -',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Expression
                        Text(
                          _questionData!.question,
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Options
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _questionData!.allAnswers.map((answer) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0), // Space between buttons
                              child: OptionButton(
                                label: answer.toString(),
                                onPressed: _isAnswerSubmitted
                                    ? null
                                    : () {
                                        _submitAnswer(answer);
                                      },
                                backgroundColor: _isAnswerSubmitted
                                    ? (answer == _questionData!.correctAnswer
                                        ? Colors.green
                                        : Colors.red)
                                    : Colors.black,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;

  const OptionButton({
    required this.label,
    this.onPressed,
    required this.backgroundColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            vertical: 20, horizontal: 40), // Padding added here
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
