import 'package:calcpal/models/activity_result.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/operational_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:calcpal/screens/activity_operational.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:calcpal/widgets/place_value_table.dart';

class SubtractionLevel2 extends StatefulWidget {
  SubtractionLevel2();

  @override
  _SubtractionLevel2State createState() => _SubtractionLevel2State();
}

class _SubtractionLevel2State extends State<SubtractionLevel2> {
  bool layoutCompleted = false;
  final TextEditingController answerController = TextEditingController();
  int retryCount = 0;
  int exerciseNumber = 1;
  int number1 = 0;
  int number2 = 0;
  String backgroundImage = '';
  Stopwatch stopwatch = Stopwatch();

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
    _initializeExercise();
    stopwatch.start();
  }

  void _initializeExercise() {
    backgroundImage = 'assets/images/level2division.jpeg';
    switch (exerciseNumber) {
      case 1:
        number1 = Random().nextInt(6) + 15; // number1 between 15 and 20
        number2 = Random().nextInt(5) + 1; // number2 between 1 and 5
        break;
      case 2:
        number1 = Random().nextInt(11) + 20; // number1 between 20 and 30
        number2 = Random().nextInt(6) + 10; // number2 between 10 and 15
        break;
      case 3:
        number1 = Random().nextInt(21) + 30; // number1 between 30 and 50
        number2 = Random().nextInt(6) + 5; // number2 between 5 and 10
        break;
      case 4:
        number1 = 999;
        number2 = (Random().nextInt(9) + 1) * 10; // number2 any multiple of 10
        break;
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  backgroundImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        'Image not found',
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    );
                  },
                ),
              ),
              // Center the layout within the available space
              Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20), // Move the heading slightly up
                          Column(
                            children: [
                              Text(
                                '${exerciseNumber}) - ${number1} - ${number2} ',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                  child: PlaceValueTable(
                                      number: number1,
                                      iconType: Icons.diamond)),
                              Text('-', style: TextStyle(fontSize: 40)),
                              Flexible(
                                  child: PlaceValueTable(
                                      number: number2,
                                      iconType: Icons.diamond)),
                            ],
                          ),
                          SizedBox(height: 20),
                          // Answer input field
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 80),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0), // Adjusts the height
                              constraints: BoxConstraints(
                                maxWidth: 300, // Adjusts the width
                              ),
                              child: TextField(
                                controller: answerController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .enterAnswerPlaceholder,
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal:
                                          10.0), // Adjusts internal padding
                                ),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: layoutCompleted ? evaluateAnswer : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.black, // Black button background
                              foregroundColor: Colors.white, // White text color
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // Slightly rounded edges
                              ),
                            ),
                            child:
                                Text(AppLocalizations.of(context)!.nextBtnText),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        layoutCompleted = true;
      });
    });
  }

  void evaluateAnswer() {
    int correctAnswer = number1 - number2;
    int userAnswer = int.tryParse(answerController.text) ?? 0;

    if (userAnswer == correctAnswer) {
      correctCount++;
      if (retryCount == 0) {
        totalScore += 10; //  10 points if correct on first try
      } else if (retryCount == 1) {
        totalScore += 5; //  5 points if correct on second try
      }
      retryCount = 0; // Reset retry count for the next question
      _showCelebrationPopup();
    } else {
      retryCount++;
      if (retryCount < 3) {
        _showTryAgainPopup();
      } else {
        _showCorrectAnswerDialog(correctAnswer);
      }
    }

    // Clear the input field after submission
    answerController.clear();
  }

  void _showCelebrationPopup() {
    // Show success toast
    _toastService.successToast(AppLocalizations.of(context)!.correctToast);

    // Wait and proceed to the next exercise
    Future.delayed(const Duration(seconds: 2), () {
      _nextExercise();
    });
  }

  void _showTryAgainPopup() {
    _toastService.errorToast(AppLocalizations.of(context)!.tryAgainToast);
  }

  void _showCorrectAnswerDialog(int correctAnswer) {
    // Show info toast with the correct answer
    _toastService.infoToast(
        '${AppLocalizations.of(context)!.correctAns}: $correctAnswer');

    // Wait briefly, then move to the next exercise
    Future.delayed(const Duration(seconds: 2), () {
      _nextExercise();
    });
  }

  void _nextExercise() {
    if (exerciseNumber < 4) {
      setState(() {
        exerciseNumber++;
        retryCount = 0;
        _initializeExercise();
      });
    } else {
      //Submit Subtraction level 2 results
      completionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      stopwatch.stop();
      totalTimeTaken = stopwatch.elapsed.inSeconds;

      _submitResultsToDB();
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
      activityName: 'Level2 - Subtraction',
      timeTaken: totalTimeTaken,
      totalScore: totalScore,
      retries: correctCount,
    ));

    // Navigate based on the status of updates
    if (activityStatus) {
      _handleSuccess(AppLocalizations.of(context)!.progressStoredTxt);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ActivityOperationalScreen(),
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
}
