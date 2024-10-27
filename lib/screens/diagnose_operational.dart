import 'package:calcpal/models/diagnosis_result_op.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/operational_question.dart';
import '../models/diagnosis.dart';
import '../models/flask_diagnosis_result.dart';
import '../models/user.dart';
import '../services/operational_service.dart';
import '../services/user_service.dart';
import '../enums/disorder_types.dart';
import '../constants/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DiagnoseOperationalScreen extends StatefulWidget {
  const DiagnoseOperationalScreen({super.key});

  @override
  _DiagnoseOperationalScreenState createState() =>
      _DiagnoseOperationalScreenState();
}

class _DiagnoseOperationalScreenState extends State<DiagnoseOperationalScreen> {
  OperationalQuestion? _questionData;
  int _currentQuestionNumber = 1;
  bool _isAnswerSubmitted = false;
  final List<bool> _answersCorrect = [];
  int _totalScore = 0;
  late Stopwatch _stopwatch;

  final UserService _userService = UserService();
  final OperationalService _questionService = OperationalService();

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
        // Call the method to submit results to the ML model
        _submitResultsToMLModel();
      }
    });
  }

  Future<void> _submitResultsToMLModel() async {
    // Stop timer and record the time
    _stopwatch.stop();
    final elapsedTimeInSeconds = _stopwatch.elapsedMilliseconds / 1000;
    final roundedElapsedTimeInSeconds = elapsedTimeInSeconds.round();

    // Calculate total score
    final totalScore = _totalScore;

    // Get shared preference
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesAccessTokenError);
      return;
    }

    // Fetch user
    User? user = await _userService.getUser(accessToken, context);

    if (user == null || user.iqScore == null) {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesIQScoreError);
      return;
    }

    // Variables to store diagnosis and status
    late bool diagnoseStatus;
    late bool status;
    late bool updateStatus;

    // Prepare diagnosis data and fetch diagnosis result from the service
    FlaskDiagnosisResult? diagnosis = await _questionService.getDiagnosisResult(
        Diagnosis(
          age: user.age,
          iq: user.iqScore!,
          q1: _answersCorrect[0] ? 1 : 0,
          q2: _answersCorrect[1] ? 1 : 0,
          q3: _answersCorrect[2] ? 1 : 0,
          q4: _answersCorrect[3] ? 1 : 0,
          q5: _answersCorrect[4] ? 1 : 0,
          seconds: roundedElapsedTimeInSeconds,
        ),
        context);

    // Check if diagnosis result is valid and get diagnose status
    if (diagnosis != null && diagnosis.prediction != null) {
      diagnoseStatus = diagnosis.prediction!;
    } else {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesResultError);
      return;
    }

    // Update user disorder status in the database
    status = await _questionService.addDiagnosisResult(DiagnosisResultOp(
        userEmail: user.email,
        quizTimeTaken: roundedElapsedTimeInSeconds,
        q1: _answersCorrect[0],
        q2: _answersCorrect[1],
        q3: _answersCorrect[2],
        q4: _answersCorrect[3],
        q5: _answersCorrect[4],
        score: totalScore.toString(),
        diagnosis: diagnoseStatus));

    // Update user disorder type in the service
    if (diagnoseStatus) {
      updateStatus = await _userService.updateDisorderType(
          DisorderTypes.operational, accessToken, context);
    } else {
      updateStatus = await _userService.updateDisorderType(
          DisorderTypes.nonOperational, accessToken, context);
    }
    print(status);
    print(updateStatus);

    // Navigate based on the status of updates
    if (status && updateStatus) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        diagnoseResultRoute, // Change this to your actual route
        (route) => false,
        arguments: {
          'diagnoseType': 'operational',
          'totalScore': totalScore,
          'elapsedTime': roundedElapsedTimeInSeconds,
        },
      );
    } else {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesSomethingWrongError);
    }
  }

  void _handleErrorAndRedirect(String message) {
    // Handle errors and redirect as needed
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
    // Redirect or other error handling
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
          ? const Center(
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
                    decoration: const BoxDecoration(
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
                          AppLocalizations.of(context)!.operationalQuestion,
                          style: TextStyle(
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
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
