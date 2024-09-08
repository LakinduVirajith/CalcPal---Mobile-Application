import 'package:calcpal/services/ideognostic_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/flask_diagnosis_result.dart';
import '../models/diagnosis_result_ideo.dart';
import '../models/diagnosis.dart';
import '../enums/disorder_types.dart';
import '../constants/routes.dart';
import '../services/user_service.dart';

import 'dart:async'; // Import for Stopwatch

class DiagnoseIdeognosticLastScreen extends StatefulWidget {
  final int q1Answer;
  final int q2Answer;
  final int q3Answer;
  final int q4Answer;
  final int totalTime;

  const DiagnoseIdeognosticLastScreen({
    super.key,
    required this.q1Answer,
    required this.q2Answer,
    required this.q3Answer,
    required this.q4Answer,
    required this.totalTime,
  });

  @override
  _DiagnoseIdeognosticLastScreenState createState() =>
      _DiagnoseIdeognosticLastScreenState();
}

class _DiagnoseIdeognosticLastScreenState
    extends State<DiagnoseIdeognosticLastScreen> {
  final GlobalKey<DrawBoxState> _drawBoxKey1 = GlobalKey<DrawBoxState>();
  final GlobalKey<DrawBoxState> _drawBoxKey2 = GlobalKey<DrawBoxState>();
  late int q5Answer;
  late Stopwatch _stopwatch;

  final UserService _userService = UserService();
  final IdeognosticService _questionService = IdeognosticService();

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()
      ..start(); // Start stopwatch when the screen is loaded
  }

  Future<void> _submitResultsToMLModel() async {
    //Validate the handrawn number answer (CNN model call)
    q5Answer = validateAnswer5();

    // Stop timer and record the time
    _stopwatch.stop();

    //calculate total time taken for entire diagnosis question set
    final totalTimeTaken = widget.totalTime + _stopwatch.elapsedMilliseconds;
    final elapsedTimeInSeconds = totalTimeTaken / 1000;
    final roundedElapsedTimeInSeconds = elapsedTimeInSeconds.round();

    // Calculate total score
    int totalScore = 0;
    totalScore += widget.q1Answer == 1 ? 1 : 0;
    totalScore += widget.q2Answer == 1 ? 1 : 0;
    totalScore += widget.q3Answer == 1 ? 1 : 0;
    totalScore += widget.q4Answer == 1 ? 1 : 0;
    totalScore += q5Answer == 1 ? 1 : 0;

    // Get shared preference
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      _handleErrorAndRedirect('Access token error. Please log in again.');
      return;
    }

    // Fetch user
    User? user = await _userService.getUser(accessToken, context);

    if (user == null || user.iqScore == null) {
      _handleErrorAndRedirect('Error fetching user IQ score.');
      return;
    }

    // Variables to store diagnosis and status
    late bool diagnoseStatus;
    late bool status;
    late bool updateStatus;

    // Prepare diagnosis data and fetch diagnosis result from the service
    FlaskDiagnosisResult? diagnosis = await _questionService.getDiagnosisResult(
        Diagnosis(
          age: user.age,
          iq: user.iqScore!,
          q1: widget.q1Answer,
          q2: widget.q2Answer,
          q3: widget.q3Answer,
          q4: widget.q4Answer,
          q5: q5Answer,
          seconds: roundedElapsedTimeInSeconds,
        ),
        context);

    // Check if diagnosis result is valid and get diagnose status
    if (diagnosis != null && diagnosis.prediction != null) {
      diagnoseStatus = diagnosis.prediction!;
    } else {
      _handleErrorAndRedirect('Error fetching diagnosis result.');
      return;
    }

    //converting to bool
    bool q1IsCorrect = widget.q1Answer == 1;
    bool q2IsCorrect = widget.q2Answer == 1;
    bool q3IsCorrect = widget.q3Answer == 1;
    bool q4IsCorrect = widget.q4Answer == 1;
    bool q5IsCorrect = q5Answer == 1;

    // Update user disorder status in the database
    status = await _questionService.addDiagnosisResult(DiagnosisResultIdeo(
        userEmail: user.email,
        timeSeconds: roundedElapsedTimeInSeconds,
        q1: q1IsCorrect,
        q2: q2IsCorrect,
        q3: q3IsCorrect,
        q4: q4IsCorrect,
        q5: q5IsCorrect,
        score: totalScore.toString(),
        diagnosis: diagnoseStatus));

    // Update user disorder type in the service
    if (diagnoseStatus) {
      updateStatus = await _userService.updateDisorderType(
          DisorderTypes.ideognostic, accessToken, context);
    } else {
      updateStatus = await _userService.updateDisorderType(
          DisorderTypes.nonIdeognostic, accessToken, context);
    }
    print(status);
    print(updateStatus);

    // Navigate based on the status of updates
    if (status && updateStatus) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        diagnoseResultRoute, // Change this to your actual route
        (route) => false,
        arguments: {
          'diagnoseType': 'ideognostic',
          'totalScore': totalScore,
          'elapsedTime': roundedElapsedTimeInSeconds,
        },
      );
    } else {
      _handleErrorAndRedirect('Error updating diagnosis result.');
    }
  }

  int validateAnswer5() {
    return 1;
  }

  void _handleErrorAndRedirect(String message) {
    // Handle errors and redirect as needed
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
    // Redirect or other error handling
  }

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
                          'assets/images/ideognostic/ideo_q5.png', // Replace with your actual image path
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
                  // Finish Button
                  ElevatedButton(
                    onPressed: () {
                      _submitResultsToMLModel();
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
