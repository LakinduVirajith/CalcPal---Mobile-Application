// class _ActivitiesGraphicalScreenState extends State<ActivitiesGraphicalScreen> {
//   late Size _whiteboardSize;
//   Offset _whiteboardOffset = Offset.zero;
//   final GlobalKey _whiteboardKey = GlobalKey();
//   final GlobalKey _repaintBoundaryKey = GlobalKey(); // for the screenshot
//   int _currentQuestionIndex = 0;

//   // New variable to track activity level
//   int activityLevel = 1;

//   // List of questions for activity level 1
//   final List<String> _level1Questions = [
//     'Draw an addition symbol.',
//     'Draw a subtraction symbol.',
//     'Draw a multiplication symbol.',
//     'Draw a division symbol.',
//     'Draw an equal symbol.',
//   ];

//   // List of questions for activity level 2
//   final List<String> _level2Questions = [
//     'Draw a greater than symbol.',
//     'Draw a less than symbol.',
//     'Draw a circle.',
//     'Draw a square.',
//     'Draw a triangle.',
//   ];

//   // List of image paths for each question for activity level 1
//   final List<String> _level1Images = [
//     'assets/images/add.png',
//     'assets/images/subs.png',
//     'assets/images/multi.png',
//     'assets/images/division.png',
//     'assets/images/equal.jpg'
//   ];

//   // List of image paths for each question for activity level 2
//   final List<String> _level2Images = [
//     'assets/images/greater_than.png',
//     'assets/images/less_than.png',
//     'assets/images/circle.png',
//     'assets/images/square.png',
//     'assets/images/triangle.png'
//   ];

//   // List to store points for each question separately for activity level 1
//   final List<List<Offset?>> _level1Points = List.generate(5, (_) => []);

//   // List to store points for each question separately for activity level 2
//   final List<List<Offset?>> _level2Points = List.generate(5, (_) => []);

//   Future<void> _handlePress() async {
//     if (_currentQuestionIndex < _getCurrentQuestions().length - 1) {
//       await _captureScreenshot();
//       print("screenshot");
//       setState(() {
//         _currentQuestionIndex++;
//       });
//     } else {
//       await _captureScreenshot();
//       if (activityLevel == 1) {
//         // Move to Level 2
//         setState(() {
//           activityLevel = 2;
//           _currentQuestionIndex = 0;
//         });
//       } else {
//         //Navigate to the next screen after Level 2
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const ActivityLevelTwo()),
//         );
//       }
//     }
//   }

//   List<String> _getCurrentQuestions() {
//     return activityLevel == 1 ? _level1Questions : _level2Questions;
//   }

//   List<String> _getCurrentImages() {
//     return activityLevel == 1 ? _level1Images : _level2Images;
//   }

//   List<List<Offset?>> _getCurrentPoints() {
//     return activityLevel == 1 ? _level1Points : _level2Points;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // FORCE LANDSCAPE ORIENTATION
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/back.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Center(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               // Calculate whiteboard size
//               _whiteboardSize = Size(
//                 constraints.maxWidth * 0.5,
//                 constraints.maxHeight * 0.5,
//               );

//               // Schedule whiteboard offset calculation after the layout is built
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 final RenderBox renderBox = _whiteboardKey.currentContext
//                     ?.findRenderObject() as RenderBox;
//                 if (renderBox != null) {
//                   setState(() {
//                     _whiteboardOffset = renderBox.localToGlobal(Offset.zero);
//                   });
//                 }
//               });

//               return Column(
//                 children: [
//                   // Question text
//                   Padding(
//                     padding: const EdgeInsets.only(top: 60.0),
//                     child: Text(
//                       _getCurrentQuestions()[_currentQuestionIndex],
//                       style: const TextStyle(
//                           fontSize: 28, fontWeight: FontWeight.bold),
//                     ),
//                   ),

//                   Expanded(
//                     child: Center(
//                       child: Stack(
//                         children: [
//                           // Whiteboard container with low-opacity symbol
//                           RepaintBoundary(
//                             key: _repaintBoundaryKey,
//                             child: Container(
//                               key: _whiteboardKey,
//                               width: _whiteboardSize.width,
//                               height: _whiteboardSize.height,
//                               decoration: BoxDecoration(
//                                 border:
//                                     Border.all(color: Colors.black, width: 1),
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Stack(
//                                 children: [
//                                   // Low-opacity symbol inside the whiteboard
//                                   Positioned.fill(
//                                     child: Opacity(
//                                       opacity: 0.2,
//                                       child: Image.asset(
//                                         _getCurrentImages()[
//                                             _currentQuestionIndex],
//                                         fit: BoxFit.contain,
//                                       ),
//                                     ),
//                                   ),
//                                   Positioned.fill(
//                                     child: GestureDetector(
//                                       onPanUpdate: (details) {
//                                         final RenderBox renderBox = context
//                                             .findRenderObject() as RenderBox;
//                                         final localPosition =
//                                             renderBox.globalToLocal(
//                                                 details.globalPosition);

//                                         // Convert global position to local position relative to the whiteboard container
//                                         final offset =
//                                             localPosition - _whiteboardOffset;

//                                         if (_isWithinBounds(
//                                             offset, _whiteboardSize)) {
//                                           setState(() {
//                                             _getCurrentPoints()[
//                                                     _currentQuestionIndex]
//                                                 .add(offset);
//                                           });
//                                         }
//                                       },
//                                       onPanEnd: (details) {
//                                         setState(() {
//                                           _getCurrentPoints()[
//                                                   _currentQuestionIndex]
//                                               .add(null);
//                                         });
//                                       },
//                                       child: CustomPaint(
//                                         painter: WhiteboardPainter(
//                                           points: _getCurrentPoints()[
//                                               _currentQuestionIndex],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   // Clear all button
//                                   Positioned(
//                                     top: 10,
//                                     right: 10,
//                                     child: ElevatedButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           _getCurrentPoints()[
//                                                   _currentQuestionIndex]
//                                               .clear();
//                                         });
//                                       },
//                                       child: const Text('Clear All'),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),

//                           // Symbol on the right side of the whiteboard
//                           Positioned(
//                             right: 0,
//                             top: 50,
//                             child: Image.asset(
//                               _getCurrentImages()[_currentQuestionIndex],
//                               width: 100,
//                               height: 100,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // Navigation buttons
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         ElevatedButton(
//                           onPressed: _currentQuestionIndex > 0
//                               ? () {
//                                   setState(() {
//                                     _currentQuestionIndex--;
//                                   });
//                                 }
//                               : null,
//                           child: const Text('Back'),
//                         ),
//                         const SizedBox(width: 20),
//                         ElevatedButton(
//                           onPressed: _handlePress,
//                           child: Text(_currentQuestionIndex <
//                                   _getCurrentQuestions().length - 1
//                               ? 'Next'
//                               : activityLevel == 1
//                                   ? 'Next Level'
//                                   : 'Submit'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   bool _isWithinBounds(Offset position, Size whiteboardSize) {
//     return position.dx >= 0 &&
//         position.dy >= 0 &&
//         position.dx <= whiteboardSize.width &&
//         position.dy <= whiteboardSize.height;
//   }
// }
