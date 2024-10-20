import 'package:calcpal/models/ideognostic_question.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calcpal/screens/diagnose_ideognostic_type2.dart';
import 'package:calcpal/services/ideognostic_service.dart';
import 'dart:async'; // Import for Timer
import 'dart:convert'; // Import to handle base64 encoding
import '../widgets/fraction_button.dart';

class DiagnoseIdeognosticScreen extends StatefulWidget {
  const DiagnoseIdeognosticScreen({super.key});

  @override
  _DiagnoseIdeognosticScreenState createState() =>
      _DiagnoseIdeognosticScreenState();
}

class _DiagnoseIdeognosticScreenState extends State<DiagnoseIdeognosticScreen> {
  IdeognosticQuestion? _questionData;
  int questionNumber = 1;
  late Stopwatch _stopwatch; // To track time
  // Create an instance of IdeognosticService
  final ideognosticService = IdeognosticService();
  int _q1Answer =
      0; // To store the answer for question 1 (0 means incorrect, 1 means correct)

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch(); // Initialize stopwatch
    _stopwatch.start(); // Start the timer when the quiz begins
    _fetchQuestionData(1);
  }

  Future<void> _fetchQuestionData(int question) async {
    // Fetch the question data and assign it to _questionData
    _questionData = await ideognosticService.fetchIdeognosticQuestion(question);

    setState(() {});
  }

  @override
  void dispose() {
    _stopwatch.stop(); // Stop the timer when the screen is disposed
    super.dispose();
  }

  void _navigateToNextQuestion(bool isCorrect) {
    if (questionNumber == 1) {
      setState(() {
        questionNumber = 2; // Navigate to the second question
        _q1Answer = isCorrect ? 1 : 0; // Store if the answer is correct
      });
      _fetchQuestionData(2); // Fetch data for the second question
    } else if (questionNumber == 2) {
      int q2Answer = isCorrect ? 1 : 0;
      print("q1: $_q1Answer");
      print("q2: $q2Answer");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiagnoseIdeognosticType2Screen(
            timeTaken: _stopwatch
                .elapsedMilliseconds, // Pass the accumulated time taken
            q1Answer: _q1Answer, // Pass whether the first question was correct
            q2Answer: q2Answer, // Pass whether the second question was correct
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
      body: _questionData == null
          ? Center(
              child:
                  CircularProgressIndicator(), // Show loading while data is fetched
            )
          : Stack(
              children: [
                // Background Image
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/diagnose_id_background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Content with Grey Box
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 20), // Reduced side padding
                    width: MediaQuery.of(context).size.width *
                        0.55, // Adjusted width
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800
                          .withOpacity(0.8), // Semi-transparent grey color
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Question Text
                        Text(
                          _questionData!.question,
                          style: TextStyle(
                            fontSize: 20,
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
                          child: _questionData != null &&
                                  _questionData!.base64image.isNotEmpty
                              ? Image.memory(
                                  base64Decode(_questionData!
                                      .base64image), // Decode the base64 string
                                  height: 100,
                                  width: 100,
                                )
                              : const CircularProgressIndicator(), // Show loading indicator if data is not ready
                        ),
                        const SizedBox(height: 40),
                        // Options
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _questionData != null
                              ? _questionData!.allAnswers.map((answer) {
                                  // Split the fraction into numerator and denominator
                                  final Map<int, String> correctAnswers = {
                                    1: '1/2',
                                    2: '1/4',
                                  };
                                  final parts = answer.split('/');
                                  final numerator = parts[0];
                                  final denominator = parts[1];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: FractionButton(
                                      numerator: numerator,
                                      denominator: denominator,
                                      onPressed: () {
                                        // Check if the answer is correct
                                        bool isCorrect = (answer ==
                                            correctAnswers[questionNumber]);

                                        _navigateToNextQuestion(isCorrect);
                                      },
                                    ),
                                  );
                                }).toList()
                              : [
                                  const CircularProgressIndicator()
                                ], // Show loading if _questionData is null
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
