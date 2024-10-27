import 'package:calcpal/models/activity_result.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/screens/division_level1.dart';
import 'package:calcpal/services/operational_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MultiplicationLevel1Screen extends StatefulWidget {
  final int number1;
  final int number2;
  final String title;
  final IconData icon;

  const MultiplicationLevel1Screen({
    super.key,
    required this.number1,
    required this.number2,
    required this.title,
    required this.icon,
  });

  @override
  _MultiplicationLevel1ScreenState createState() =>
      _MultiplicationLevel1ScreenState();
}

class _MultiplicationLevel1ScreenState
    extends State<MultiplicationLevel1Screen> {
  late int correctAnswer;
  late Color iconColor;

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
    correctAnswer = widget.number1 * widget.number2;

    // Set the icon color based on the title
    if (widget.title.contains('5')) {
      iconColor = Colors.blue;
    } else if (widget.title.contains('6')) {
      iconColor = Colors.orange;
    } else {
      iconColor = Colors.green;
    }
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
        navigateToNextActivity(); // Move to next activity after 1 second
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
      activityName: 'Level1 - Multiplication',
      timeTaken: totalTimeTaken,
      totalScore: totalScore,
      retries: correctCount,
    ));

    // Navigate based on the status of updates
    if (activityStatus) {
      _handleSuccess(AppLocalizations.of(context)!.progressStoredTxt);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DivisionLevel1Screen(
            number1: 10, // Set appropriate number1 for the next activity
            number2: 2, // Set appropriate number2 for the next activity
            title:
                '7 : - ${AppLocalizations.of(context)!.opActivityLvl1Div} 😊', // Set the new title
            icon: FontAwesomeIcons.flag, // Set the appropriate icon
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

  void navigateToNextActivity() {
    if (widget.title.contains('5')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiplicationLevel1Screen(
            number1: 4, // Set appropriate number1 for Activity 6
            number2: 3, // Set appropriate number2 for Activity 6
            title:
                '6 : ${AppLocalizations.of(context)!.opActivityLvl1Mul} 😊', // Set the new title
            icon: FontAwesomeIcons.book, // Set the appropriate icon
          ),
        ),
      );
    } else {
      //Submit Multiplication level 1 results
      completionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      stopwatch.stop();
      totalTimeTaken = stopwatch.elapsed.inSeconds;

      _submitResultsToDB();
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
                const SizedBox(height: 30),
                // Number and Icons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // First Number and Icons
                    buildNumberBox(widget.number1),
                    const SizedBox(width: 20),
                    // Multiplication Sign and Second Number
                    Text(
                      'x ${widget.number2}',
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Equal Sign
                    const Text(
                      '=',
                      style: TextStyle(fontSize: 48, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Answer Visualization (Separated by a Border)
                buildAnswerBox(widget.number1, widget.number2),
                const SizedBox(height: 20),
                // Answer Selection Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildAnswerButton(correctAnswer - widget.number2),
                    const SizedBox(width: 10),
                    buildAnswerButton(correctAnswer),
                    const SizedBox(width: 10),
                    buildAnswerButton(correctAnswer + widget.number2),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build number box with icons
  Widget buildNumberBox(int number) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            children: List.generate(number, (index) {
              return Icon(
                widget.icon, // Use the icon from the widget
                size: 25,
                color: iconColor, // Use the color set in initState
              );
            }),
          ),
        ),
      ],
    );
  }

  // Helper function to build answer visualization box
  Widget buildAnswerBox(int number1, int number2) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Wrap(
        spacing: 10.0, // Add spacing between the segments
        children: List.generate(number2, (index) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.black,
                width: 2,
              ), // Border around each part
            ),
            child: Wrap(
              children: List.generate(number1, (index) {
                return Icon(
                  widget.icon, // Use the icon from the widget
                  size: 25,
                  color: iconColor, // Use the color set in initState
                );
              }),
            ),
          );
        }),
      ),
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
