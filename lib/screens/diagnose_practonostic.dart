import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/enums/disorder_types.dart';
import 'package:calcpal/models/diagnosis.dart';
import 'package:calcpal/models/diagnosis_result.dart';
import 'package:calcpal/models/flask_diagnosis_result.dart';
import 'package:calcpal/models/practognotic_question.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:calcpal/services/practognostic_service.dart';
import 'package:calcpal/widgets/answer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer;

class DiagnosePractonosticScreen extends StatefulWidget {
  const DiagnosePractonosticScreen({super.key});

  @override
  State<DiagnosePractonosticScreen> createState() =>
      _DiagnosePractonosticScreenState();
}

class _DiagnosePractonosticScreenState
    extends State<DiagnosePractonosticScreen> {
  String selectedLanguageCode = 'en-US';
  int currentQuestionNumber = 1;
  late String question;
  late List<String> answers;
  late String correctAnswer;
  late String imageType;
  late String questionText;
  final Stopwatch _stopwatch = Stopwatch();
  late Future<void> _questionFuture;
  static bool isErrorOccurred = false;
  static List<bool> userResponses = [];
  static bool isDataLoading = false;

  @override
  void initState() {
    super.initState();
    _setupLanguage();
    // LOAD THE FIRST QUESTION WHEN THE WIDGET IS INITIALIZED
    _questionFuture = _loadQuestion();
  }

  @override
  void dispose() {
    super.dispose();
    userResponses = [];
  }

// INITIALIZING THE USER SERVICE
  final UserService _userService = UserService();
  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();
  // INITIALIZING THE VERBAL SERVICE
  final PractognosticService _questionService = PractognosticService();

  // FUNCTION TO SET THE SELECTED LANGUAGE BASED ON THE STORED LANGUAGE CODE
  Future<void> _setupLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    print(languageCode);
    selectedLanguageCode = languageCode;
  }

  // FUNCTION TO LOAD AND PLAY QUESTION
  Future<void> _loadQuestion() async {
    try {
      setState(() {
        isErrorOccurred = false;
        isDataLoading = true;
      });
      await Future.delayed(const Duration(milliseconds: 200));
      PractognosticQuestion? practoQuestion =
          await _questionService.fetchQuestion(currentQuestionNumber,
              CommonService.getLanguageForAPI(selectedLanguageCode), context);
      if (practoQuestion != null) {
        setState(() {
          question = practoQuestion.question;
          answers = practoQuestion.answers;
          correctAnswer = practoQuestion.correctAnswer;
          if (practoQuestion.imageType != null) {
            imageType = practoQuestion.imageType!;
          }
          if (practoQuestion.questionText != null) {
            questionText = practoQuestion.questionText!;
          }

          // DECODE BASE64 ENCODED QUESTION
          if (selectedLanguageCode != 'en') {
            setState(() => question = CommonService.decodeString(question));
            setState(
                () => questionText = CommonService.decodeString(questionText));
            setState(() => answers = CommonService.decodeList(answers));
          }

          if (currentQuestionNumber == 1) {
            _stopwatch.start();
          }
        });
      } else {
        setState(() {
          isErrorOccurred = true;
          isDataLoading = false;
        });
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

  Future<void> _handleAnswer(String userAnswer) async {
    developer.log("handle answer call");
    print(userAnswer);
    print(correctAnswer);
    // CHECK IF THE USER'S ANSWER IS CORRECT
    if (userAnswer == correctAnswer) {
      userResponses.insert(currentQuestionNumber - 1, true);
    } else {
      userResponses.insert(currentQuestionNumber - 1, false);
    }

    // CHECK IF THERE ARE MORE QUESTIONS LEFT
    if (currentQuestionNumber != 5) {
      currentQuestionNumber++;
      _loadQuestion();
    } else {
      _submitResultsToMLModel();
    }
  }

  Future<void> _submitResultsToMLModel() async {
    print(userResponses);
    // STOP THE TIMER AND RECORD ELAPSED TIME IN SECONDS
    _stopwatch.stop();
    final elapsedTimeInSeconds = _stopwatch.elapsedMilliseconds / 1000;
    final roundedElapsedTimeInSeconds = elapsedTimeInSeconds.round();

    // CALCULATE THE TOTAL SCORE BASED ON TRUE RESPONSES
    final int totalScore = userResponses.where((response) => response).length;

    // GET THE INSTANCE OF SHARED PREFERENCES
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    print(accessToken);

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
          q1: userResponses[0] ? 1 : 0,
          q2: userResponses[1] ? 1 : 0,
          q3: userResponses[2] ? 1 : 0,
          q4: userResponses[3] ? 1 : 0,
          q5: userResponses[4] ? 1 : 0,
          seconds: roundedElapsedTimeInSeconds,
        ),
        context);
    print("Q1: ${userResponses[0]}");
    print("Q2: ${userResponses[1]}");
    print("Q3: ${userResponses[2]}");
    print("Q4: ${userResponses[3]}");
    print("Q5: ${userResponses[4]}");
    print("prediction: ${diagnosis?.prediction}");
    print("Message: ${diagnosis?.message}");

    // CHECK IF DIAGNOSIS RESULT IS VALID AND GET DIAGNOSE STATUS
    if (diagnosis != null && diagnosis.prediction != null) {
      diagnoseStatus = diagnosis.prediction!;
      print(diagnoseStatus);
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
      print("practo");
      updateStatus = await _userService.updateDisorderType(
          DisorderTypes.practognostic, accessToken, context);
    } else {
      updateStatus = await _userService.updateDisorderType(
          DisorderTypes.nonPractognostic, accessToken, context);
    }

    // NAVIGATE BASED ON THE STATUS OF UPDATES
    if (status && updateStatus) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        diagnoseResultRoute,
        (route) => false,
        arguments: {
          'diagnoseType': 'practognostic',
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

    return Scaffold(
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
                      right: constraints.maxWidth * 0.12,
                      left: constraints.maxWidth * 0.12,
                      bottom: constraints.maxHeight * 0.1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 36.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(96, 96, 96, 0.5),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                isDataLoading)
                            ? // SHOW LOADER WHILE WAITING FOR THE QUESTION TO LOAD
                            const Center(
                                child: SpinKitCubeGrid(
                                  color: Colors.white,
                                  size: 80.0,
                                ),
                              )
                            : (snapshot.hasError || isErrorOccurred)
                                ? // DISPLAY ERROR IF LOADING FAILED
                                Center(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .commonMessagesLoadQuestion,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w400),
                                    ),
                                  )
                                // DISPLAY QUESTION INSTRUCTIONS
                                : Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            question,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),

                                      questionText != ""
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  questionText,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (currentQuestionNumber == 3)
                                                  Image.asset(
                                                    'assets/images/practoq3.png',
                                                    height: 150.0,
                                                  ),
                                                if (currentQuestionNumber == 4)
                                                  Image.asset(
                                                    'assets/images/practoq4.png',
                                                    height: 150.0,
                                                  ),
                                                if (currentQuestionNumber == 5)
                                                  Image.asset(
                                                    'assets/images/practoq5.png',
                                                    height: 150.0,
                                                  ),
                                              ],
                                            ),
                                      const SizedBox(height: 12.0),
                                      // ANSWER OPTIONS
                                      AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: Row(
                                          key: ValueKey<int>(
                                            currentQuestionNumber,
                                          ),
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: answers.map((answer) {
                                            return GestureDetector(
                                              onTap: () =>
                                                  _handleAnswer(answer),
                                              child: AnswerBox(
                                                width: 150.0,
                                                height: 60,
                                                value: answer,
                                                size: 18.0,
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
    );
  }
}
