import 'package:calcpal/models/activity_result.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/operational_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:calcpal/screens/subtraction_level1.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OperationalLevel1Screen extends StatefulWidget {
  const OperationalLevel1Screen({super.key});

  @override
  _OperationalLevel1ScreenState createState() =>
      _OperationalLevel1ScreenState();
}

class _OperationalLevel1ScreenState extends State<OperationalLevel1Screen> {
  int number1 = Random().nextInt(5) + 1; // Random number between 1 and 5
  int number2 = Random().nextInt(5) + 1; // Random number between 1 and 5
  int correctAnswer = 0;
  bool isActivity1 = true;
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
    correctAnswer = number1 + number2;
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
        moveToNextActivity(); // Move to next activity after 1 second
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
      activityName: 'Level1 - Addition',
      timeTaken: totalTimeTaken,
      totalScore: totalScore,
      retries: correctCount,
    ));

    // Navigate based on the status of updates
    if (activityStatus) {
      _handleSuccess(AppLocalizations.of(context)!.progressStoredTxt);
      int rand = Random().nextInt(4) + 1;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubtractionLevel1Screen(
            title:
                "3 : ${AppLocalizations.of(context)!.opActivityLvl1Sub} 5 - $rand", // Set the title for Activity 4
            number1: 5,
            number2: rand, // Random number between 1 and 4
            icon: FontAwesomeIcons.leaf,
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

  void moveToNextActivity() {
    setState(() {
      if (isActivity1) {
        // Move to Activity 2
        number1 = 5;
        number2 = Random().nextInt(4) + 6; // Random number between 6 and 10
        correctAnswer = number1 + number2;
        isActivity1 = false;
      } else {
        //Submit Addition level 1 results
        completionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

        stopwatch.stop();
        totalTimeTaken = stopwatch.elapsed.inSeconds;

        _submitResultsToDB();
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
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
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
                  top: 40,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4), // Add padding around the text
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(
                          0.6), // Set a contrasting background color with some transparency
                      border: Border.all(
                        color: Colors
                            .white, // Set border color to contrast with background
                        width: 1, // Very thin border
                      ),
                      borderRadius:
                          BorderRadius.circular(4), // Optional: rounded corners
                    ),
                    child: Text(
                      isActivity1
                          ? "1 : ${AppLocalizations.of(context)!.opActivityLvl1Add} $number1 + $number2"
                          : "2 : ${AppLocalizations.of(context)!.opActivityLvl1Add} $number1 + $number2",
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Number and Apples/Sweets Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // First Number and Apples/Sweets
                    buildNumberBox(number1, showNumber: false),
                    const SizedBox(width: 20),
                    // Plus Sign
                    const Text(
                      '+',
                      style: TextStyle(fontSize: 48, color: Colors.black),
                    ),
                    const SizedBox(width: 20),
                    // Second Number and Apples/Sweets
                    buildNumberBox(number2, showNumber: false),
                    const SizedBox(height: 30),
                    // Equal Sign
                    const Text(
                      '=',
                      style: TextStyle(fontSize: 48, color: Colors.black),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // Visualization of the Correct Answer (Without Number)
                buildNumberBox(correctAnswer, showNumber: false),
                const SizedBox(height: 30),
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

  // Helper function to build number box with apples/sweets and optional number
  Widget buildNumberBox(int number, {required bool showNumber}) {
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
              // Apples/Sweets
              Wrap(
                children: List.generate(number, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      isActivity1
                          ? FontAwesomeIcons.appleAlt
                          : FontAwesomeIcons.candyCane,
                      size: 30,
                      color: isActivity1 ? Colors.red : Colors.purple,
                    ),
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
