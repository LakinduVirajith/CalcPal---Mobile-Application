// import 'package:flutter/material.dart';
// import 'package:flutter_cube/flutter_cube.dart';

// void main() => runApp(Shapes3D());

// class Shapes3D extends StatefulWidget {
//   @override
//   State<Shapes3D> createState() => _MyAppState();
// }

// class _MyAppState extends State<Shapes3D> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('3D Shape Explorer')),
//         body: ShapeExplorer(),
//       ),
//     );
//   }
// }

// class ShapeExplorer extends StatefulWidget {
//   @override
//   _ShapeExplorerState createState() => _ShapeExplorerState();
// }

// class _ShapeExplorerState extends State<ShapeExplorer> {
//   late Scene _scene;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: Cube(
//             onSceneCreated: (Scene scene) {
//               _scene = scene;
//               _scene.world.add(Object(
//                 scale: Vector3.all(5.0),
//                 position: Vector3(0, 0, 0),
//                 fileName:
//                     'assets/images/Cube.obj', // Ensure you have a cube.obj file in the assets
//               ));
//             },
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: ElevatedButton(
//             onPressed: () {
//               // Rotate the cube
//               _scene.world.children[0].rotation.y += 0.1;
//               setState(() {});
//             },
//             child: Text('Rotate Cube'),
//           ),
//         ),
//       ],
//     );
//   }
// }
