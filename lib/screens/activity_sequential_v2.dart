import 'dart:math';
import 'package:calcpal/constants/routes.dart';
import 'package:flutter/material.dart';

import '../services/toast_service.dart';

class NumberLineJumpScreen extends StatefulWidget {
  @override
  _NumberLineJumpScreenState createState() => _NumberLineJumpScreenState();
}

class _NumberLineJumpScreenState extends State<NumberLineJumpScreen> {
  final int gridSize = 5; // Number of elements in the number line
  int completionCount = 0;
  int currentLevel = 1; // Track the current level
// For testing, can increase later

  late List<int> numberLine;
  late List<int?> placedNumbers;
  late List<int> shuffledNumbers; // Shuffled version of the number line
  final Random random = Random();
  final ToastService _toastService = ToastService();
  @override
  void initState() {
    super.initState();
    _generateNumberLinePattern(); // Initialize number line with pattern
  }

  // Function to generate a number line following a specific pattern based on level
  void _generateNumberLinePattern() {
    int startNumber = random.nextInt(10) + 1; // Starting number for the pattern
    int step;

    switch (currentLevel) {
      case 1:
        step = 2; // Add by 2
        numberLine =
            List.generate(gridSize, (index) => startNumber + index * step);
        break;
      case 2:
        step = 5; // Add by 5
        numberLine =
            List.generate(gridSize, (index) => startNumber + index * step);
        break;
      case 3:
        step = 2; // Multiply by 2
        numberLine = List.generate(
            gridSize, (index) => startNumber * pow(step, index).toInt());
        break;
      case 4:
        step = 5; // Multiply by 5
        numberLine = List.generate(
            gridSize, (index) => startNumber * pow(step, index).toInt());
        break;
      case 5:
        step = 8; // Multiply by 8
        numberLine = List.generate(
            gridSize, (index) => startNumber * pow(step, index).toInt());
        break;
      default:
        Navigator.of(context).pushNamed(activityDashboardRoute);
        break;
    }

    placedNumbers =
        List.generate(numberLine.length, (index) => null); // Empty slots

    // Shuffle the numbers for dragging
    shuffledNumbers = List.from(numberLine)..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Line Jump - Level $currentLevel'),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/activity_background_v5.jpg'),
            fit: BoxFit.cover, // Fit the image to the screen
          ),
        ),
        child: Center(
          // Center all elements
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Number Line (Drag Target)
              Expanded(
                child: Center(
                  // Center the number line horizontally
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: numberLine.asMap().entries.map((entry) {
                      int index = entry.key;
                      int number = entry.value;
                      return DragTarget<int>(
                        builder: (context, candidateData, rejectedData) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.all(8),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(8),
                              color: placedNumbers[index] != null
                                  ? Colors.green
                                  : Colors.grey[300],
                            ),
                            child: Center(
                              child: Text(
                                placedNumbers[index]?.toString() ?? '',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                        onAccept: (data) {
                          if (data == number) {
                            setState(() {
                              placedNumbers[index] = data;
                              // Remove the number from shuffled list after successful drag
                              shuffledNumbers.remove(data);

                              // Check if all numbers are placed correctly
                              if (placedNumbers.every((val) => val != null)) {
                                completionCount++;
                                _showCompletionMessage();

                                // No need for a pop-up. Button will be shown to proceed.
                              }
                            });
                          } else {
                            _showErrorMessage(); // Incorrect placement feedback
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Shuffled Numbers to Drag
              Center(
                child: SizedBox(
                    height: 80,
                    width: 600,
                    child: shuffledNumbers.isNotEmpty
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: shuffledNumbers.length,
                            itemBuilder: (context, index) {
                              return Draggable<int>(
                                data: shuffledNumbers[index],
                                child: Container(
                                  width: 100,
                                  height: 60,
                                  margin: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                        offset: Offset(
                                            2, 2), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      shuffledNumbers[index].toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ),
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    width: 100,
                                    height: 60,
                                    color: Colors.blue.withOpacity(0.5),
                                    child: Center(
                                      child: Text(
                                        shuffledNumbers[index].toString(),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Container(
                                  width: 100,
                                  height: 60,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          )
                        : Container(
                            padding: EdgeInsets.all(
                                4.0), // Add padding around the text
                            color: const Color.fromARGB(226, 234, 252, 68),
                            child: Center(
                              child: Text(
                                'All numbers placed!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(
                                      255, 0, 0, 0), // Text color
                                  letterSpacing: 1.5, // Spacing between letters
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4.0,
                                      color:
                                          const Color.fromARGB(255, 111, 97, 97)
                                              .withOpacity(0.3),
                                      offset: Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )),
              ),
              SizedBox(height: 20),

              // Button to move to next level
              if (placedNumbers.every((val) =>
                  val != null)) // Show button only when level is complete
                ElevatedButton(
                  onPressed: () {
                    _nextLevel(); // Move to the next level when button is pressed
                  },
                  child: Text('Next Level'),
                ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Display a message when the number line is completed correctly
  void _showCompletionMessage() {
    _toastService.successToast('Well done! You completed the number line.');
  }

  // Display a message for incorrect placement
  void _showErrorMessage() {
    _toastService.warningToast('Incorrect placement! Try again.');
  }

  // Move to the next level
  void _nextLevel() {
    setState(() {
      if (currentLevel < 6) {
        currentLevel++;
      } else {
        currentLevel = 1; // Restart at level 1 after level 5
      }
      completionCount = 0; // Reset completion count for new level
      _generateNumberLinePattern(); // Generate a new pattern for the next level
    });
  }
}
