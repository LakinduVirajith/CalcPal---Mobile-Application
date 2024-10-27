import 'package:calcpal/models/activity_result.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/operational_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:calcpal/screens/multiplication_level1.dart';
import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubtractionLevel1Screen extends StatefulWidget {
  final String title;
  final int number1;
  final int number2;
  final IconData icon;
  final bool isActivity4;

  const SubtractionLevel1Screen({
    super.key,
    required this.title,
    required this.number1,
    required this.number2,
    required this.icon,
    this.isActivity4 = false,
  });

  @override
  _SubtractionLevel1ScreenState createState() =>
      _SubtractionLevel1ScreenState();
}

class _SubtractionLevel1ScreenState extends State<SubtractionLevel1Screen> {
  late int correctAnswer;
  int retryCount = 0;
  late Stopwatch stopwatch; // For timing

  String completionDate = ''; // For storing the current date
  int totalTimeTaken = 0; //For Storing time take for the activity
  int totalScore = 0; //For Storing total acore for the activity
  int correctCount = 0; //For Stroing no of correctly ans excercises

  final UserService _userService = UserService();
  final OperationalService _activityService = OperationalService();
  final ToastService _toastService = ToastService();

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    correctAnswer = widget.number1 - widget.number2;
    stopwatch.start();
  }

  void showFeedback(bool isCorrect) {
    if (isCorrect) {
      correctCount++;
      if (retryCount == 0) {
        totalScore += 10; //  10 points if correct on first try
      } else if (retryCount == 1) {
        totalScore += 5; //  5 points if correct on second try
      }
      retryCount = 0; // Reset retry count for the next question
    } else {
      retryCount++; // Increment retryCount if the answer is incorrect
    }
    if (isCorrect) {
      _toastService.successToast(AppLocalizations.of(context)!.correctToast);
      Future.delayed(const Duration(seconds: 1), () {
        moveToNextActivity(context,
            widget.isActivity4); // Move to next activity after 1 second
      });
    } else {
      _toastService.errorToast(AppLocalizations.of(context)!.tryAgainToast);
    }
  }

  Future<void> _submitResultsToDB() async {
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
    late bool activityStatus;

    // Update user disorder status in the database
    activityStatus = await _activityService.addActivityResult(ActivityResult(
      userEmail: user.email,
      date: completionDate,
      activityName: 'Level1 - Subtraction',
      timeTaken: totalTimeTaken,
      totalScore: totalScore,
      retries: correctCount,
    ));

    // Navigate based on the status of updates
    if (activityStatus) {
      _handleSuccess(AppLocalizations.of(context)!.progressStoredTxt);
      // Navigate to MultiplicationScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiplicationLevel1Screen(
            number1: 3,
            number2: 2,
            title: "5 : ${AppLocalizations.of(context)!.opActivityLvl1Mul} 😊",
            icon: FontAwesomeIcons.book,
          ),
        ),
      );
    } else {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesSomethingWrongError);
    }
  }

  void _handleErrorAndRedirect(String message) {
    // Handle errors and redirect
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  void _handleSuccess(String message) {
    // Handle errors and redirect
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ));
  }

  void moveToNextActivity(BuildContext context, bool isActivity4) {
    if (isActivity4) {
      //Submit Subtraction level 1 results
      completionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      stopwatch.stop();
      totalTimeTaken = stopwatch.elapsed.inSeconds;

      _submitResultsToDB();
    } else {
      // Navigate to Activity 4 (Subtraction)
      int rand1 = Random().nextInt(4) + 6; // Random number between 6 and 15
      int rand2 = Random().nextInt(6) + 1; // Random number between 1 and 6
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubtractionLevel1Screen(
            title:
                "4 : ${AppLocalizations.of(context)!.opActivityLvl1Sub} $rand1 - $rand2",
            number1: rand1,
            number2: rand2,
            icon: FontAwesomeIcons.mugHot,
            isActivity4: true,
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
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/level1general.png'),
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
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(
                          0.6), // Contrasting background color with transparency
                      border: Border.all(
                        color: Colors
                            .white, // Border color to contrast with background
                        width: 1, // Thin border
                      ),
                      borderRadius:
                          BorderRadius.circular(4), // Optional: rounded corners
                    ),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Number and Icons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // First Number and Icons
                    buildNumberBox(widget.number1, false, showNumber: false),
                    const SizedBox(width: 20),
                    // Subtraction Sign
                    const Text(
                      '-',
                      style: TextStyle(
                        fontSize: 48,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Second Number and Icons
                    buildNumberBox(widget.number2, false, showNumber: false),
                    const SizedBox(height: 30),
                    // Equal Sign
                    const Text(
                      '=',
                      style: TextStyle(fontSize: 48, color: Colors.black),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // Visualization of the Answer (With Crossed-Out Icons)
                buildNumberBox(widget.number1, true, showNumber: false),
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
        ],
      ),
    );
  }

  // Helper function to build number box with icons and optional number
  Widget buildNumberBox(int number, bool crossedOut,
      {required bool showNumber}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Icons with Crossed-Out Option
              Wrap(
                children: List.generate(number, (index) {
                  bool shouldCrossOut =
                      crossedOut && index >= (widget.number1 - widget.number2);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        size: 30,
                        color: shouldCrossOut
                            ? Colors.red.withOpacity(0.5)
                            : Colors.green,
                      ),
                      if (shouldCrossOut)
                        const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 35,
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
        // Conditionally Display Number
        if (showNumber) const SizedBox(height: 10),
        if (showNumber)
          Text(
            '$number',
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
      ],
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
