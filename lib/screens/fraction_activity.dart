import 'package:calcpal/models/activity_result.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/screens/activity_ideognostic.dart';
import 'package:calcpal/services/ideognostic_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:async'; // For timing
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FractionActivityScreen extends StatefulWidget {
  const FractionActivityScreen({super.key});

  @override
  _FractionActivityScreenState createState() => _FractionActivityScreenState();
}

class _FractionActivityScreenState extends State<FractionActivityScreen> {
  final TextEditingController numeratorController = TextEditingController();
  final TextEditingController denominatorController = TextEditingController();
  final PageController _pageController = PageController(initialPage: 0);
  int retryCount = 0;
  int totalParts = 0;
  int coloredParts = 0;
  Color exerciseColor = Colors.grey;
  bool isCorrect = false;
  late Stopwatch stopwatch; // For timing
  int exerciseNumber = 1;

  String completionDate = ''; // For storing the current date
  int totalTimeTaken = 0; //For Storing time take for the activity
  int totalScore = 0; //For Storing total acore for the activity
  int correctCount = 0; //For Stroing no of correctly ans excercises

  final UserService _userService = UserService();
  final IdeognosticService _activityService = IdeognosticService();
  final ToastService _toastService = ToastService();

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    _initializeExercise(exerciseNumber);
  }

  void _initializeExercise(int exerciseNumber) {
    // Initialize exercise-specific content
    switch (exerciseNumber) {
      case 1:
        totalParts = 2;
        coloredParts = _getRandomNumber(1, totalParts - 1);
        exerciseColor = Colors.pinkAccent; // Set color for exercise 1
        stopwatch.start(); // Start timing the exercise
        break;
      case 2:
        totalParts = 5;
        coloredParts = _getRandomNumber(1, totalParts - 1);
        exerciseColor = Colors.green; // Set color for exercise 2
        break;
      case 3:
        totalParts = 8;
        coloredParts = _getRandomNumber(1, totalParts - 1);
        exerciseColor = Colors.blue; // Set color for exercise 3
        break;
      case 4:
        totalParts = 10;
        coloredParts = _getRandomNumber(1, totalParts - 1);
        exerciseColor = Colors.orange; // Set color for exercise 4
        break;
      default:
        totalParts = 0;
        coloredParts = 0;
    }
    // Clear input boxes when initializing new exercise
    numeratorController.clear();
    denominatorController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: 4, // Adjust based on the number of exercises
        itemBuilder: (context, index) {
          return _buildExercisePage(index + 1);
        },
        onPageChanged: (index) {
          setState(() {
            exerciseNumber++;
            _initializeExercise(exerciseNumber); // Initialize the next exercise
          });
        },
      ),
    );
  }

  Widget _buildExercisePage(int exerciseNumber) {
    return Stack(
      children: [
        // Background Image
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fraction.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
              child: Text(
                '$exerciseNumber: ${AppLocalizations.of(context)!.ideognosticQuestionType3}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.95,
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(136, 164, 164, 164),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Information Boxes
                          _infoBox(AppLocalizations.of(context)!.numeratorDesc,
                              exerciseColor),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Fraction Visual
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color.fromARGB(255, 145, 145, 145),
                                  ),
                                  child: _buildFractionVisual(
                                      totalParts, coloredParts, exerciseColor),
                                ),

                                const SizedBox(height: 16),
                                // Fraction Input Field
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.4,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 80,
                                        child: TextField(
                                          controller: numeratorController,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: 80,
                                        height: 2,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 80,
                                        child: TextField(
                                          controller: denominatorController,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          _infoBox(
                              AppLocalizations.of(context)!.denominatorDesc,
                              exerciseColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Submit Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Adjust alignment as needed
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _validateAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Black button background
                      foregroundColor: Colors.white, // White text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Slightly rounded edges
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.checkAnsBtn),
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFractionVisual(int totalParts, int coloredParts, Color color) {
    return Wrap(
      spacing: 1.0,
      runSpacing: 4.0,
      children: List.generate(totalParts, (index) {
        bool isColored = index < coloredParts;
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isColored ? color : Colors.grey,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  Widget _infoBox(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      constraints: const BoxConstraints(
        maxWidth: 250, // Adjust the maximum width as needed
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12, // Adjust font size for readability
        ),
        textAlign: TextAlign.center, // Center-align text
        softWrap: true, // Ensure text wraps to the next line
      ),
    );
  }

  int _getRandomNumber(int min, int max) {
    final Random random = Random();
    return min + random.nextInt(max - min + 1);
  }

  void _validateAnswer() {
    int numerator = int.tryParse(numeratorController.text) ?? 0;
    int denominator = int.tryParse(denominatorController.text) ?? 0;

    if (numerator == coloredParts && denominator == totalParts) {
      isCorrect = true;
      correctCount++;
      if (retryCount == 0) {
        totalScore += 10;
      } else {
        totalScore += 5;
      }
      _showSuccessToast();
    } else {
      retryCount++;
      isCorrect = false;
      if (retryCount < 3) {
        _showRetryToast();
      } else {
        _showCorrectAnswerToast();
      }
    }
  }

  void _showSuccessToast() {
    // Display success toast message
    _toastService.successToast(AppLocalizations.of(context)!
        .correctToast); // Replace with localized success message

    // Proceed to the next page after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (exerciseNumber == 4) {
        // Finalize date and time in last exercise
        completionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

        stopwatch.stop();
        totalTimeTaken = stopwatch.elapsed.inSeconds;
        _submitResultsToDB();
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void _showRetryToast() {
    // Display retry toast message
    _toastService.errorToast(AppLocalizations.of(context)!
        .tryAgainToast); // Replace with localized retry message

    // Clear input fields for retry
    numeratorController.clear();
    denominatorController.clear();
  }

  void _showCorrectAnswerToast() {
    // Display correct answer toast message
    _toastService.successToast(
        '${AppLocalizations.of(context)!.correctAns} : $coloredParts/$totalParts');

    // Proceed to the next page after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (exerciseNumber == 4) {
        // Finalize date and time in last exercise
        completionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

        stopwatch.stop();
        totalTimeTaken = stopwatch.elapsed.inSeconds;
        _submitResultsToDB();
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
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
      activityName: 'Fractions',
      timeTaken: totalTimeTaken,
      totalScore: totalScore,
      retries: correctCount,
    ));

    // Navigate based on the status of updates
    if (activityStatus) {
      _handleSuccess(AppLocalizations.of(context)!.progressStoredTxt);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ActivityIdeognosticScreen(),
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

  @override
  void dispose() {
    numeratorController.dispose();
    denominatorController.dispose();
    super.dispose();
  }
}
