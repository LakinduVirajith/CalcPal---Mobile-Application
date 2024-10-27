import 'package:calcpal/screens/activity_visual_spatial.dart';
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
      'details':
          'A Circle has 0 edges and 0 corners.\nArea: π × radius²\nPerimeter: 2 × π × radius'
    },
    {
      'name': 'Square',
      'image': 'assets/images/Box.png',
      'details':
          'A Square has 4 edges and 4 corners.\nArea: side × side\nPerimeter: 4 × side'
    },
    {
      'name': 'Triangle',
      'image': 'assets/images/Triangle.png',
      'details':
          'A Triangle has 3 edges and 3 corners.\nArea: 0.5 × base × height\nPerimeter: side₁ + side₂ + side₃'
    },
    {
      'name': 'Rectangle',
      'image': 'assets/images/Rectangle.png',
      'details':
          'A Rectangle has 4 edges and 4 corners.\nArea: length × width\nPerimeter: 2 × (length + width)'
    },
    {
      'name': 'Cylinder',
      'image': 'assets/images/Cylinder.png',
      'details':
          'A Cylinder has 2 circular faces and no edges or corners.\nSurface Area: 2 × π × radius × (radius + height)\nVolume: π × radius² × height'
    },
    {
      'name': 'Cube',
      'image': 'assets/images/Cube.png',
      'details':
          'A Cube has 6 faces, 12 edges, and 8 corners.\nSurface Area: 6 × side²\nVolume: side³'
    },
    {
      'name': 'Cuboid',
      'image': 'assets/images/Cuboid.png',
      'details':
          'A Cuboid has 6 faces, 12 edges, and 8 corners.\nSurface Area: 2 × (length × width + width × height + height × length)\nVolume: length × width × height'
    },
    {
      'name': 'Prism',
      'image': 'assets/images/Prism.png',
      'details':
          'A Prism has flat sides and identical ends.\nSurface Area: 2 × base area + perimeter × height\nVolume: base area × height'
    },
    {
      'name': 'Cone',
      'image': 'assets/images/Cone.png',
      'details':
          'A Cone has 1 circular face and 1 corner.\nSurface Area: π × radius × (radius + slant height)\nVolume: 1/3 × π × radius² × height'
    },
  ];

  int currentShapeIndex = 0;
  List<Offset> points = [];

  void _loadNextShape() {
    setState(() {
      points.clear();
      if (currentShapeIndex < shapes.length - 1) {
        currentShapeIndex += 1;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FinishPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Draw Shapes",
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        toolbarHeight: 50.0,
      ),
      body: Row(
        children: [
          // Left side: Shape name, image, and details (1/3 of the width)
          Container(
            width: MediaQuery.of(context).size.width * 0.33,
            padding: const EdgeInsets.all(20.0),
            color: Colors.grey[200],
            child: Center(
              child: Column(
                children: [
                  Text(
                    shapes[currentShapeIndex]['name']!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    shapes[currentShapeIndex]['image']!,
                    width: 90,
                    height: 90,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    shapes[currentShapeIndex]['details']!,
                    style: const TextStyle(
                      fontSize: 14,
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
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    padding: const EdgeInsets.all(10),
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
                        points.add(Offset.zero);
                      },
                      child: CustomPaint(
                        painter: ShapePainter(points),
                        child: Container(),
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
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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

class FinishPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Finish"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Congratulations! You've completed the Shape Drawing.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityVisualSpatialScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                'Next Game',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
