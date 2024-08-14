import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnoseIdeognosticLastScreen extends StatefulWidget {
  const DiagnoseIdeognosticLastScreen({super.key});

  @override
  _DiagnoseIdeognosticLastScreenState createState() =>
      _DiagnoseIdeognosticLastScreenState();
}

class _DiagnoseIdeognosticLastScreenState
    extends State<DiagnoseIdeognosticLastScreen> {
  final GlobalKey<DrawBoxState> _drawBoxKey1 = GlobalKey<DrawBoxState>();
  final GlobalKey<DrawBoxState> _drawBoxKey2 = GlobalKey<DrawBoxState>();

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/diagnose_id_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content with Grey Box
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 30, horizontal: 20), // Padding around the grey box
              width: MediaQuery.of(context).size.width * 0.6, // Adjusted width
              decoration: BoxDecoration(
                color: Colors.grey.shade800
                    .withOpacity(0.8), // Semi-transparent grey color
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Question Text
                  const Text(
                    'Write the fraction shown by the shape below',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Row containing the shape and fraction input areas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Shape Image
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          'assets/images/q1_img.png', // Replace with your actual image path
                          height: 150,
                          width: 200,
                        ),
                      ),
                      const SizedBox(width: 40),
                      // Fraction Input Areas
                      Column(
                        children: [
                          Row(
                            children: [
                              _buildDrawArea(_drawBoxKey1),
                              _buildEraserButton(_drawBoxKey1),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: 200,
                            height: 2,
                            color: Colors
                                .white, // Divider line between fraction numerator and denominator
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _buildDrawArea(_drawBoxKey2),
                              _buildEraserButton(_drawBoxKey2),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Next Button
                  ElevatedButton(
                    onPressed: () {
                      // Handle "Next" button press
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Finish',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget for the drawing area
  Widget _buildDrawArea(GlobalKey<DrawBoxState> key) {
    return Container(
      width: 150,
      height: 150,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DrawBox(key: key), // Custom painter for drawing
    );
  }

  // Widget for the eraser button
  Widget _buildEraserButton(GlobalKey<DrawBoxState> key) {
    return IconButton(
      icon: const Icon(Icons.phonelink_erase_sharp,
          color: Colors.black), // Eraser icon
      onPressed: () {
        key.currentState?.clearDrawing();
      },
    );
  }
}

class DrawBox extends StatefulWidget {
  const DrawBox({Key? key}) : super(key: key);

  @override
  DrawBoxState createState() => DrawBoxState();
}

class DrawBoxState extends State<DrawBox> {
  final List<Offset?> _points = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          RenderBox renderBox = context.findRenderObject() as RenderBox;
          _points.add(renderBox.globalToLocal(details.globalPosition));
        });
      },
      onPanEnd: (details) {
        _points
            .add(null); // Add a null to indicate the end of the drawing stroke
      },
      child: CustomPaint(
        painter: _DrawingPainter(_points),
      ),
    );
  }

  void clearDrawing() {
    setState(() {
      _points.clear();
    });
  }
}

class _DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  _DrawingPainter(this.points);

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
