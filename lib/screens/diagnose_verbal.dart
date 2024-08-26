import 'package:audioplayers/audioplayers.dart';
import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/enums/disorder.dart';
import 'package:calcpal/models/diagnosis.dart';
import 'package:calcpal/models/diagnosis_result.dart';
import 'package:calcpal/models/flask_diagnosis_result.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:calcpal/services/text_to_speech_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:calcpal/services/verbal_service.dart';
import 'package:calcpal/widgets/answer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiagnoseVerbalScreen extends StatefulWidget {
  const DiagnoseVerbalScreen({super.key});

  static late BytesSource questionVoice;
  static late String question;
  static late List<String> answers;
  static late String correctAnswer;

  static List<bool> userResponses = [];
  static int currentQuestionNumber = 1;
  static String selectedLanguage = 'English';

  static bool isAudioPlaying = false;
  static bool isDataLoading = false;
  static bool isErrorOccurred = false;

  @override
  State<DiagnoseVerbalScreen> createState() => _DiagnoseVerbalScreenState();
}

class _DiagnoseVerbalScreenState extends State<DiagnoseVerbalScreen> {
  // FUTURE THAT HOLDS THE STATE OF THE QUESTION LOADING PROCESS
  late Future<void> _questionFuture;

  // INITIALIZING THE VERBAL SERVICE
  final VerbalService _questionService = VerbalService();
  // INITIALIZING THE USER SERVICE
  final UserService _userService = UserService();
  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();
  // STOPWATCH INSTANCE FOR TIMING
  final Stopwatch _stopwatch = Stopwatch();

  // INITIALIZING TEXT-TO-SPEECH SERVICE
  final TextToSpeechService _textToSpeechService = TextToSpeechService();
  // INITIALIZING AUDIO PLAYER
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // LOAD THE FIRST QUESTION WHEN THE WIDGET IS INITIALIZED
    _questionFuture = _loadQuestion();
  }

  @override
  void dispose() {
    DiagnoseVerbalScreen.currentQuestionNumber = 1;
    _stopwatch.reset();
    super.dispose();
  }

  // FUNCTION TO LOAD AND PLAY QUESTION
  Future<void> _loadQuestion() async {
    try {
      setState(() {
        DiagnoseVerbalScreen.isErrorOccurred = false;
        DiagnoseVerbalScreen.isDataLoading = true;
      });

      final question = await _questionService.fetchQuestion(
        DiagnoseVerbalScreen.currentQuestionNumber,
        DiagnoseVerbalScreen.selectedLanguage,
      );

      if (question != null) {
        setState(() {
          DiagnoseVerbalScreen.question = question.question;
          DiagnoseVerbalScreen.answers = question.answers;
          DiagnoseVerbalScreen.answers.shuffle();
          DiagnoseVerbalScreen.correctAnswer = question.correctAnswer;
        });

        // SYNTHESIZE SPEECH FOR THE QUESTION AND STORE THE AUDIO DATA
        DiagnoseVerbalScreen.questionVoice =
            await _textToSpeechService.synthesizeSpeech(
          DiagnoseVerbalScreen.question,
          CommonService.getLanguageCode(
            DiagnoseVerbalScreen.selectedLanguage,
          ),
        );

        await _toggleAudioPlayback();

        // START THE STOPWATCH FOR THE FIRST QUESTION ONLY
        if (DiagnoseVerbalScreen.currentQuestionNumber == 1) {
          _stopwatch.start();
        }
      } else {
        setState(() {
          DiagnoseVerbalScreen.isErrorOccurred = true;
          DiagnoseVerbalScreen.isDataLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        DiagnoseVerbalScreen.isErrorOccurred = true;
        DiagnoseVerbalScreen.isDataLoading = false;
      });
    } finally {
      setState(() => DiagnoseVerbalScreen.isDataLoading = false);
    }
  }

  // FUNCTION TO TOGGLE AUDIO PLAYBACK
  Future<void> _toggleAudioPlayback() async {
    if (DiagnoseVerbalScreen.isAudioPlaying) {
      await _audioPlayer.stop();
    } else {
      await _audioPlayer.play(DiagnoseVerbalScreen.questionVoice);

      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() => DiagnoseVerbalScreen.isAudioPlaying = false);
      });
    }

    setState(() => DiagnoseVerbalScreen.isAudioPlaying =
        !DiagnoseVerbalScreen.isAudioPlaying);
  }

  // FUNCTION TO HANDLE USER ANSWERS
  Future<void> _handleAnswer(String userAnswer) async {
    // CHECK IF THE USER'S ANSWER IS CORRECT
    if (userAnswer == DiagnoseVerbalScreen.correctAnswer) {
      DiagnoseVerbalScreen.userResponses.add(true);
    } else {
      DiagnoseVerbalScreen.userResponses.add(false);
    }

    // CHECK IF THERE ARE MORE QUESTIONS LEFT
    if (DiagnoseVerbalScreen.currentQuestionNumber != 5) {
      DiagnoseVerbalScreen.currentQuestionNumber++;
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
    final int totalScore =
        DiagnoseVerbalScreen.userResponses.where((response) => response).length;

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
        q1: DiagnoseVerbalScreen.userResponses[0] ? 1 : 0,
        q2: DiagnoseVerbalScreen.userResponses[1] ? 1 : 0,
        q3: DiagnoseVerbalScreen.userResponses[2] ? 1 : 0,
        q4: DiagnoseVerbalScreen.userResponses[3] ? 1 : 0,
        q5: DiagnoseVerbalScreen.userResponses[4] ? 1 : 0,
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
        q1: DiagnoseVerbalScreen.userResponses[0],
        q2: DiagnoseVerbalScreen.userResponses[1],
        q3: DiagnoseVerbalScreen.userResponses[2],
        q4: DiagnoseVerbalScreen.userResponses[3],
        q5: DiagnoseVerbalScreen.userResponses[4],
        totalScore: totalScore.toString(),
        label: diagnoseStatus,
      ),
    );

    // UPDATE USER DISORDER TYPE IN THE SERVICE
    if (diagnoseStatus) {
      updateStatus = await _userService.updateDisorderType(
        Disorder.verbal,
        accessToken,
      );
    }

    // NAVIGATE BASED ON THE STATUS OF UPDATES
    if (status && updateStatus) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        diagnoseResultRoute,
        (route) => false,
        arguments: {
          'diagnoseType': 'verbal',
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
                                DiagnoseVerbalScreen.isDataLoading)
                            ? // SHOW LOADER WHILE WAITING FOR THE QUESTION TO LOAD
                            const Center(
                                child: SpinKitCubeGrid(
                                  color: Colors.white,
                                  size: 80.0,
                                ),
                              )
                            : (snapshot.hasError ||
                                    DiagnoseVerbalScreen.isErrorOccurred)
                                ? // DISPLAY ERROR IF LOADING FAILED
                                Center(
                                    child: Text(
                                      DiagnoseVerbalScreen.selectedLanguage ==
                                              'English'
                                          ? 'Failed to load question. Please try again.'
                                          : DiagnoseVerbalScreen
                                                      .selectedLanguage ==
                                                  'Sinhala'
                                              ? 'ප්‍රශ්නය පූරණය කිරීමට අසමත් විය. කරුණාකර නැවත උත්සාහ කරන්න.'
                                              : DiagnoseVerbalScreen
                                                          .selectedLanguage ==
                                                      'Tamil'
                                                  ? 'கேள்வியை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.'
                                                  : 'Failed to load question. Please try again.',
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
                                        DiagnoseVerbalScreen.selectedLanguage ==
                                                'English'
                                            ? 'Listen and answer the question'
                                            : DiagnoseVerbalScreen
                                                        .selectedLanguage ==
                                                    'Sinhala'
                                                ? 'ප්‍රශ්නයට සවන් දී පිළිතුරු දෙන්න.'
                                                : DiagnoseVerbalScreen
                                                            .selectedLanguage ==
                                                        'Tamil'
                                                    ? 'கேள்வியைக் கேட்டு பதில் சொல்லுங்கள்.'
                                                    : 'Listen and answer the question',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400),
                                      ),
                                      const SizedBox(height: 24.0),
                                      // PLAY AUDIO BUTTON
                                      AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: GestureDetector(
                                          key: ValueKey<bool>(
                                            DiagnoseVerbalScreen.isAudioPlaying,
                                          ),
                                          onTap: _toggleAudioPlayback,
                                          child: Opacity(
                                            opacity: 0.65,
                                            child: Container(
                                              height: 70,
                                              width: 125,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(18.0),
                                                ),
                                              ),
                                              child: SvgPicture.asset(
                                                DiagnoseVerbalScreen
                                                        .isAudioPlaying
                                                    ? 'assets/icons/pause-button.svg'
                                                    : 'assets/icons/play-button.svg',
                                                semanticsLabel: 'Play Icon',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 48.0),
                                      // ANSWER OPTIONS
                                      AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: Row(
                                          key: ValueKey<int>(
                                            DiagnoseVerbalScreen
                                                .currentQuestionNumber,
                                          ),
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: DiagnoseVerbalScreen.answers
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
    );
  }
}
