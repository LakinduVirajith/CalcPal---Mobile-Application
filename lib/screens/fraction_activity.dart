import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async'; // For timing

class FractionActivityScreen extends StatefulWidget {
  final int exerciseNumber;

  const FractionActivityScreen({super.key, required this.exerciseNumber});

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
  int totalScore = 0;
  int totalTimeTaken = 0;
  bool isCorrect = false;
  late Stopwatch stopwatch; // For timing

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    _initializeExercise(widget.exerciseNumber);
  }

  void _initializeExercise(int exerciseNumber) {
    // Initialize exercise-specific content
    switch (exerciseNumber) {
      case 1:
        totalParts = 2;
        coloredParts = _getRandomNumber(1, totalParts - 1);
        exerciseColor = Colors.red; // Set color for exercise 1
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
    stopwatch.start(); // Start timing the exercise
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fraction Activity'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: 4, // Adjust based on the number of exercises
        itemBuilder: (context, index) {
          return _buildExercisePage(index + 1);
        },
        onPageChanged: (index) {
          setState(() {
            _initializeExercise(index + 1); // Initialize the next exercise
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
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage('assets/images/fractionact_$exerciseNumber.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Exercise $exerciseNumber: Identify the Fraction',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.6,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.withOpacity(0.9),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Information Boxes
                          _infoBox(
                              'Did you know 😲? The top number of a fraction is called the numerator. You can find it by counting the no of shaded parts.',
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
                                  ),
                                  child: _buildFractionVisual(
                                      totalParts, coloredParts, exerciseColor),
                                ),
                                const SizedBox(height: 16), // Reduced space
                                const Text(
                                  'Type the numbers in these boxes:',
                                  style: TextStyle(fontSize: 18),
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
                              'Did you know 😲? The bottom number of a fraction is called the denominator. You can find it by counting the total no of parts.',
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
              child: ElevatedButton(
                onPressed: _validateAnswer,
                child: const Text('Submit'),
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
          width: 60,
          height: 60,
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
          fontSize: 16, // Adjust font size for readability
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

    stopwatch.stop();
    totalTimeTaken = stopwatch.elapsedMilliseconds ~/
        1000; // Convert milliseconds to seconds

    if (numerator == coloredParts && denominator == totalParts) {
      isCorrect = true;
      totalScore += 10; // Example score increment
      _showDialog('Correct!', '🎉 Congratulations! 🎉', true);
    } else {
      retryCount++;
      isCorrect = false;
      if (retryCount < 3) {
        _showDialog('Incorrect', 'Let\'s try again.', false);
      } else {
        _showDialog('Correct Answer',
            'The correct fraction is $coloredParts/$totalParts.', true);
      }
    }

    print('Exercise ${widget.exerciseNumber} results:');
    print('Retries: $retryCount');
    print('Total Score: $totalScore');
    print('Total Time Taken: $totalTimeTaken seconds');
    print('Is Correct: $isCorrect');
  }

  void _showDialog(String title, String content, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.exerciseNumber == 4) {
                  // End of activity, print results to the console
                  print('Activity End Results:');
                  print('Total Retries: $retryCount');
                  print('Final Score: $totalScore');
                  print('Total Time Taken: $totalTimeTaken seconds');
                  print('Was the last attempt Correct? $isCorrect');
                } else if (isSuccess) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                  stopwatch
                      .reset(); // Reset the stopwatch for the next exercise
                } else {
                  numeratorController.clear();
                  denominatorController.clear();
                  stopwatch.reset(); // Reset the stopwatch for a retry
                  stopwatch.start();
                }
              },
              child: Text(isSuccess ? 'Next' : 'Retry'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    numeratorController.dispose();
    denominatorController.dispose();
    stopwatch.stop();
    super.dispose();
  }
}
