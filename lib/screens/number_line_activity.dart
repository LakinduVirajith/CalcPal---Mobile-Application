import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberLineActivity extends StatefulWidget {
  final int exerciseNumber;
  const NumberLineActivity({super.key, required this.exerciseNumber});

  @override
  _NumberLineActivityState createState() => _NumberLineActivityState();
}

class _NumberLineActivityState extends State<NumberLineActivity> {
  final Map<int, bool> isPlacedCorrectly = {};
  final Map<int, int?> numberPositions = {};
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
      numberLine = List.generate(10, (index) => index + 1); // 1 to 10
      missingNumbers = _getRandomNumbers(
          2, numberLine, random); // Get 2 random missing numbers
    } else if (widget.exerciseNumber == 2) {
      numberLine = List.generate(10, (index) => index + 1); // 1 to 10
      missingNumbers = _getRandomNumbers(
          4, numberLine, random); // Get 4 random missing numbers
    } else if (widget.exerciseNumber == 3) {
      numberLine = List.generate(11, (index) => index + 20); // 20 to 30
      missingNumbers = _getRandomNumbers(
          4, numberLine, random); // Get 4 random missing numbers
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NumberLineActivity(
                    exerciseNumber: widget.exerciseNumber + 1,
                  ),
                ),
              );
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
            : const Text("Not quite right, Let's try the next excercise"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (retryCount < 2) {
                setState(() {
                  retryCount++;
                  setupExercise(); // Reset the exercise
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NumberLineActivity(
                      exerciseNumber: widget.exerciseNumber + 1,
                    ),
                  ),
                );
              }
            },
            child: Text(retryCount < 2 ? 'Retry' : 'Next'),
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
      appBar: AppBar(
        title: const Text("Let's work with Number Lines"),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/operational_level1.png'),
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
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.withOpacity(1),
                    ),
                    height: MediaQuery.of(context).size.height *
                        0.3, // Set height to 30% of the screen
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
                                        horizontal: 16.0),
                                    child: missingNumbers.contains(number)
                                        ? DragTarget<int>(
                                            builder: (context, candidateData,
                                                rejectedData) {
                                              return Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.blueAccent),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    numberPositions[number]
                                                            ?.toString() ??
                                                        '?',
                                                    style: const TextStyle(
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            onAccept: (data) {
                                              setState(() {
                                                if (data == number) {
                                                  isPlacedCorrectly[number] =
                                                      true;
                                                }
                                                numberPositions[number] = data;
                                              });
                                            },
                                          )
                                        : Text(
                                            '$number',
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
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
              // Draggable Numbers
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: missingNumbers
                    .map(
                      (number) => Draggable<int>(
                        data: number,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '$number',
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        childWhenDragging:
                            const SizedBox(width: 60, height: 60),
                        child: numberPositions[number] == null
                            ? Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '$number',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(width: 60, height: 60),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  bool allCorrect =
                      isPlacedCorrectly.values.every((correct) => correct);
                  if (allCorrect) {
                    _showSuccessDialog();
                  } else {
                    _showFailureDialog();
                  }
                },
                child: const Text('Next'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
