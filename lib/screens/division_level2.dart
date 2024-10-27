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
import '../screens/activity_operational.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:calcpal/widgets/place_value_table.dart';

class DivisionLevel2 extends StatefulWidget {
  DivisionLevel2();

  @override
  _DivisionLevel2State createState() => _DivisionLevel2State();
}

class _DivisionLevel2State extends State<DivisionLevel2> {
  bool layoutCompleted = false;
  final TextEditingController answerController = TextEditingController();
  int retryCount = 0;
  int exerciseNumber = 1;
  int number1 = 0;
  int number2 = 0;
  String backgroundImage = '';
  String infoMessage = '';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Set the infoMessage and other variables here after dependencies are available
    _initializeInfoMessage();

    // Ensure layout completion logic happens after the frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        layoutCompleted = true;
      });
    });
  }

  void _initializeInfoMessage() {
    switch (exerciseNumber) {
      case 1:
        infoMessage = AppLocalizations.of(context)!.divLvl2Num1Text;
        break;
      case 2:
        infoMessage = AppLocalizations.of(context)!.divLvl2Num2Text;
        break;
      case 3:
        infoMessage = AppLocalizations.of(context)!.divLvl2Num3Text;
        break;
      case 4:
        infoMessage = AppLocalizations.of(context)!.divLvl2Num10Text;
        break;
    }
  }

  void _initializeExercise() {
    backgroundImage = 'assets/images/level2subtraction.jpeg';
    switch (exerciseNumber) {
      case 1:
        number1 = Random().nextInt(20) + 1; // Number1 between 1 and 20
        number2 = 1;
        break;
      case 2:
        number1 = generateEvenNumberBetween1And20();
        number2 = 2; // Number2 is always 2
        break;
      case 3:
        // Ensure number1 is divisible by 3
        number1 = generateRandomMultipleOfThree();
        number2 = 3; // number2 is 3
        break;
      case 4:
        number1 = generateRandomMultipleOfTen(); // Generate multiples of 10
        number2 = 10; // number2 is 10
        break;
    }
  }

  int generateRandomMultipleOfThree() {
    int number;
    do {
      number = Random().nextInt(90) +
          10; // Generates a random number between 10 and 99
    } while (number % 3 != 0); // Ensure the number is a multiple of 3
    return number;
  }

  int generateRandomMultipleOfTen() {
    int number;
    do {
      number = Random().nextInt(90) +
          10; // Generates a random number between 10 and 99
    } while (number % 10 != 0); // Ensure the number is a multiple of 10
    return number;
  }

  int generateEvenNumberBetween1And20() {
    int number;
    do {
      number = Random().nextInt(20) +
          1; // Generates a random number between 1 and 20
    } while (number % 2 != 0); // Ensures the number is a multiple of 2 (even)
    return number;
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
                                '${exerciseNumber}) - ${number1} ÷ ${number2}',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: constraints.maxWidth *
                                    0.60, // Set the width to 35% of the screen
                                child: PlaceValueTable(
                                    number: number1, iconType: Icons.phone),
                              ),
                              // Box around division sign
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors
                                      .grey.shade300, // Grey background color
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  '÷',
                                  style: TextStyle(fontSize: 40),
                                ),
                              ),
                              SizedBox(width: 10), // Add space between boxes
                              // Box around the second number
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors
                                      .grey.shade300, // Grey background color
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  '${number2}',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      50), // Add space between the boxes and the place value table
                              // Limit the width of the PlaceValueTable
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Centers the row content
                            children: [
                              // Information bubble
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        20), // Adjust the padding as needed
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Text(
                                    infoMessage,
                                    style: TextStyle(fontSize: 15),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // Add a horizontal space between the information bubble and the text field
                              SizedBox(width: 20),
                              // Answer input field
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        20), // Adjust the padding as needed
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
                            ],
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

  void evaluateAnswer() {
    int correctAnswer = number1 ~/ number2;
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
        _initializeInfoMessage();
      });
    } else {
      //Submit Addition level 2 results
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
      activityName: 'Level2 - Division',
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
