import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/enums/disorder_types.dart';
import 'package:calcpal/models/diagnosis.dart';
import 'package:calcpal/models/diagnosis_result.dart';
import 'package:calcpal/models/flask_diagnosis_result.dart';
import 'package:calcpal/models/lexical_question.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:calcpal/services/lexical_service.dart';
import 'package:calcpal/services/speech_to_text_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:calcpal/widgets/answer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer;

class DiagnoseLexicalScreen extends StatefulWidget {
  const DiagnoseLexicalScreen({super.key});

  @override
  State<DiagnoseLexicalScreen> createState() => _DiagnoseLexicalScreenState();
}

class _DiagnoseLexicalScreenState extends State<DiagnoseLexicalScreen> {
  // VARIABLES TO HOLD QUESTION AND ANSWER DATA
  late String question;
  late List<String> answers;

  List<bool> userResponses = [];
  int currentQuestionNumber = 1;
  String selectedLanguageCode = 'en';

  bool isMicrophoneOn = false;
  bool isDataLoading = false;
  bool isErrorOccurred = false;

  // FUTURE THAT HOLDS THE STATE OF THE QUESTION LOADING PROCESS
  late Future<void> _questionFuture;

  // COUNTER TO TRACK THE NUMBER OF VOICE ATTEMPTS
  int _voiceAttempt = 1;

  // STOPWATCH INSTANCE FOR TIMING
  final Stopwatch _stopwatch = Stopwatch();

  // INITIALIZING SERVICEs
  final LexicalService _questionService = LexicalService();
  final UserService _userService = UserService();
  final SpeechToTextService _speechService = SpeechToTextService();
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

    // LOAD THE FIRST QUESTION WHEN THE WIDGET IS INITIALIZED
    _setupLanguage();
    _questionFuture = _loadQuestion();
  }

  @override
  void dispose() {
    super.dispose();

    currentQuestionNumber = 1;
    userResponses = [];
    _stopwatch.reset();
  }

  // FUNCTION TO SET THE SELECTED LANGUAGE BASED ON THE STORED LANGUAGE CODE
  Future<void> _setupLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    selectedLanguageCode = languageCode;
  }

  // FUNCTION TO LOAD THE QUESTION
  Future<void> _loadQuestion() async {
    try {
      setState(() {
        isErrorOccurred = false;
        isDataLoading = true;
      });

      LexicalQuestion? response =
          await _questionService.fetchQuestion(currentQuestionNumber, context);

      if (response != null) {
        setState(() {
          question = response.question;
          answers = response.answers;
        });
        // DECODE BASE64 ENCODED ANSWERS
        setState(() {
          answers[2] = CommonService.decodeString(answers[2]);
          answers[3] = CommonService.decodeString(answers[3]);
        });
        // AWAIT THE ASYNCHRONOUS OPERATION TO CAPTURE THE USER'S VOICE
        _voiceAttempt = 1;
        await _captureVoice();

        // START THE STOPWATCH FOR THE FIRST QUESTION ONLY
        if (currentQuestionNumber == 1) {
          _stopwatch.start();
        }
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

  // FUNCTION TO HANDLE VOICE CAPTURE
  Future<void> _captureVoice() async {
    // CHECK AND REQUEST MICROPHONE PERMISSION
    bool isPermissionGranted =
        await _speechService.checkAndRequestMicrophonePermission();
    if (!isPermissionGranted) {
      _toastService.errorToast(
          AppLocalizations.of(context)!.commonLexicalMessagesToProceedError);
      return;
    }

    // TOGGLE MICROPHONE STATE
    setState(() => isMicrophoneOn = true);

    // INITIALIZE THE SPEECH TO TEXT SERVICE
    bool isInitialized = await _speechService.initializeSpeechToText(
      onError: (error) {
        setState(() => isMicrophoneOn = false);
        _toastService.infoToast(
            AppLocalizations.of(context)!.commonLexicalMessagesNoSpeechError);
        developer.log('Error: $error');
      },
      onStatus: (status) => developer.log('Status: $status'),
    );

    if (isInitialized) {
      // SET LOCALEID BASED ON SELECTED LANGUAGE
      String localeId = CommonService.getLanguageCode(
        selectedLanguageCode,
      );

      // START LISTENING FOR SPEECH INPUT
      _speechService.startListening(
          localeId: localeId,
          onResult: (recognizedWords) async {
            if (recognizedWords.isNotEmpty) {
              developer.log('recognizedWord: $recognizedWords');

              // COMPARE RECOGNIZED WORDS WITH THE EXPECTED
              bool isCorrectAnswer = answers.any((answer) =>
                  recognizedWords.toLowerCase().trim() ==
                  answer.toLowerCase().trim());

              // HANDLE RESPONSE BASED ON ATTEMPT
              if (_voiceAttempt == 1 && !isCorrectAnswer) {
                _toastService.errorToast(AppLocalizations.of(context)!
                    .diagnoseLexicalMessagesDidntRightError);
                _voiceAttempt = 2;
                await _captureVoice(); // RETRY ON FAILURE
              } else {
                userResponses.insert(
                    currentQuestionNumber - 1, isCorrectAnswer);

                // CHECK IF THERE ARE MORE QUESTIONS LEFT
                if (currentQuestionNumber < 5) {
                  currentQuestionNumber++;
                  await _loadQuestion();
                } else {
                  await _submitResultsToMLModel();
                }
              }
            }
          },
          onDone: () async {
            setState(() => isMicrophoneOn = false);
          });
    } else {
      _toastService.errorToast(AppLocalizations.of(context)!
          .commonLexicalMessagesFailedToInitializeError);
      setState(() => isMicrophoneOn = false);
    }
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

      // ROUND TO THE NEAREST WHOLE SECOND
      final roundedElapsedTimeInSeconds = elapsedTimeInSeconds.round();

      // CALCULATE THE TOTAL SCORE BASED ON TRUE RESPONSES
      final int totalScore = userResponses.where((response) => response).length;

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
            DisorderTypes.lexical, accessToken, context);
      } else {
        updateStatus = await _userService.updateDisorderType(
            DisorderTypes.nonLexical, accessToken, context);
      }

      // NAVIGATE BASED ON THE STATUS OF UPDATES
      if (status && updateStatus) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          diagnoseResultRoute,
          (route) => false,
          arguments: {
            'diagnoseType': 'lexical',
            'totalScore': totalScore,
            'elapsedTime': roundedElapsedTimeInSeconds,
          },
        );
      } else {
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
    // DISPLAY WARNING MESSAGE
    _toastService.warningToast(message);

    // REDIRECT TO LOGIN PAGE
    Navigator.of(context).pushNamedAndRemoveUntil(
      loginRoute,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                                'assets/images/diagnose_background_v2.png'),
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
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .diagnoseLexicalMessagesReadTheNumber,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24.0),
                                        // QUESTION NUMBER
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            AnswerBox(
                                              width: 160.0,
                                              height: 160.0,
                                              value: question,
                                              size: 64.0,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                      Positioned(
                        top: constraints.maxHeight * 0.7,
                        right: constraints.maxWidth * 0.25,
                        left: constraints.maxWidth * 0.6,
                        bottom: constraints.maxHeight * 0.15,
                        child: (snapshot.hasError || isErrorOccurred)
                            ? Container()
                            : AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: GestureDetector(
                                  key: ValueKey<bool>(
                                    isMicrophoneOn,
                                  ),
                                  onTap: _captureVoice,
                                  child: Opacity(
                                    opacity: 0.65,
                                    child: Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        color: isMicrophoneOn
                                            ? Colors.black
                                            : Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: isMicrophoneOn
                                          ? Image.asset(
                                              'assets/icons/sound-wave.gif',
                                              fit: BoxFit.contain,
                                            )
                                          : SvgPicture.asset(
                                              'assets/icons/microphone.svg',
                                              semanticsLabel: 'microphone icon',
                                            ),
                                    ),
                                  ),
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
