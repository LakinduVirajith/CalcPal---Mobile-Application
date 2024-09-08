import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/enums/disorder_types.dart';
import 'package:calcpal/models/diagnosis.dart';
import 'package:calcpal/models/diagnosis_result.dart';
import 'package:calcpal/models/flask_diagnosis_result.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:calcpal/services/sequential_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:calcpal/widgets/answer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer;

class DiagnoseSequentialScreen extends StatefulWidget {
  const DiagnoseSequentialScreen({super.key});

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
  State<DiagnoseSequentialScreen> createState() =>
      _DiagnoseSequentialScreenState();
}

class _DiagnoseSequentialScreenState extends State<DiagnoseSequentialScreen> {
  // FUTURE THAT HOLDS THE STATE OF THE QUESTION LOADING PROCESS
  late Future<void> _questionFuture;

  // INITIALIZING THE VERBAL SERVICE
  final SequentialService _questionService = SequentialService();
  // INITIALIZING THE USER SERVICE
  final UserService _userService = UserService();
  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();
  // STOPWATCH INSTANCE FOR TIMING
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    // LOAD THE FIRST QUESTION WHEN THE WIDGET IS INITIALIZED
    _questionFuture = _loadQuestion();
  }

  @override
  void dispose() {
    DiagnoseSequentialScreen.currentQuestionNumber = 1;
    DiagnoseSequentialScreen.userResponses = [];
    _stopwatch.reset();
    super.dispose();
  }

  // FUNCTION TO SET THE SELECTED LANGUAGE BASED ON THE STORED LANGUAGE CODE
  Future<void> _setupLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    DiagnoseSequentialScreen.selectedLanguageCode = languageCode;
  }

  // FUNCTION TO LOAD AND PLAY QUESTION
  Future<void> _loadQuestion() async {
    try {
      await _setupLanguage();
      setState(() {
        DiagnoseSequentialScreen.isErrorOccurred = false;
        DiagnoseSequentialScreen.isDataLoading = true;
      });

      final question = await _questionService.fetchQuestion(
          DiagnoseSequentialScreen.currentQuestionNumber,
          CommonService.getLanguageForAPI(
              DiagnoseSequentialScreen.selectedLanguageCode),
          context);

      if (question != null) {
        setState(() {
          DiagnoseSequentialScreen.question = question.question;
          DiagnoseSequentialScreen.answers = question.answers;
          DiagnoseSequentialScreen.answers.shuffle();
          DiagnoseSequentialScreen.correctAnswer = question.correctAnswer;
        });
        // DECODE BASE64 ENCODED QUESTION
        if (DiagnoseSequentialScreen.selectedLanguageCode != 'en') {
          _decodeQuestion(DiagnoseSequentialScreen.question);
        }
        // START THE STOPWATCH FOR THE FIRST QUESTION ONLY
        if (DiagnoseSequentialScreen.currentQuestionNumber == 1) {
          _stopwatch.start();
        }
      } else {
        setState(() {
          DiagnoseSequentialScreen.isErrorOccurred = true;
          DiagnoseSequentialScreen.isDataLoading = false;
        });
      }
    } catch (e) {
      developer.log(e.toString());
      setState(() {
        DiagnoseSequentialScreen.isErrorOccurred = true;
        DiagnoseSequentialScreen.isDataLoading = false;
      });
    } finally {
      setState(() => DiagnoseSequentialScreen.isDataLoading = false);
    }
  }

  // FUNCTION TO DECODE BASE64 ENCODED QUESTION
  Future _decodeQuestion(String question) async {
    try {
      setState(() {
        DiagnoseSequentialScreen.question = utf8.decode(base64Decode(question));
      });
    } catch (e) {
      developer.log('Error decoding answers: ${e.toString()}');
    }
  }

  // FUNCTION TO HANDLE USER ANSWERS
  Future<void> _handleAnswer(String userAnswer) async {
    // CHECK IF THE USER'S ANSWER IS CORRECT
    if (userAnswer == DiagnoseSequentialScreen.correctAnswer) {
      DiagnoseSequentialScreen.userResponses
          .insert(DiagnoseSequentialScreen.currentQuestionNumber - 1, true);
    } else {
      DiagnoseSequentialScreen.userResponses
          .insert(DiagnoseSequentialScreen.currentQuestionNumber - 1, false);
    }

    // CHECK IF THERE ARE MORE QUESTIONS LEFT
    if (DiagnoseSequentialScreen.currentQuestionNumber != 5) {
      DiagnoseSequentialScreen.currentQuestionNumber++;
      _loadQuestion();
    } else {
      _submitResultsToMLModel();
    }
  }

  // FUNCTION TO SUBMIT RESULTS TO MACHINE LEARNING MODEL
  Future<void> _submitResultsToMLModel() async {
    // STOP THE TIMER AND RECORD ELAPSED TIME IN SECONDS
    _stopwatch.stop();
    final elapsedTimeInSeconds = _stopwatch.elapsedMilliseconds / 1000;
    final roundedElapsedTimeInSeconds = elapsedTimeInSeconds.round();

    // CALCULATE THE TOTAL SCORE BASED ON TRUE RESPONSES
    final int totalScore = DiagnoseSequentialScreen.userResponses
        .where((response) => response)
        .length;

    // GET THE INSTANCE OF SHARED PREFERENCES
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    // CHECK IF ACCESS TOKEN IS AVAILABLE
    if (accessToken == null) {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesAccessTokenError);
      return;
    }

    // FETCH USER INFO
    User? user = await _userService.getUser(accessToken, context);

    // CHECK IF USER AND IQ SCORE ARE AVAILABLE
    if (user == null || user.iqScore == null) {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesIQScoreError);
      return;
    }

    // VARIABLES TO STORE DIAGNOSIS AND UPDATE STATUS
    late bool diagnoseStatus;
    late bool status;
    late bool updateStatus;

    // PREPARE DIAGNOSIS DATA AND FETCH DIAGNOSIS RESULT FROM THE SERVICE
    FlaskDiagnosisResult? diagnosis = await _questionService.getDiagnosisResult(
        Diagnosis(
          age: user.age,
          iq: user.iqScore!,
          q1: DiagnoseSequentialScreen.userResponses[0] ? 1 : 0,
          q2: DiagnoseSequentialScreen.userResponses[1] ? 1 : 0,
          q3: DiagnoseSequentialScreen.userResponses[2] ? 1 : 0,
          q4: DiagnoseSequentialScreen.userResponses[3] ? 1 : 0,
          q5: DiagnoseSequentialScreen.userResponses[4] ? 1 : 0,
          seconds: roundedElapsedTimeInSeconds,
        ),
        context);

    // CHECK IF DIAGNOSIS RESULT IS VALID AND GET DIAGNOSE STATUS
    if (diagnosis != null && diagnosis.prediction != null) {
      diagnoseStatus = diagnosis.prediction!;
    } else {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesResultError);
      return;
    }

    // UPDATE USER DISORDER STATUS IN THE DATABASE
    status = await _questionService.addDiagnosisResult(
        DiagnosisResult(
          userEmail: user.email,
          timeSeconds: roundedElapsedTimeInSeconds,
          q1: DiagnoseSequentialScreen.userResponses[0],
          q2: DiagnoseSequentialScreen.userResponses[1],
          q3: DiagnoseSequentialScreen.userResponses[2],
          q4: DiagnoseSequentialScreen.userResponses[3],
          q5: DiagnoseSequentialScreen.userResponses[4],
          totalScore: totalScore.toString(),
          label: diagnoseStatus,
        ),
        context);

    // UPDATE USER DISORDER TYPE IN THE SERVICE
    if (diagnoseStatus) {
      updateStatus = await _userService.updateDisorderType(
          DisorderTypes.sequential, accessToken, context);
    } else {
      updateStatus = await _userService.updateDisorderType(
          DisorderTypes.nonSequential, accessToken, context);
    }

    // NAVIGATE BASED ON THE STATUS OF UPDATES
    if (status && updateStatus) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        diagnoseResultRoute,
        (route) => false,
        arguments: {
          'diagnoseType': 'sequential',
          'totalScore': totalScore,
          'elapsedTime': roundedElapsedTimeInSeconds,
        },
      );
    } else {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesSomethingWrongError);
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

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // SET CUSTOM STATUS BAR COLOR
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        systemNavigationBarColor: Colors.black,
      ),
    );

    return PopScope(
      canPop: false, // CANPOP IS SET TO FALSE TO PREVENT POPPING THE ROUTE
      // CALLBACK WHEN BACK BUTTON IS PRESSED
      onPopInvoked: (didPop) {
        if (didPop) return; // PREVENT DEFAULT BACK NAVIGATION
        Navigator.of(context).pushNamed(mainDashboardRoute);
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
                  return Stack(
                    children: [
                      // SET BACKGROUND IMAGE
                      Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/diagnose_background_v1.png'),
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
                                  DiagnoseSequentialScreen.isDataLoading)
                              ? // SHOW LOADER WHILE WAITING FOR THE QUESTION TO LOAD
                              const Center(
                                  child: SpinKitCubeGrid(
                                    color: Colors.white,
                                    size: 80.0,
                                  ),
                                )
                              : (snapshot.hasError ||
                                      DiagnoseSequentialScreen.isErrorOccurred)
                                  ? // DISPLAY ERROR IF LOADING FAILED
                                  Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .commonMessagesLoadQuestion,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400),
                                      ),
                                    )
                                  // DISPLAY QUESTION INSTRUCTIONS
                                  : Column(
                                      children: [
                                        Text(
                                          DiagnoseSequentialScreen.question,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: DiagnoseSequentialScreen
                                                          .selectedLanguageCode ==
                                                      'ta'
                                                  ? 16
                                                  : 20,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400),
                                        ),
                                        const SizedBox(height: 48.0),
                                        // ANSWER OPTIONS
                                        AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          child: Row(
                                            key: ValueKey<int>(
                                              DiagnoseSequentialScreen
                                                  .currentQuestionNumber,
                                            ),
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: DiagnoseSequentialScreen
                                                .answers
                                                .map((answer) {
                                              return GestureDetector(
                                                onTap: () =>
                                                    _handleAnswer(answer),
                                                child: AnswerBox(
                                                  width: 60.0,
                                                  height: 60,
                                                  value: answer,
                                                  size: 24.0,
                                                ),
                                              );
                                            }).toList(),
                                          ),
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
}
