import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class FractionActivityScreen extends StatelessWidget {
  final int exerciseNumber;

  const FractionActivityScreen({super.key, required this.exerciseNumber});

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Define exercise-specific content
    int totalParts;
    int coloredParts;
    Widget fractionVisual;

    switch (exerciseNumber) {
      case 1:
        totalParts = 2;
        coloredParts = _getRandomNumber(1, totalParts - 1);
        fractionVisual =
            _buildFractionVisual(totalParts, coloredParts, Colors.red);
        break;
      case 2:
        totalParts = 5;
        coloredParts = _getRandomNumber(1, totalParts - 1);
        fractionVisual =
            _buildFractionVisual(totalParts, coloredParts, Colors.green);
        break;
      case 3:
        totalParts = 8;
        coloredParts = _getRandomNumber(1, totalParts - 1);
        fractionVisual =
            _buildFractionVisual(totalParts, coloredParts, Colors.blue);
        break;
      case 4:
        totalParts = 10;
        coloredParts = _getRandomNumber(1, totalParts - 1);
        fractionVisual =
            _buildFractionVisual(totalParts, coloredParts, Colors.orange);
        break;
      default:
        totalParts = 0;
        coloredParts = 0;
        fractionVisual = const Placeholder();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fraction Activity'),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/multiplication_level2_1.png'),
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
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.6,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.withOpacity(0.8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Information Boxes
                            _infoBox('Numerator', Colors.red),
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
                                    child: fractionVisual,
                                  ),
                                  const SizedBox(height: 32), // Increased space
                                  // Fraction Input Field
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.4,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 60,
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: 60,
                                          height: 2,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: 60,
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            _infoBox('Denominator', Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Next Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FractionActivityScreen(
                          exerciseNumber: exerciseNumber + 1,
                        ),
                      ),
                    );
                  },
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFractionVisual(int totalParts, int coloredParts, Color color) {
    return Container(
      child: Wrap(
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
      ),
    );
  }

  Widget _infoBox(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  int _getRandomNumber(int min, int max) {
    final Random random = Random();
    return min + random.nextInt(max - min + 1);
  }
}
