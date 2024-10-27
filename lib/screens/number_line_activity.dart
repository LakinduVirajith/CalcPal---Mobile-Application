import 'dart:math';
import 'package:calcpal/models/activity_result.dart';
import 'package:calcpal/screens/activity_ideognostic.dart';
import 'package:calcpal/services/ideognostic_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:calcpal/models/user.dart';

class NumberLineActivity extends StatefulWidget {
  final int initialExerciseNumber = 1;
  const NumberLineActivity({super.key});

  @override
  _NumberLineActivityState createState() => _NumberLineActivityState();
}

class _NumberLineActivityState extends State<NumberLineActivity> {
  late PageController _pageController;
  int currentExerciseNumber = 0;

  String completionDate = ''; // For storing the current date
  int elapsedTime = 0; //For Storing time take for the activity
  int totalScore = 0; //For Storing total acore for the activity
  int correctCount = 0; //For Stroing no of correctly ans excercises

  final UserService _userService = UserService();
  final IdeognosticService _activityService = IdeognosticService();
  final ToastService _toastService = ToastService();

  // Variables to track scores and retries
  List<bool> exerciseResults = [false, false, false, false, false];
  List<int> retries = [0, 0, 0, 0, 0];

  Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: widget.initialExerciseNumber - 1);
    currentExerciseNumber = widget.initialExerciseNumber;

    // Start the stopwatch when the first exercise loads
    stopwatch.start();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void updateScoreAndStopwatch(bool isCorrect, int exerciseIndex) {
    setState(() {
      exerciseResults[exerciseIndex] = isCorrect;
      if (isCorrect) {
        correctCount++;
        if (retries[exerciseIndex] == 0) {
          totalScore += 10; // First attempt, +10 points
        } else if (retries[exerciseIndex] == 1) {
          totalScore += 5; // Second attempt, +5 points
        }
      }

      // Stop the stopwatch if it's the last exercise
      if (exerciseIndex == 4) {
        stopwatch.stop();

        completionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

        // Convert Duration to seconds
        elapsedTime = stopwatch.elapsed.inSeconds;

        print('Time taken: $elapsedTime');
        print('date: $completionDate');
        print('correct no: $correctCount');
        print('Total Score: $totalScore');

        _submitResultsToDB();
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
      activityName: 'Number Line',
      timeTaken: elapsedTime,
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
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: 5,
        onPageChanged: (pageIndex) {
          setState(() {
            currentExerciseNumber = pageIndex + 1;
          });
        },
        itemBuilder: (context, index) {
          return NumberLineExercise(
            exerciseNumber: index + 1,
            pageController: _pageController, // Pass the page controller
            updateScoreAndStopwatch: updateScoreAndStopwatch,
            exerciseIndex: index,
            retries: retries,
            toastService: _toastService,
          );
        },
      ),
    );
  }
}

class NumberLineExercise extends StatefulWidget {
  final int exerciseNumber;
  final PageController
      pageController; // Accept the page controller as a parameter
  final Function(bool, int)
      updateScoreAndStopwatch; // Callback for updating score and stopping the stopwatch
  final int exerciseIndex; // Index of the current exercise
  final List<int> retries; // List to track retries for each exercise
  final ToastService toastService;

  const NumberLineExercise(
      {super.key,
      required this.exerciseNumber,
      required this.pageController,
      required this.updateScoreAndStopwatch,
      required this.exerciseIndex,
      required this.retries,
      required this.toastService});

  @override
  _NumberLineExerciseState createState() => _NumberLineExerciseState();
}

class _NumberLineExerciseState extends State<NumberLineExercise> {
  Map<int, bool> isPlacedCorrectly = {};
  Map<int, int?> numberPositions = {};
  late List<int> missingNumbers;
  late List<int> numberLine;
  int retryCount = 0; // Track retries

  @override
  void initState() {
    super.initState();
    setupExercise();
  }

  void setupExercise() {
    final random = Random();

    if (widget.exerciseNumber == 1) {
      numberLine = List.generate(9, (index) => index + 1); // 1 to 10
      missingNumbers = _getRandomNumbers(
          2, numberLine, random); // Get 2 random missing numbers
    } else if (widget.exerciseNumber == 2) {
      numberLine = List.generate(9, (index) => index + 1); // 1 to 10
      missingNumbers = _getRandomNumbers(
          4, numberLine, random); // Get 4 random missing numbers
    } else if (widget.exerciseNumber == 3) {
      numberLine = List.generate(6, (index) => 25 + index); // 25 to 30
      missingNumbers = _getRandomNumbers(
          3, numberLine, random); // Get 3 random missing numbers
    } else if (widget.exerciseNumber == 4) {
      numberLine = List.generate(6, (index) => 45 + index); // 45 to 50
      missingNumbers = _getRandomNumbers(
          3, numberLine, random); // Get 3 random missing numbers
    } else if (widget.exerciseNumber == 5) {
      numberLine = List.generate(6, (index) => 90 + index); // 90 to 95
      missingNumbers = _getRandomNumbers(
          3, numberLine, random); // Get 3 random missing numbers
    }

    for (int num in missingNumbers) {
      isPlacedCorrectly[num] = false; // Initialize correctness tracking
      numberPositions[num] = null; // Initialize positions
    }
  }

  List<int> _getRandomNumbers(int count, List<int> numberLine, Random random) {
    List<int> tempNumberLine = List.from(numberLine); // Copy the number line
    List<int> randomNumbers = [];
    for (int i = 0; i < count; i++) {
      int randomIndex = random.nextInt(tempNumberLine.length);
      randomNumbers.add(tempNumberLine.removeAt(randomIndex));
    }
    return randomNumbers;
  }

  void _showSuccessToast() {
    // Show success toast
    widget.toastService
        .successToast(AppLocalizations.of(context)!.correctToast);

    widget.updateScoreAndStopwatch(
        true, widget.exerciseIndex); // Update score and stopwatch

    // Wait for 2 seconds, then proceed to next exercise
    Future.delayed(const Duration(seconds: 2), () {
      if (widget.exerciseNumber < 6) {
        widget.pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _showFailureToast() {
    // Show failure toast using the toast service
    widget.toastService.errorToast(retryCount < 2
            ? AppLocalizations.of(context)!.tryAgainToast // "Let's try again!"
            : AppLocalizations.of(context)!
                .nextExcerciseToast // "Not quite right, let's try the next exercise"
        );

    // Delay before proceeding to next steps
    Future.delayed(const Duration(seconds: 2), () {
      if (retryCount < 2) {
        setState(() {
          retryCount++;
          widget.retries[widget.exerciseIndex] = retryCount; // Update retries
          resetState(); // Reset the exercise state
        });
      } else {
        widget.updateScoreAndStopwatch(
            false, widget.exerciseIndex); // Update stopwatch without score
        widget.pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void resetState() {
    setState(() {
      // Reset correctness and positions for retries
      isPlacedCorrectly.clear();
      numberPositions.clear();
      setupExercise(); // Reinitialize the exercise with fresh state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/numberline_img.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 40.0, horizontal: 10.0),
              child: Text(
                '${widget.exerciseNumber}: ${AppLocalizations.of(context)!.numberLineTopic}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.withOpacity(0.9),
                  ),
                  width: MediaQuery.of(context).size.width * 0.90,
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 4,
                        color: Colors.black,
                        margin: const EdgeInsets.only(bottom: 10),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: numberLine
                            .map((number) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: missingNumbers.contains(number)
                                      ? DragTarget<int>(
                                          builder: (context, candidateData,
                                              rejectedData) {
                                            return Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  numberPositions[number]
                                                          ?.toString() ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          onAccept: (receivedNumber) {
                                            setState(() {
                                              // Allow the number to be placed in the spot (correct or incorrect)
                                              numberPositions[number] =
                                                  receivedNumber;

                                              // Only mark the spot as correct if the number is correct
                                              if (receivedNumber == number) {
                                                isPlacedCorrectly[number] =
                                                    true;
                                              } else {
                                                isPlacedCorrectly[number] =
                                                    false; // Ensure it's not marked correct
                                              }
                                            });
                                          },
                                        )
                                      : Container(
                                          width: 60,
                                          height: 60,
                                          child: Text(
                                            '$number',
                                            style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: DragTarget<int>(
                builder: (context, candidateData, rejectedData) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: missingNumbers.map((number) {
                      return Draggable<int>(
                        data: number,
                        feedback: Container(
                          width: 60,
                          height: 60,
                          color: Colors.black,
                          child: Center(
                            child: Text(
                              '$number',
                              style: const TextStyle(
                                  fontSize: 25, color: Colors.white),
                            ),
                          ),
                        ),
                        childWhenDragging: Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey,
                        ),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$number',
                              style: const TextStyle(
                                  fontSize: 25, color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (isPlacedCorrectly.values.every((correct) => correct)) {
                  _showSuccessToast();
                } else {
                  _showFailureToast();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Black button background
                foregroundColor: Colors.white, // White text color
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
            ),
            const SizedBox(height: 20.0)
          ],
        ),
      ],
    );
  }
}
