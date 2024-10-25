import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../screens/activity_operational.dart';

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
  int totalScore = 0;
  String backgroundImage = '';
  String infoMessage = '';
  Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _initializeExercise();
    stopwatch.start();
  }

  void _initializeExercise() {
    switch (exerciseNumber) {
      case 1:
        number1 = Random().nextInt(20) + 1; // Number1 between 1 and 20
        number2 = 1;
        backgroundImage =
            'assets/images/operational_activities/division_level2_1.png';
        infoMessage =
            'Learning Point! Any number divided by 1 is the number itself.';
        break;
      case 2:
        number1 = generateEvenNumberBetween1And20();
        number2 = 2; // Number2 is always 2
        backgroundImage =
            'assets/images/operational_activities/division_level2_2.png';
        infoMessage = 'Learning Point! Even numbers are divisible by 2.';
        break;
      case 3:
        // Ensure number1 is divisible by 3
        number1 = generateRandomMultipleOfThree();
        number2 = 3; // number2 is 3
        backgroundImage =
            'assets/images/operational_activities/division_level2_3.png';
        infoMessage =
            'Learning Point! Numbers divisible by 3 have no remainder.';
        break;
      case 4:
        number1 = generateRandomMultipleOfTen(); // Generate multiples of 10
        number2 = 10; // number2 is 10
        backgroundImage =
            'assets/images/operational_activities/division_level2_4.png';
        infoMessage =
            'Learning Point! Multiples of 10 are easy to divide by 10.';
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
                                'Exercise ${exerciseNumber} - ${number1} ÷ ${number2}',
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
                                child: PlaceValueTable(number: number1),
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
                                      labelText: 'Enter your answer',
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
                            onPressed: layoutCompleted
                                ? () {
                                    int correctAnswer = number1 ~/ number2;
                                    int userAnswer =
                                        int.tryParse(answerController.text) ??
                                            0;

                                    if (userAnswer == correctAnswer) {
                                      totalScore++;
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
                                : null, // Disable the button if the layout isn't complete
                            child: Text('Next'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              textStyle: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
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

  void _showCelebrationPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Congratulations! Good job 🎉🎉'),
        content: Text('You got the correct answer!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nextExercise();
            },
            child: Text('Next'),
          ),
        ],
      ),
    );
  }

  void _showTryAgainPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Let's Try Again 😊"),
        content: Text('That answer is incorrect.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showCorrectAnswerDialog(int correctAnswer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Correct Answer'),
        content: Text('The correct answer was $correctAnswer.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nextExercise();
            },
            child: Text('Next'),
          ),
        ],
      ),
    );
  }

  void _nextExercise() {
    if (exerciseNumber < 4) {
      setState(() {
        exerciseNumber++;
        retryCount = 0;
        _initializeExercise();
      });
    } else {
      stopwatch.stop();
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final totalTime = stopwatch.elapsed.inSeconds;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Well done!'),
        content: Text(
            'You have completed all exercises.\nTotal Score: $totalScore/4\nTotal Time: $totalTime seconds'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ActivityOperationalScreen(),
                ),
              );
            },
            child: Text('Back'),
          ),
        ],
      ),
    );
  }
}

class PlaceValueTable extends StatelessWidget {
  final int number;

  PlaceValueTable({required this.number});

  @override
  Widget build(BuildContext context) {
    int hundreds = (number ~/ 100) % 10;
    int tens = (number ~/ 10) % 10;
    int ones = number % 10;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          margin: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade300, // Set grey background color
            border: Border.all(),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hundreds',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  VerticalDivider(
                      color: Colors.black,
                      thickness: 2), // Add a black line between columns
                  Expanded(
                    child: Text(
                      'Tens',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  VerticalDivider(
                      color: Colors.black,
                      thickness: 2), // Add a black line between columns
                  Expanded(
                    child: Text(
                      'Ones',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.black), // Black line below the headers
              Row(
                children: [
                  Expanded(child: createStars(hundreds)),
                  VerticalDivider(
                      color: Colors.black,
                      thickness: 2), // Add a black line between columns
                  Expanded(child: createStars(tens)),
                  VerticalDivider(
                      color: Colors.black,
                      thickness: 2), // Add a black line between columns
                  Expanded(child: createStars(ones)),
                ],
              ),
            ],
          ),
        ),
        // Display number below the place value table
        Text(
          '$number',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget createStars(int count) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      runSpacing: 8.0,
      children: List.generate(
        count,
        (index) => Icon(Icons.star, size: 22, color: Colors.black),
      ),
    );
  }
}
