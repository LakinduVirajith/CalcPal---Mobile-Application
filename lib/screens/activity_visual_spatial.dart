import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/toast_service.dart';

class ActivityVisualSpatialScreen extends StatefulWidget {
  const ActivityVisualSpatialScreen({super.key});
  @override
  State<ActivityVisualSpatialScreen> createState() =>
      _ActivityVisualSpatialScreenState();
}

class _ActivityVisualSpatialScreenState
    extends State<ActivityVisualSpatialScreen> {
  final int gridSize = 4;
  final ToastService _toastService = ToastService();

  // Keep track of which grid cell holds which shape
  late List<String?> gridValues;

  // Define the correct placements for each grid cell (optional, for validation)
  final List<String?> correctGridValues = [
    'Circle',
    'Triangle',
    'Square',
    'Rectangle'
  ];

  @override
  void initState() {
    super.initState();
    gridValues = List.generate(gridSize * gridSize, (index) => null);
    itemGenerate = generateRandomItems(shapes, 10);
    print(itemGenerate);
  }

  int attept = 10;
  // late List<String?> itemGenerate;
  List<String> shapes = ['Circle', 'Triangle', 'Square', 'Rectangle'];

  // Generate the list randomly with a maximum of 10 items
  late List<String> itemGenerate;

  List<String> generateRandomItems(List<String> shapes, int totalItems) {
    // Create an empty list to store the randomly generated items
    List<String> randomItems = [];

    Random random = Random();

    // Repeat the process until we have 'totalItems' in the list
    for (int i = 0; i < totalItems; i++) {
      // Randomly pick an item from the shapes list
      int randomIndex = random.nextInt(shapes.length);

      // Add the random shape to the list
      randomItems.add(shapes[randomIndex]);
    }

    return randomItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Shape Bucket'),
        ),
        body: Container(
          margin: const EdgeInsets.only(top: .0),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/images/activity_background_v5.jpg'), // Path to your image
              fit: BoxFit.cover, // Fit the image to the screen
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: gridSize,
                  itemBuilder: (context, index) {
                    return DragTarget<String>(
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          decoration: BoxDecoration(
                              color: gridValues[index] != null
                                  ? const Color.fromARGB(31, 145, 221, 148)
                                  : const Color.fromARGB(134, 224, 167, 167),
                              border: Border.all(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  width: 5.0),
                              borderRadius: BorderRadius.circular(150.0)),
                          child: Center(
                            child: Text(shapes[index]),
                          ),
                        );
                      },
                      onAccept: (data) {
                        // Check if the drop is correct (optional)
                        if (correctGridValues[index] == null ||
                            data == correctGridValues[index]) {
                          setState(() {
                            gridValues[index] = data;
                          });
                        } else {
                          // Provide feedback for incorrect placement (optional)
                          _toastService.warningToast("Try Again !!!");
                        }
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              // Shapes to drag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: itemGenerate.map((item) {
                  return GestureDetector(
                    // onTap: () {
                    // itemGenerate.remove(item);
                    // attept++;
                    // },
                    // key: ValueKey<int>(attept),
                    child: _shapeItem(item,
                        "/Users/macbookpro2018/Desktop/SLIIT/Research/CalcPal---Mobile-Application/assets/images/${item}.png"),
                  );
                }).toList(),
              ),
              SizedBox(height: 10.0),
            ],
          ),
        ));
  }

  Widget _shapeItem(String shape, String imagePath) {
    return Draggable<String>(
      data: shape,
      onDragCompleted: () => itemGenerate.remove(shape),
      child: _buildShapeWidget(imagePath),
      feedback: _buildShapeWidget(imagePath), // What is shown while dragging
      childWhenDragging: Container(), // Shape disappears when being dragged
    );
  }

  Widget _buildShapeWidget(String imagePath) {
    return Container(
      width: 60,
      height: 60,
      child: Center(
        child: Image.asset(imagePath), // Display image
      ),
    );
  }
}

// class ShapeItem extends StatelessWidget {
//   final String shape;
//   final String imagePath;

//   ShapeItem({required this.shape, required this.imagePath});

//   @override
//   Widget build(BuildContext context) {
//     return Draggable<String>(
//       data: shape,
//       onDragCompleted: () => shape.,
//       child: _buildShapeWidget(),
//       feedback: _buildShapeWidget(), // What is shown while dragging
//       childWhenDragging: Container(), // Shape disappears when being dragged
//     );
//   }

//   Widget _buildShapeWidget() {
//     return Container(
//       width: 50,
//       height: 50,
//       child: Center(
//         child: Image.asset(imagePath), // Display image
//       ),
//     );
//   }
// }

 
