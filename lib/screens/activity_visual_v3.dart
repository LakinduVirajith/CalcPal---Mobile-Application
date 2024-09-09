import 'package:flutter/material.dart';

void main() {
  runApp(ShapeDrawingApp());
}

class ShapeDrawingApp extends StatefulWidget {
  @override
  State<ShapeDrawingApp> createState() => _ShapeDrawingAppState();
}

class _ShapeDrawingAppState extends State<ShapeDrawingApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ShapeDrawingPage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class ShapeDrawingPage extends StatefulWidget {
  @override
  _ShapeDrawingPageState createState() => _ShapeDrawingPageState();
}

class _ShapeDrawingPageState extends State<ShapeDrawingPage> {
  final List<Map<String, String>> shapes = [
    {
      'name': 'Circle',
      'image': 'assets/images/Circle.png',
      'details': 'A Circle has 0 edges and 0 corners.'
    },
    {
      'name': 'Square',
      'image': 'assets/images/Square.png',
      'details': 'A Square has 4 edges and 4 corners.'
    },
    {
      'name': 'Triangle',
      'image': 'assets/images/Triangle.png',
      'details': 'A Triangle has 3 edges and 3 corners.'
    },
    {
      'name': 'Rectangle',
      'image': 'assets/images/Rectangle.png',
      'details': 'A Rectangle has 4 edges and 4 corners.'
    },
  ];

  int currentShapeIndex = 0;
  List<Offset> points = [];

  void _loadNextShape() {
    setState(() {
      points.clear();
      currentShapeIndex = (currentShapeIndex + 1) % shapes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Draw Shapes"),
        backgroundColor: const Color.fromARGB(255, 105, 214, 91),
      ),
      body: Row(
        children: [
          // Left side: Shape name, image, and details (1/3 of the width)
          Container(
            width: MediaQuery.of(context).size.width * 0.33, // 1/3 of the width
            padding: const EdgeInsets.all(20.0),
            color: Colors.grey[200], // Background color for the left section
            child: Center(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shapes[currentShapeIndex]['name']!,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 20),
                  Image.asset(
                    shapes[currentShapeIndex]['image']!,
                    width: 120,
                    height: 120,
                  ),
                  SizedBox(height: 20),
                  Text(
                    shapes[currentShapeIndex]['details']!,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right side: Whiteboard for drawing shapes (2/3 of the width)
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 3),
                    ),
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          RenderBox renderBox =
                              context.findRenderObject() as RenderBox;
                          points.add(
                              renderBox.globalToLocal(details.localPosition));
                        });
                      },
                      onPanEnd: (details) {
                        points.add(
                            Offset.zero); // Add a separator to stop the line
                      },
                      child: CustomPaint(
                        painter: ShapePainter(points),
                        child:
                            Container(), // Ensure the container takes up space
                      ),
                    ),
                  ),
                ),

                // Finish button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: _loadNextShape,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      backgroundColor: Colors.deepPurple, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                      ),
                    ),
                    child: Text(
                      'Finish',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final List<Offset> points;
  ShapePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
