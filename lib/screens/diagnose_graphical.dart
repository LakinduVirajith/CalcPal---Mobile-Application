import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

class DiagnoseGraphicalScreen extends StatefulWidget {
  const DiagnoseGraphicalScreen({super.key});

  @override
  _DiagnoseGraphicalScreenState createState() =>
      _DiagnoseGraphicalScreenState();
}

class _DiagnoseGraphicalScreenState extends State<DiagnoseGraphicalScreen> {
  late Size _whiteboardSize;
  Offset _whiteboardOffset = Offset.zero;
  final GlobalKey _whiteboardKey = GlobalKey();
  final GlobalKey _repaintBoundaryKey = GlobalKey(); // for the screenshot
  int _currentQuestionIndex = 0;

  // List of drawing questions
  final List<String> _questions = [
    'Draw an addition symbol.',
    'Draw a subtraction symbol.',
    'Draw a multiplication symbol.',
    'Draw a division symbol.',
    'Draw an equal symbol.',
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
            image: AssetImage('assets/images/graphical.jpg'),
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
                      child: RepaintBoundary(
                        key: _repaintBoundaryKey,
                        child: Container(
                          key: _whiteboardKey,
                          width: _whiteboardSize.width,
                          height: _whiteboardSize.height,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    final RenderBox renderBox =
                                        context.findRenderObject() as RenderBox;
                                    final localPosition = renderBox
                                        .globalToLocal(details.globalPosition);

                                    // Convert global position to local position relative to the whiteboard container
                                    final offset =
                                        localPosition - _whiteboardOffset;

                                    if (_isWithinBounds(
                                        offset, _whiteboardSize)) {
                                      setState(() {
                                        _questionPoints[_currentQuestionIndex]
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
                          onPressed:
                              _currentQuestionIndex < _questions.length - 1
                                  ? () {
                                      setState(() {
                                        _currentQuestionIndex++;
                                      });
                                    }
                                  : _captureScreenshot,
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
