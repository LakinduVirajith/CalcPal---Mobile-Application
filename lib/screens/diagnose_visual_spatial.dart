import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/enums/disorder_types.dart';
import 'package:calcpal/models/diagnosis.dart';
import 'package:calcpal/models/diagnosis_result.dart';
import 'package:calcpal/models/flask_diagnosis_result.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:calcpal/services/visual_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

class DiagnoseVisualScreen extends StatefulWidget {
  const DiagnoseVisualScreen({super.key});
  static late BytesSource questionVoice;
  static late String question;
  static late List<String> answers;
  static late String correctAnswer;
  static List<bool> userResponses = [];
  static int currentQuestionNumber = 1;
  static String selectedLanguageCode = 'en-US';
  static bool isDataLoading = false;
  static bool isErrorOccurred = false;

  @override
  State<DiagnoseVisualScreen> createState() => _DiagnoseVisualScreenState();
}

class _DiagnoseVisualScreenState extends State<DiagnoseVisualScreen> {
  late Future<void> _questionFuture;
  final VisualService _questionService = VisualService();
  final UserService _userService = UserService();
  final ToastService _toastService = ToastService();
  final Stopwatch _stopwatch = Stopwatch();
  late Size _whiteboardSize = Size(500, 300);
  final GlobalKey _whiteboardKey = GlobalKey();
  int _currentQuestionIndex = 0;
  String correctAnswer = "";

  final List<List<Offset?>> _questionPoints = List.generate(5, (_) => []);
  @override
  void initState() {
    super.initState();
    _questionFuture = _loadQuestion();
  }

  @override
  void dispose() {
    DiagnoseVisualScreen.currentQuestionNumber = 1;
    DiagnoseVisualScreen.userResponses = [];
    _stopwatch.reset();
    super.dispose();
  }

  Future<void> _setupLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    DiagnoseVisualScreen.selectedLanguageCode = languageCode;
  }

  Future<void> _loadQuestion() async {
    try {
      await _setupLanguage();
      setState(() {
        DiagnoseVisualScreen.isErrorOccurred = false;
        DiagnoseVisualScreen.isDataLoading = true;
      });

      final question = await _questionService.fetchQuestion(
          DiagnoseVisualScreen.currentQuestionNumber,
          CommonService.getLanguageForAPI(
              DiagnoseVisualScreen.selectedLanguageCode),
          context);

      if (question != null) {
        setState(() {
          DiagnoseVisualScreen.question = question.question;
          DiagnoseVisualScreen.answers = question.answers;
          DiagnoseVisualScreen.answers.shuffle();
          DiagnoseVisualScreen.correctAnswer = question.correctAnswer;
        });
        if (DiagnoseVisualScreen.selectedLanguageCode != 'en') {
          _decodeQuestion(DiagnoseVisualScreen.question);
          DiagnoseVisualScreen.answers =
              CommonService.decodeList(question.answers);
          DiagnoseVisualScreen.correctAnswer =
              CommonService.decodeString(question.correctAnswer);
          print(DiagnoseVisualScreen.answers);
          print(DiagnoseVisualScreen.correctAnswer);
        }
        if (DiagnoseVisualScreen.currentQuestionNumber == 1) {
          _stopwatch.start();
        }
      } else {
        setState(() {
          DiagnoseVisualScreen.isErrorOccurred = true;
          DiagnoseVisualScreen.isDataLoading = false;
        });
      }
    } catch (e) {
      developer.log(e.toString());
      setState(() {
        DiagnoseVisualScreen.isErrorOccurred = true;
        DiagnoseVisualScreen.isDataLoading = false;
      });
    } finally {
      setState(() => DiagnoseVisualScreen.isDataLoading = false);
    }
  }

  Future _decodeQuestion(String question) async {
    try {
      setState(() {
        DiagnoseVisualScreen.question = utf8.decode(base64Decode(question));
      });
    } catch (e) {
      developer.log('Error decoding answers: ${e.toString()}');
    }
  }

  Future<void> _handleAnswer(String userAnswer) async {
    if (userAnswer == DiagnoseVisualScreen.correctAnswer) {
      DiagnoseVisualScreen.userResponses
          .insert(DiagnoseVisualScreen.currentQuestionNumber - 1, true);
    } else {
      DiagnoseVisualScreen.userResponses
          .insert(DiagnoseVisualScreen.currentQuestionNumber - 1, false);
    }

    if (DiagnoseVisualScreen.currentQuestionNumber != 5) {
      DiagnoseVisualScreen.currentQuestionNumber++;
      _loadQuestion();
    } else {
      _submitResultsToMLModel();
    }
  }

  Future<bool> _submitdata() async {
    try {
      late String predictedLabel2 = "";
      RenderRepaintBoundary boundary2 = _whiteboardKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image2 = await boundary2.toImage(pixelRatio: 1.0);
      ByteData? byteData2 =
          await image2.toByteData(format: ui.ImageByteFormat.png);

      if (byteData2 != null) {
        List<int> bytes = List<int>.generate(
            byteData2.lengthInBytes, (index) => byteData2.getUint8(index));
        String base64String2 = base64Encode(bytes);
        final response2 = await http.post(
          Uri.parse('http://149.102.141.132:5002/predict-shape'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"image": base64String2}),
        );

        if (response2.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response2.body);
          predictedLabel2 = responseData['class'];
          _handleAnswer(predictedLabel2);
        } else {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _submitResultsToMLModel() async {
    _stopwatch.stop();
    final elapsedTimeInSeconds = _stopwatch.elapsedMilliseconds / 1000;
    final roundedElapsedTimeInSeconds = elapsedTimeInSeconds.round();

    final int totalScore =
        DiagnoseVisualScreen.userResponses.where((response) => response).length;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesAccessTokenError);
      return;
    }
    User? user = await _userService.getUser(accessToken, context);

    if (user == null || user.iqScore == null) {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesIQScoreError);
      return;
    }
    late bool diagnoseStatus;
    late bool status;
    late bool updateStatus;

    FlaskDiagnosisResult? diagnosis = await _questionService.getDiagnosisResult(
        Diagnosis(
          age: user.age,
          iq: user.iqScore!,
          q1: DiagnoseVisualScreen.userResponses[0] ? 1 : 0,
          q2: DiagnoseVisualScreen.userResponses[1] ? 1 : 0,
          q3: DiagnoseVisualScreen.userResponses[2] ? 1 : 0,
          q4: DiagnoseVisualScreen.userResponses[3] ? 1 : 0,
          q5: DiagnoseVisualScreen.userResponses[4] ? 1 : 0,
          seconds: roundedElapsedTimeInSeconds,
        ),
        context);
    if (diagnosis != null && diagnosis.prediction != null) {
      diagnoseStatus = diagnosis.prediction!;
    } else {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesResultError);
      return;
    }

    status = await _questionService.addDiagnosisResult(
        DiagnosisResult(
          userEmail: user.email,
          timeSeconds: roundedElapsedTimeInSeconds,
          q1: DiagnoseVisualScreen.userResponses[0],
          q2: DiagnoseVisualScreen.userResponses[1],
          q3: DiagnoseVisualScreen.userResponses[2],
          q4: DiagnoseVisualScreen.userResponses[3],
          q5: DiagnoseVisualScreen.userResponses[4],
          totalScore: totalScore.toString(),
          label: diagnoseStatus,
        ),
        context);

    if (diagnoseStatus) {
      updateStatus = await _userService.updateDisorderType(
          DisorderTypes.visualSpatial, accessToken, context);
    } else {
      updateStatus = await _userService.updateDisorderType(
          DisorderTypes.nonVisualSpatial, accessToken, context);
    }

    if (status && updateStatus) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        diagnoseResultRoute,
        (route) => false,
        arguments: {
          'diagnoseType': 'VisualSpatial',
          'totalScore': totalScore,
          'elapsedTime': roundedElapsedTimeInSeconds,
        },
      );
    } else {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesSomethingWrongError);
    }
  }

  void _handleErrorAndRedirect(String message) {
    _toastService.warningToast(message);
    Navigator.of(context).pushNamedAndRemoveUntil(
      loginRoute,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        systemNavigationBarColor: Colors.black,
      ),
    );

    return PopScope(
      canPop: false, // Prevent popping the route
      onPopInvoked: (didPop) {
        if (didPop) return; // Prevent default back navigation
        Navigator.of(context).pushNamed('/mainDashboardRoute');
      },
      child: Scaffold(
        body: SafeArea(
          right: false,
          left: false,
          child: FutureBuilder(
            future: _questionFuture,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate whiteboard size
                  _whiteboardSize = Size(
                    constraints.maxWidth * 0.5,
                    constraints.maxHeight * 0.5,
                  );
                  return Stack(
                    children: [
                      // Set background image
                      Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/diagnose_background_v4.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: constraints.maxHeight * 0.1,
                        right: constraints.maxWidth * 0.25,
                        left: constraints.maxWidth * 0.25,
                        bottom: constraints.maxHeight * 0.1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24.0,
                            horizontal: 36.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(96, 96, 96, 1),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  DiagnoseVisualScreen.isDataLoading)
                              ? // Show loader while waiting for the question to load
                              const Center(
                                  child: SpinKitCubeGrid(
                                    color: Colors.white,
                                    size: 80.0,
                                  ),
                                )
                              : (snapshot.hasError ||
                                      DiagnoseVisualScreen.isErrorOccurred)
                                  ? // Display error if loading failed
                                  const Center(
                                      child: Text(
                                        "Error loading question", // Replace with localization
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400),
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        Text(
                                          DiagnoseVisualScreen.question,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: DiagnoseVisualScreen
                                                          .selectedLanguageCode ==
                                                      'ta'
                                                  ? 16
                                                  : 20,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400),
                                        ),
                                        const SizedBox(height: 5.0),
                                        DiagnoseVisualScreen
                                                    .currentQuestionNumber ==
                                                5
                                            ? RepaintBoundary(
                                                key: _whiteboardKey,
                                                child: Container(
                                                  width: _whiteboardSize.width,
                                                  height:
                                                      _whiteboardSize.height,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black,
                                                        width: 1),
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned.fill(
                                                        child: GestureDetector(
                                                          onPanUpdate:
                                                              (details) {
                                                            final RenderBox
                                                                renderBox =
                                                                _whiteboardKey
                                                                        .currentContext!
                                                                        .findRenderObject()
                                                                    as RenderBox;
                                                            final localPosition =
                                                                renderBox
                                                                    .globalToLocal(
                                                                        details
                                                                            .globalPosition);

                                                            if (_isWithinBounds(
                                                                localPosition,
                                                                _whiteboardSize)) {
                                                              setState(() {
                                                                _questionPoints[
                                                                        _currentQuestionIndex]
                                                                    .add(
                                                                        localPosition);
                                                              });
                                                            }
                                                          },
                                                          onPanEnd: (details) {
                                                            setState(() {
                                                              _questionPoints[
                                                                      _currentQuestionIndex]
                                                                  .add(null);
                                                            });
                                                          },
                                                          child: CustomPaint(
                                                            painter:
                                                                WhiteboardPainter(
                                                              points: _questionPoints[
                                                                  _currentQuestionIndex],
                                                            ),
                                                            size: Size(
                                                                _whiteboardSize
                                                                    .width,
                                                                _whiteboardSize
                                                                    .height),
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
                                                              _questionPoints[
                                                                      _currentQuestionIndex]
                                                                  .clear();
                                                            });
                                                          },
                                                          child: const Text(
                                                              'Clear All'),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () =>
                                                            _submitdata(),
                                                        child: Text("Finish"),
                                                      ),
                                                    ],
                                                  ),
                                                ))
                                            : Column(
                                                children: [
                                                  Container(
                                                    height: 80,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: AssetImage(
                                                            'assets/images/Visual${DiagnoseVisualScreen.currentQuestionNumber}.png'),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  // Answer options
                                                  AnimatedSwitcher(
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    child: Wrap(
                                                      key: ValueKey<int>(
                                                          DiagnoseVisualScreen
                                                              .currentQuestionNumber),
                                                      spacing:
                                                          12.0, // Spacing between boxes horizontally
                                                      runSpacing:
                                                          12.0, // Spacing between boxes vertically
                                                      children:
                                                          DiagnoseVisualScreen
                                                              .answers
                                                              .map((answer) {
                                                        return GestureDetector(
                                                          onTap: () =>
                                                              _handleAnswer(
                                                                  answer),
                                                          child: AnswerBox(
                                                            width: 150.0,
                                                            height: 55.0,
                                                            value: answer,
                                                            size: 20.0,
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ],
                                    ),
                        ),
                      ),
                    ],
                  );
                },
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

class AnswerBox extends StatelessWidget {
  final double width;
  final double height;
  final String value;
  final double size;

  const AnswerBox({
    required this.width,
    required this.height,
    required this.value,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        value,
        style: TextStyle(color: Colors.white, fontSize: size),
      ),
    );
  }
}
