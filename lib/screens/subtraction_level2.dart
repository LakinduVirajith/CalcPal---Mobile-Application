import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class SubtractionLevel2 extends StatefulWidget {
  final int exerciseNumber;
  final int number1;
  final int number2;
  final String backgroundImage;

  SubtractionLevel2({
    required this.exerciseNumber,
    required this.number1,
    required this.number2,
    required this.backgroundImage,
  });

  @override
  _SubtractionLevel2State createState() => _SubtractionLevel2State();
}

class _SubtractionLevel2State extends State<SubtractionLevel2> {
  bool layoutCompleted = false;
  final TextEditingController answerController = TextEditingController();
  int retryCount = 0;

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
                  widget.backgroundImage,
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
                                'Exercise ${widget.exerciseNumber}',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${widget.number1} - ${widget.number2}',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                  child:
                                      PlaceValueTable(number: widget.number1)),
                              Text('-', style: TextStyle(fontSize: 40)),
                              Flexible(
                                  child:
                                      PlaceValueTable(number: widget.number2)),
                            ],
                          ),
                          SizedBox(height: 20),
                          // Answer input field
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 100),
                            child: TextField(
                              controller: answerController,
                              decoration: InputDecoration(
                                labelText: 'Enter your answer',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: layoutCompleted
                                ? () {
                                    int correctAnswer =
                                        widget.number1 - widget.number2;
                                    int userAnswer =
                                        int.tryParse(answerController.text) ??
                                            0;

                                    if (userAnswer == correctAnswer) {
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
                              // primary: Colors.black,
                              // onPrimary: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              textStyle: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      getNextExerciseScreen(widget.exerciseNumber),
                ),
              );
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      getNextExerciseScreen(widget.exerciseNumber),
                ),
              );
            },
            child: Text('Next'),
          ),
        ],
      ),
    );
  }

  // Function to create next exercise screen
  Widget getNextExerciseScreen(int currentExerciseNumber) {
    switch (currentExerciseNumber) {
      case 1:
        return SubtractionLevel2(
          exerciseNumber: 2,
          number1: Random().nextInt(11) + 20, // number1 between 20 and 30
          number2: Random().nextInt(6) + 10, // number2 between 10 and 15
          backgroundImage: 'assets/images/subtraction_level2_2.png',
        );
      case 2:
        return SubtractionLevel2(
          exerciseNumber: 3,
          number1: Random().nextInt(21) + 30, // number1 between 30 and 50
          number2: Random().nextInt(6) + 5, // number2 between 5 and 10
          backgroundImage: 'assets/images/subtraction_level2_3.png',
        );
      case 3:
        return SubtractionLevel2(
          exerciseNumber: 4,
          number1: 999,
          number2: (Random().nextInt(9) + 1) * 10, // number2 any multiple of 10
          backgroundImage: 'assets/images/subtraction_level2_4.png',
        );
      default:
        return SubtractionLevel2(
          exerciseNumber: 1,
          number1: Random().nextInt(6) + 15, // number1 between 15 and 20
          number2: Random().nextInt(5) + 1, // number2 between 1 and 5
          backgroundImage: 'assets/images/subtraction_level2_1.png',
        );
    }
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
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  VerticalDivider(
                      color: Colors.black,
                      thickness: 2), // Add a black line between columns
                  Expanded(
                    child: Text(
                      'Tens',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  VerticalDivider(
                      color: Colors.black,
                      thickness: 2), // Add a black line between columns
                  Expanded(
                    child: Text(
                      'Ones',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
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
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
        (index) => Icon(Icons.flag, size: 50, color: Colors.black),
      ),
    );
  }
}
