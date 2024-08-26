import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/enums/disorder.dart';
import 'package:calcpal/models/diagnosis.dart';
import 'package:calcpal/models/diagnosis_result.dart';
import 'package:calcpal/models/flask_diagnosis_result.dart';
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
import 'dart:developer' as developer;

class DiagnoseLexicalScreen extends StatefulWidget {
  const DiagnoseLexicalScreen({super.key});

  static late String question;
  static late List<String> answers;

  static List<bool> userResponses = [];
  static int currentQuestionNumber = 1;
  static String selectedLanguage = 'English';

  static bool isMicrophoneOn = false;
  static bool isErrorOccurred = false;

  @override
  State<DiagnoseLexicalScreen> createState() => _DiagnoseLexicalScreenState();
}

class _DiagnoseLexicalScreenState extends State<DiagnoseLexicalScreen> {
  // FUTURE THAT HOLDS THE STATE OF THE QUESTION LOADING PROCESS
  late Future<void> _questionFuture;
  // VARIABLE TO STORE THE LAST RECOGNIZED WORD TO AVOID DUPLICATES
  String _previousRecognizedWord = '';
  // COUNTER TO TRACK THE NUMBER OF VOICE ATTEMPTS
  int _voiceAttempt = 1;

  // INITIALIZING THE VERBAL SERVICE
  final LexicalService _questionService = LexicalService();
  // INITIALIZING THE USER SERVICE
  final UserService _userService = UserService();
  // STOPWATCH INSTANCE FOR TIMING
  final Stopwatch _stopwatch = Stopwatch();

  // INITIALIZING SPEECH-TO-TEXT SERVICE
  final SpeechToTextService _speechService = SpeechToTextService();
  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

  @override
  void initState() {
    super.initState();
    // LOAD THE FIRST QUESTION WHEN THE WIDGET IS INITIALIZED
    _questionFuture = _loadQuestion();
  }

  @override
  void dispose() {
    DiagnoseLexicalScreen.currentQuestionNumber = 1;
    _stopwatch.reset();
    super.dispose();
  }

  // FUNCTION TO LOAD THE QUESTION
  Future<void> _loadQuestion() async {
    try {
      final question = await _questionService.fetchQuestion(
        DiagnoseLexicalScreen.currentQuestionNumber,
      );

      if (question != null) {
        setState(() {
          DiagnoseLexicalScreen.question = question.question;
          DiagnoseLexicalScreen.answers = question.answers;
        });
        // AWAIT THE ASYNCHRONOUS OPERATION TO CAPTURE THE USER'S VOICE
        _voiceAttempt = 1;
        await _captureVoice();

        // START THE STOPWATCH FOR THE FIRST QUESTION ONLY
        if (DiagnoseLexicalScreen.currentQuestionNumber == 1) {
          _stopwatch.start();
        }
      } else {
        setState(() => DiagnoseLexicalScreen.isErrorOccurred = true);
      }
    } catch (e) {
      setState(() => DiagnoseLexicalScreen.isErrorOccurred = true);
    }
  }

  // FUNCTION TO HANDLE VOICE CAPTURE
  Future<void> _captureVoice() async {
    // CHECK AND REQUEST MICROPHONE PERMISSION
    bool isPermissionGranted =
        await _speechService.checkAndRequestMicrophonePermission();
    if (!isPermissionGranted) {
      _toastService.errorToast('To proceed, please allow microphone access.');
      return;
    }

    // TOGGLE MICROPHONE STATE
    setState(() => DiagnoseLexicalScreen.isMicrophoneOn = true);

    // INITIALIZE THE SPEECH TO TEXT SERVICE
    bool isInitialized = await _speechService.initializeSpeechToText(
      onError: (error) {
        setState(() => DiagnoseLexicalScreen.isMicrophoneOn = false);
        _toastService.infoToast("No speech detected. Let's try that again!");
        developer.log('Error: $error');
      },
      onStatus: (status) => developer.log('Status: $status'),
    );

    if (isInitialized) {
      // SET LOCALEID BASED ON SELECTED LANGUAGE
      String localeId = CommonService.getLanguageCode(
        DiagnoseLexicalScreen.selectedLanguage,
      );

      // START LISTENING FOR SPEECH INPUT
      _speechService.startListening(
        localeId: localeId,
        onResult: (recognizedWords) async {
          String recognizedWord = recognizedWords.split(' ').first;

          // STOP LISTENING
          await _speechService.stopListening();
          setState(() => DiagnoseLexicalScreen.isMicrophoneOn = false);

          if (recognizedWord.isNotEmpty &&
              recognizedWord != _previousRecognizedWord) {
            // UPDATE THE PREVIOUS RECOGNIZED WORD
            _previousRecognizedWord = recognizedWord;

            // COMPARE RECOGNIZED WORDS WITH THE EXPECTED
            bool isCorrectAnswer = DiagnoseLexicalScreen.answers.any((answer) =>
                recognizedWord.toLowerCase().trim() ==
                answer.toLowerCase().trim());

            // HANDLE RESPONSE BASED ON ATTEMPT
            if (_voiceAttempt == 1 && !isCorrectAnswer) {
              _toastService.errorToast(
                  "That didn't seem right. Please try saying it again.");
              _voiceAttempt = 2;
              await _captureVoice(); // RETRY ON FAILURE
            } else {
              DiagnoseLexicalScreen.userResponses.add(isCorrectAnswer);

              // CHECK IF THERE ARE MORE QUESTIONS LEFT
              if (DiagnoseLexicalScreen.currentQuestionNumber < 5) {
                DiagnoseLexicalScreen.currentQuestionNumber++;
                await _loadQuestion();
              } else {
                await _submitResultsToMLModel();
              }
            }
          }
        },
      );
    } else {
      _toastService.errorToast(
          'Failed to initialize the voice recognition service. Please try again.');
      setState(() => DiagnoseLexicalScreen.isMicrophoneOn = false);
    }
  }

  // FUNCTION TO SUBMIT RESULTS TO MACHINE LEARNING MODEL
  Future<void> _submitResultsToMLModel() async {
    // STOP THE TIMER AND RECORD ELAPSED TIME IN SECONDS
    _stopwatch.stop();
    final elapsedTimeInSeconds = _stopwatch.elapsedMilliseconds / 1000;

    // ROUND TO THE NEAREST WHOLE SECOND
    final roundedElapsedTimeInSeconds = elapsedTimeInSeconds.round();

    // CALCULATE THE TOTAL SCORE BASED ON TRUE RESPONSES
    final int totalScore = DiagnoseLexicalScreen.userResponses
        .where((response) => response)
        .length;

    // GET THE INSTANCE OF SHARED PREFERENCES
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    // CHECK IF ACCESS TOKEN IS AVAILABLE
    if (accessToken == null) {
      _handleErrorAndRedirect('Access token not available. Please log in.');
      return;
    }

    // FETCH USER INFO
    User? user = await _userService.getUser(accessToken);

    // CHECK IF USER AND IQ SCORE ARE AVAILABLE
    if (user == null || user.iqScore == null) {
      _handleErrorAndRedirect(
          'User information or IQ score not available. Please log in.');
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
        q1: DiagnoseLexicalScreen.userResponses[0] ? 1 : 0,
        q2: DiagnoseLexicalScreen.userResponses[1] ? 1 : 0,
        q3: DiagnoseLexicalScreen.userResponses[2] ? 1 : 0,
        q4: DiagnoseLexicalScreen.userResponses[3] ? 1 : 0,
        q5: DiagnoseLexicalScreen.userResponses[4] ? 1 : 0,
        seconds: roundedElapsedTimeInSeconds,
      ),
    );

    // CHECK IF DIAGNOSIS RESULT IS VALID AND GET DIAGNOSE STATUS
    if (diagnosis != null && diagnosis.prediction != null) {
      diagnoseStatus = diagnosis.prediction!;
    } else {
      _handleErrorAndRedirect(
          'Something went wrong. Please log in to your account.');
      return;
    }

    // UPDATE USER DISORDER STATUS IN THE DATABASE
    status = await _questionService.addDiagnosisResult(
      DiagnosisResult(
        userEmail: user.email,
        timeSeconds: roundedElapsedTimeInSeconds,
        q1: DiagnoseLexicalScreen.userResponses[0],
        q2: DiagnoseLexicalScreen.userResponses[1],
        q3: DiagnoseLexicalScreen.userResponses[2],
        q4: DiagnoseLexicalScreen.userResponses[3],
        q5: DiagnoseLexicalScreen.userResponses[4],
        totalScore: totalScore.toString(),
        label: diagnoseStatus,
      ),
    );

    // UPDATE USER DISORDER TYPE IN THE SERVICE
    if (diagnoseStatus) {
      updateStatus = await _userService.updateDisorderType(
        Disorder.lexical,
        accessToken,
      );
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
          'Something went wrong. Please log in to your account.');
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
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: SafeArea(
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
                                ConnectionState.waiting)
                            ? // SHOW LOADER WHILE WAITING FOR THE QUESTION TO LOAD
                            const Center(
                                child: SpinKitCubeGrid(
                                  color: Colors.white,
                                  size: 80.0,
                                ),
                              )
                            : (snapshot.hasError ||
                                    DiagnoseLexicalScreen.isErrorOccurred)
                                ? // DISPLAY ERROR IF LOADING FAILED
                                Center(
                                    child: Text(
                                      DiagnoseLexicalScreen.selectedLanguage ==
                                              'English'
                                          ? 'Failed to load question. Please try again.'
                                          : DiagnoseLexicalScreen
                                                      .selectedLanguage ==
                                                  'Sinhala'
                                              ? 'ප්‍රශ්නය පූරණය කිරීමට අසමත් විය. කරුණාකර නැවත උත්සාහ කරන්න.'
                                              : DiagnoseLexicalScreen
                                                          .selectedLanguage ==
                                                      'Tamil'
                                                  ? 'கேள்வியை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.'
                                                  : 'Listen and answer the question',
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
                                            DiagnoseLexicalScreen
                                                        .selectedLanguage ==
                                                    'English'
                                                ? 'Read the number out loud.'
                                                : DiagnoseLexicalScreen
                                                            .selectedLanguage ==
                                                        'Sinhala'
                                                    ? 'අංකය ශබ්ද නඟා කියවන්න.'
                                                    : DiagnoseLexicalScreen
                                                                .selectedLanguage ==
                                                            'Tamil'
                                                        ? 'எண்ணை சத்தமாகப் படியுங்கள்.'
                                                        : 'Read the number out loud',
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
                                            value:
                                                DiagnoseLexicalScreen.question,
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
                      child: (snapshot.hasError ||
                              DiagnoseLexicalScreen.isErrorOccurred)
                          ? Container()
                          : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: GestureDetector(
                                key: ValueKey<bool>(
                                  DiagnoseLexicalScreen.isMicrophoneOn,
                                ),
                                onTap: _captureVoice,
                                child: Opacity(
                                  opacity: 0.65,
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      DiagnoseLexicalScreen.isMicrophoneOn
                                          ? 'assets/icons/microphone-radio.svg'
                                          : 'assets/icons/microphone.svg',
                                      semanticsLabel: 'Microphone Icon',
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
    );
  }
}
