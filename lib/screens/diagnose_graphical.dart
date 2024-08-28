import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnoseGraphicalScreen extends StatefulWidget {
  const DiagnoseGraphicalScreen({super.key});

  @override
  _DiagnoseGraphicalScreenState createState() =>
      _DiagnoseGraphicalScreenState();
}

class _DiagnoseGraphicalScreenState extends State<DiagnoseGraphicalScreen> {
  final List<Offset?> _points = [];
  late Size _whiteboardSize;
  Offset _whiteboardOffset = Offset.zero;
  final GlobalKey _whiteboardKey = GlobalKey();

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
                constraints.maxWidth * 0.6,
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
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'Draw an addition symbol',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
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
                                      _points.add(offset);
                                    });
                                  }
                                },
                                onPanEnd: (details) {
                                  setState(() {
                                    _points.add(null);
                                  });
                                },
                                child: CustomPaint(
                                  painter: WhiteboardPainter(points: _points),
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
                                    _points.clear();
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
                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement Back functionality
                          },
                          child: const Text('Back'),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement Next functionality
                          },
                          child: const Text('Next'),
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
