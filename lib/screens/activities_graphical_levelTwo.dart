import 'dart:convert';
import 'dart:ui' as ui;
import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

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
  List<bool> userResponses = [];

  // New variable to track activity level
  int activityLevel = 1;

  Future<void> _handlePress() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      final response = await _captureScreenshot();
      print(response);
      setState(() {
        // _currentQuestionIndex++;
        setState(() {
          if (response == _correctQuestionAnwers[_currentQuestionIndex]) {
            _toastService.infoToast(
              'Congratulations!! You Are Correct 👏👏🎉🎉!!',
            );
            _currentQuestionIndex++; // Move to the next question
          } else {
            _toastService.infoToast(
              'Try again!! ☹️☹️!!',
            );
          }
        });
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

  Future<String> _captureScreenshot() async {
    String predictedLabel = "";
    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      String base64String = base64Encode(pngBytes);

      final responseSymbol = await http.post(
        Uri.parse('http://149.102.141.132:5002/predict-symbol'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image": base64String}),
      );

      if (responseSymbol.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(responseSymbol.body);
        predictedLabel = responseData['predicted_class'];
        return predictedLabel;
      } else {
        print(
            "Failed to send first image. Status code: ${responseSymbol.statusCode}");
      }
    } catch (e) {
      print("Error capturing screenshot: $e");
    }
    return predictedLabel;
  }

  // Shuffled List of drawing questions
  final List<String> _questions = [
    'Draw a division symbol.',
    'Draw an equal symbol.',
    'Draw a multiplication symbol.',
    'Draw a subtraction symbol.',
    'Draw an addition symbol.',
    'Draw an equal symbol.',
    'Draw a division symbol.',
    'Draw an addition symbol.',
    'Draw a multiplication symbol.',
    'Draw a subtraction symbol.',
  ];

  // Shuffled List of image paths corresponding to each question
  final List<String> _questionImages = [
    'assets/images/division.png',
    'assets/images/equal.jpg',
    'assets/images/multi.png',
    'assets/images/subs.png',
    'assets/images/add.png',
    'assets/images/equal.jpg',
    'assets/images/division.png',
    'assets/images/add.png',
    'assets/images/multi.png',
    'assets/images/subs.png',
  ];

  final List<String> _correctQuestionAnwers = [
    'Divide',
    'Equal',
    'Multiply',
    'Minus',
    'Add',
    'Equal',
    'Divide',
    'Add',
    'Multiply',
    'Minus',
  ];

  //Initialze the services
  final ToastService _toastService = ToastService();

  // Store points for each question separately
  final List<List<Offset?>> _questionPoints = List.generate(10, (_) => []);

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
                  // back button at the top left corner
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(activityDashboardRoute);
                        },
                        child: Image.asset(
                          'assets/icons/back.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                  ),

                  // Question text
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
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
                              _questionImages[_currentQuestionIndex],
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
                                    // Remove the last inserted value in the array if it exists
                                    if (userResponses.isNotEmpty) {
                                      userResponses.removeLast();
                                    }
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
