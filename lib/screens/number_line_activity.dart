import 'dart:math';
import 'package:calcpal/screens/activity_ideognostic.dart';
import 'package:calcpal/screens/fraction_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

class NumberLineActivity extends StatefulWidget {
  final int initialExerciseNumber = 1;
  const NumberLineActivity({super.key});

  @override
  _NumberLineActivityState createState() => _NumberLineActivityState();
}

class _NumberLineActivityState extends State<NumberLineActivity> {
  late PageController _pageController;
  int currentExerciseNumber = 0;

  // Variables to track scores and retries
  List<bool> exerciseResults = [false, false, false];
  List<int> retries = [0, 0, 0];
  int totalScore = 0;
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
        totalScore += 10; // score increment
      }

      // Stop the stopwatch if it's the last exercise
      if (exerciseIndex == 2) {
        stopwatch.stop();

        // Convert Duration to seconds
        int elapsedTime = stopwatch.elapsed.inSeconds;

        _showCompletionDialog(elapsedTime, totalScore);
        print('Time taken: ${stopwatch.elapsed}');
        print('Exercise Results: $exerciseResults');
        print('Retries: $retries');
        print('Total Score: $totalScore');
      }
    });
  }

  void _showCompletionDialog(int elapsedTime, int total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Well done!'),
        content: Text(
          'You have completed all exercises.\nTotal Score: $total/40\nTotal Time: $elapsedTime seconds',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => FractionActivityScreen(),
                ),
              );
            },
            child: Text('Next Activity'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ActivityIdeognosticScreen(),
                ),
              );
            },
            child: Text('Back'),
          ),
        ],
      ),
    );
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
        itemCount: 3, // Assuming you have 3 exercises
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

  const NumberLineExercise({
    super.key,
    required this.exerciseNumber,
    required this.pageController,
    required this.updateScoreAndStopwatch,
    required this.exerciseIndex,
    required this.retries,
  });

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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: const Text('Correct! 🎉'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.updateScoreAndStopwatch(
                  true, widget.exerciseIndex); // Update score and stopwatch

              if (widget.exerciseNumber < 3) {
                widget.pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not Quite Right'),
        content: retryCount < 2
            ? const Text('Let\'s try again!')
            : const Text("Not quite right, Let's try the next exercise"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (retryCount < 2) {
                setState(() {
                  retryCount++;
                  widget.retries[widget.exerciseIndex] =
                      retryCount; // Update retries
                  resetState(); // Reset the exercise state
                });
              } else {
                widget.updateScoreAndStopwatch(false,
                    widget.exerciseIndex); // Update stopwatch without score
                widget.pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Text(retryCount < 2 ? 'Retry' : 'Next'),
          ),
        ],
      ),
    );
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
              image: AssetImage(
                  'assets/images/ideognostic_activities/numberline_${widget.exerciseNumber}.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Exercise ${widget.exerciseNumber}: Label the Number Line',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.withOpacity(0.9),
                  ),
                  width: MediaQuery.of(context).size.width * 0.90,
                  height: MediaQuery.of(context).size.height * 0.30,
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
                                      horizontal: 10.0),
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
              padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                  _showSuccessDialog();
                } else {
                  _showFailureDialog();
                }
              },
              child: const Text('Check Answer'),
            ),
          ],
        ),
      ],
    );
  }
}
