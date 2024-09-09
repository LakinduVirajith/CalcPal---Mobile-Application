import 'dart:ui' as ui;
import 'package:calcpal/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

class ActivitiesGraphicalScreenLevelTwo extends StatefulWidget {
  const ActivitiesGraphicalScreenLevelTwo({super.key});

  @override
  State<ActivitiesGraphicalScreenLevelTwo> createState() =>
      _ActivitiesGraphicalScreenLevelTwoState();
}

class _ActivitiesGraphicalScreenLevelTwoState
    extends State<ActivitiesGraphicalScreenLevelTwo> {
  late Size _whiteboardSize;
  Offset _whiteboardOffset = Offset.zero;
  final GlobalKey _whiteboardKey = GlobalKey();
  final GlobalKey _repaintBoundaryKey = GlobalKey(); // for the screenshot
  int _currentQuestionIndex = 0;

  // New variable to track activity level
  int activityLevel = 1;

  Future<void> _handlePress() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      await _captureScreenshot();
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      await _captureScreenshot();

      //Navigate to the next ActivityLevelTwo widget
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ActivityLevelTwo()),
      );
    }
  }

  Future<void> _captureScreenshot() async {
    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Now you have the screenshot in pngBytes. You can save it, display it, etc.
      // For example, you can print its length to see that it has been captured:
      print("Screenshot captured: ${pngBytes.length} bytes");
    } catch (e) {
      print("Error capturing screenshot: $e");
    }
  }

  // List of drawing questions
  final List<String> _questions = [
    'Draw an addition symbol.',
    'Draw a subtraction symbol.',
    'Draw a multiplication symbol.',
    'Draw a division symbol.',
    'Draw an equal symbol.',
  ];

  // List of image paths corresponding to each question
  final List<String> _questionImages = [
    'assets/images/add.png',
    'assets/images/subs.png',
    'assets/images/multi.png',
    'assets/images/division.png',
    'assets/images/equal.jpg'
  ];

  // Store points for each question separately
  final List<List<Offset?>> _questionPoints = List.generate(5, (_) => []);

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/back1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate whiteboard size
              _whiteboardSize = Size(
                constraints.maxWidth * 0.5,
                constraints.maxHeight * 0.5,
              );

              // Schedule whiteboard offset calculation after the layout is built
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final RenderBox renderBox = _whiteboardKey.currentContext
                    ?.findRenderObject() as RenderBox;
                if (renderBox != null) {
                  setState(() {
                    _whiteboardOffset = renderBox.localToGlobal(Offset.zero);
                  });
                }
              });

              return Column(
                children: [
                  // Question text
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Text(
                      _questions[_currentQuestionIndex],
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: Stack(
                        children: [
                          // Whiteboard container with low-opacity symbol
                          RepaintBoundary(
                            key: _repaintBoundaryKey,
                            child: Container(
                              key: _whiteboardKey,
                              width: _whiteboardSize.width,
                              height: _whiteboardSize.height,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: GestureDetector(
                                      onPanUpdate: (details) {
                                        final RenderBox renderBox = context
                                            .findRenderObject() as RenderBox;
                                        final localPosition =
                                            renderBox.globalToLocal(
                                                details.globalPosition);

                                        // Convert global position to local position relative to the whiteboard container
                                        final offset =
                                            localPosition - _whiteboardOffset;

                                        if (_isWithinBounds(
                                            offset, _whiteboardSize)) {
                                          setState(() {
                                            _questionPoints[
                                                    _currentQuestionIndex]
                                                .add(offset);
                                          });
                                        }
                                      },
                                      onPanEnd: (details) {
                                        setState(() {
                                          _questionPoints[_currentQuestionIndex]
                                              .add(null);
                                        });
                                      },
                                      child: CustomPaint(
                                        painter: WhiteboardPainter(
                                          points: _questionPoints[
                                              _currentQuestionIndex],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Clear all button
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _questionPoints[_currentQuestionIndex]
                                              .clear();
                                        });
                                      },
                                      child: const Text('Clear All'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Addition symbol on the right side of the whiteboard
                          Positioned(
                            right: 0,
                            top: 50,
                            child: Image.asset(
                              _questionImages[
                                  _currentQuestionIndex], // Replace with your image path
                              width: 100,
                              height: 100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _currentQuestionIndex > 0
                              ? () {
                                  setState(() {
                                    _currentQuestionIndex--;
                                  });
                                }
                              : null,
                          child: const Text('Back'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _handlePress,
                          child: Text(
                              _currentQuestionIndex < _questions.length - 1
                                  ? 'Next'
                                  : 'Submit'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  bool _isWithinBounds(Offset position, Size whiteboardSize) {
    return position.dx >= 0 &&
        position.dy >= 0 &&
        position.dx <= whiteboardSize.width &&
        position.dy <= whiteboardSize.height;
  }
}

class WhiteboardPainter extends CustomPainter {
  final List<Offset?> points;

  WhiteboardPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

//Activity Level two
class ActivityLevelTwo extends StatelessWidget {
  const ActivityLevelTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/back4.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'assets/icons/back.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(96, 96, 96, 0.5),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: const Text(
                      'Congratulations!!!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(96, 96, 96, 0.5),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: const Text(
                      'You Have Successfully Finish The Activity',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(activityDashboardRoute),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        const Color.fromARGB(255, 0, 0, 0),
                      ),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 24.0),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Finish',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ui.Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
