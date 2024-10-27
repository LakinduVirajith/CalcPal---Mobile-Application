import 'dart:ui' as ui;
import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/enums/disorder_types.dart';
import 'package:calcpal/models/diagnosis.dart';
import 'package:calcpal/models/diagnosis_result.dart';
import 'package:calcpal/models/flask_diagnosis_result.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/graphical_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert'; // Import this library for base64 encoding
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer;

class DiagnoseGraphicalScreen extends StatefulWidget {
  const DiagnoseGraphicalScreen({super.key});

  @override
  State<DiagnoseGraphicalScreen> createState() =>
      _DiagnoseGraphicalScreenState();
}

class _DiagnoseGraphicalScreenState extends State<DiagnoseGraphicalScreen> {
  late Size _whiteboardSize;
  Offset _whiteboardOffset = Offset.zero;
  final GlobalKey _whiteboardKey = GlobalKey();
  final GlobalKey _repaintBoundaryKey = GlobalKey(); // for the screenshot
  int _currentQuestionIndex = 0;
  bool isErrorOccurred = false;
  bool isDataLoading = false;
  String selectedLanguageCode = 'en';

  final Stopwatch _stopwatch = Stopwatch();
  List<bool> userResponses = [];

  // INITIALIZING SERVICEs
  final GraphicalService _questionService = GraphicalService();
  final UserService _userService = UserService();
  final ToastService _toastService = ToastService();

  @override
  void initState() {
    super.initState();

    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // SET CUSTOM STATUS BAR COLOR
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    _setupLanguage();
    _stopwatch.start();

    // LOADING ACTIVITY DATA
    // _initiated();
    // _activityFuture = _loadActivity();
  }

  @override
  void dispose() {
    super.dispose();

    _currentQuestionIndex = 0;
    userResponses = [];
    _stopwatch.reset();
  }

  // FUNCTION TO SET THE SELECTED LANGUAGE BASED ON THE STORED LANGUAGE CODE
  Future<void> _setupLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    selectedLanguageCode = languageCode;
  }

  Future<void> _handlePress() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      final response = await _captureScreenshot();
      developer.log("response : $response");

      //await _captureScreenshot();
      setState(() {
        if (response == _questionAnwers[_currentQuestionIndex]) {
          userResponses.insert(_currentQuestionIndex, true);
        } else {
          userResponses.insert(_currentQuestionIndex, false);
        }

        _currentQuestionIndex++; // Move to the next question
      });
    } else {
      final response = await _captureScreenshot();
      developer.log("response : $response");

      setState(() {
        if (response == _questionAnwers[_currentQuestionIndex]) {
          userResponses.insert(_currentQuestionIndex, true);
        } else {
          userResponses.insert(_currentQuestionIndex, false);
        }
      });
      //navigate to the graphical diagnos results
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => const GraphicalDiagnosisresult()),
      // );
      await _submitResultsToMLModel();
    }
  }

  //Capture screenshot method and get the symbol lable
  Future<String> _captureScreenshot() async {
    String predictedLabel = "";
    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Convert pngBytes to base64 string
      String base64String = base64Encode(pngBytes);

      // Get the image lable
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
        developer.log(
            "Failed to send first image. Status code: ${responseSymbol.statusCode}");
      }
    } catch (e) {
      developer.log("Error capturing screenshot: $e");
    }
    return predictedLabel; // Return the predicted label
  }

  // FUNCTION TO SUBMIT RESULTS TO MACHINE LEARNING MODEL
  Future<void> _submitResultsToMLModel() async {
    try {
      setState(() {
        isErrorOccurred = false;
        isDataLoading = true;
      });
      // STOP THE TIMER AND RECORD ELAPSED TIME IN SECONDS
      _stopwatch.stop();
      final elapsedTimeInSeconds = _stopwatch.elapsedMilliseconds / 1000;
      final roundedElapsedTimeInSeconds = elapsedTimeInSeconds.round();

      // CALCULATE THE TOTAL SCORE BASED ON TRUE RESPONSES
      final int totalScore = userResponses.where((response) => response).length;

      // GET THE INSTANCE OF SHARED PREFERENCES
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      // CHECK IF ACCESS TOKEN IS AVAILABLE
      if (accessToken == null) {
        print("hello1");
        _handleErrorAndRedirect(
            AppLocalizations.of(context)!.commonMessagesAccessTokenError);
        return;
      }
      // FETCH USER INFO
      User? user = await _userService.getUser(accessToken, context);

      // CHECK IF USER AND IQ SCORE ARE AVAILABLE
      if (user == null || user.iqScore == null) {
        print("hello2");
        _handleErrorAndRedirect(
            AppLocalizations.of(context)!.commonMessagesIQScoreError);
        return;
      }
      // VARIABLES TO STORE DIAGNOSIS AND UPDATE STATUS
      late bool diagnoseStatus;
      late bool status;
      late bool updateStatus;
      // PREPARE DIAGNOSIS DATA AND FETCH DIAGNOSIS RESULT FROM THE SERVICE
      FlaskDiagnosisResult? diagnosis =
          await _questionService.getDiagnosisResult(
              Diagnosis(
                age: user.age,
                iq: user.iqScore!,
                q1: userResponses[0] ? 1 : 0,
                q2: userResponses[1] ? 1 : 0,
                q3: userResponses[2] ? 1 : 0,
                q4: userResponses[3] ? 1 : 0,
                q5: userResponses[4] ? 1 : 0,
                seconds: roundedElapsedTimeInSeconds,
              ),
              context);
      // CHECK IF DIAGNOSIS RESULT IS VALID AND GET DIAGNOSE STATUS
      if (diagnosis != null && diagnosis.prediction != null) {
        diagnoseStatus = diagnosis.prediction!;
      } else {
        print("hello3");
        _handleErrorAndRedirect(
            AppLocalizations.of(context)!.commonMessagesResultError);
        return;
      }
      // UPDATE USER DISORDER STATUS IN THE DATABASE
      status = await _questionService.addDiagnosisResult(
          DiagnosisResult(
            userEmail: user.email,
            timeSeconds: roundedElapsedTimeInSeconds,
            q1: userResponses[0],
            q2: userResponses[1],
            q3: userResponses[2],
            q4: userResponses[3],
            q5: userResponses[4],
            totalScore: totalScore.toString(),
            label: diagnoseStatus,
          ),
          context);
      // UPDATE USER DISORDER TYPE IN THE SERVICE
      if (diagnoseStatus) {
        updateStatus = await _userService.updateDisorderType(
            DisorderTypes.graphical, accessToken, context);
      } else {
        updateStatus = await _userService.updateDisorderType(
            DisorderTypes.nonGraphical, accessToken, context);
      }
      print("status: $status");
      print("updateStatus: $updateStatus");

      // NAVIGATE BASED ON THE STATUS OF UPDATES
      if (status && updateStatus) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          diagnoseResultRoute,
          (route) => false,
          arguments: {
            'diagnoseType': 'graphical',
            'totalScore': totalScore,
            'elapsedTime': roundedElapsedTimeInSeconds,
          },
        );
      } else {
        print("hello4");
        _handleErrorAndRedirect(
            AppLocalizations.of(context)!.commonMessagesSomethingWrongError);
      }
    } catch (e) {
      developer.log(e.toString());
      setState(() {
        isErrorOccurred = true;
        isDataLoading = false;
      });
    } finally {
      setState(() => isDataLoading = false);
    }
  }

  // FUNCTION TO HANDLE ERRORS AND REDIRECT TO LOGIN PAGE
  void _handleErrorAndRedirect(String message) {
    _toastService.warningToast(message);
    Navigator.of(context).pushNamedAndRemoveUntil(
      loginRoute,
      (route) => false,
    );
  }

  // List of drawing questions english
  final List<String> _questions = [
    'Draw an addition symbol.',
    'Draw a subtraction symbol.',
    'Draw a multiplication symbol.',
    'Draw a division symbol.',
    'Draw an equal symbol.',
  ];

  // List of drawing questions sinhala
  final List<String> _sinhalQuestions = [
    'එකතු කිරීමේ ලකුණ අඳින්න.',
    'අඩුකිරීමේ ලකුණ අඳින්න.',
    'ගුණ කිරීමේ ලකුණ අඳින්න.',
    'බෙදීමේ ලකුණ අඳින්න.',
    'සමාන ලකුණ අඳින්න.',
  ];

  // List of drawing questions tamil
  final List<String> _tamilQuestions = [
    'சேர்க்கை குறியை வரையவும்.',
    'குறைப்புக்குறியை வரையவும்.',
    'பெருக்கல் குறியை வரையவும்.',
    'பகுத்தல் குறியை வரையவும்.',
    'சமமான குறியை வரையவும்.',
  ];

  //List of answers
  final List<String> _questionAnwers = [
    'Add',
    'Minus',
    'Multiply',
    'Divide',
    'Equal',
    'Decimal',
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
            image: AssetImage('assets/images/diagnose_background_v2.png'),
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
                      // _questions[_currentQuestionIndex],
                      selectedLanguageCode == 'en'
                          ? _questions[_currentQuestionIndex]
                          : selectedLanguageCode == 'si'
                              ? _sinhalQuestions[_currentQuestionIndex]
                              : _tamilQuestions[_currentQuestionIndex],
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Stack(
                        children: [
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
                                    points:
                                        _questionPoints[_currentQuestionIndex],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Clear all button (outside RepaintBoundary)
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

class GraphicalDiagnosisresult extends StatelessWidget {
  const GraphicalDiagnosisresult({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backImage.png'),
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
                      "Let's move on to the next task",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(diagnosePractognosticRoute);
                    },
                    child: const Text(
                      'Next',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
