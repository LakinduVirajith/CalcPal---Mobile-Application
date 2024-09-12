import 'package:audioplayers/audioplayers.dart';
import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/enums/disorder_types.dart';
import 'package:calcpal/models/diagnosis.dart';
import 'package:calcpal/models/diagnosis_result.dart';
import 'package:calcpal/models/flask_diagnosis_result.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/models/verbal_question.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer;

class DiagnoseVerbalScreen extends StatefulWidget {
  const DiagnoseVerbalScreen({super.key});

  @override
  State<DiagnoseVerbalScreen> createState() => _DiagnoseVerbalScreenState();
}

class _DiagnoseVerbalScreenState extends State<DiagnoseVerbalScreen> {
  // VARIABLES TO HOLD QUESTION AND ANSWER DATA
  late BytesSource questionVoice;
  late String question;
  late List<String> answers;
  late String correctAnswer;

  List<bool> userResponses = [];
  int currentQuestionNumber = 1;
  String selectedLanguageCode = 'en';

  bool isAudioPlaying = false;
  bool isDataLoading = false;
  bool isErrorOccurred = false;

  // FUTURE THAT HOLDS THE STATE OF THE QUESTION LOADING PROCESS
  late Future<void> _questionFuture;

  // STOPWATCH INSTANCE FOR TIMING
  final Stopwatch _stopwatch = Stopwatch();

  // INITIALIZING AUDIO PLAYER
  final AudioPlayer _audioPlayer = AudioPlayer();

  // INITIALIZING SERVICEs
  final VerbalService _questionService = VerbalService();
  final UserService _userService = UserService();
  final ToastService _toastService = ToastService();
  final TextToSpeechService _textToSpeechService = TextToSpeechService();

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

  // FUNCTION TO LOAD AND PLAY QUESTION
  Future<void> _loadQuestion() async {
    try {
      setState(() {
        isErrorOccurred = false;
        isDataLoading = true;
      });

      VerbalQuestion? response = await _questionService.fetchQuestion(
          currentQuestionNumber,
          CommonService.getLanguageForAPI(selectedLanguageCode),
          context);

      if (response != null) {
        setState(() {
          question = response.question;
          answers = response.answers;
          answers.shuffle();
          correctAnswer = response.correctAnswer;
        });
        // DECODE BASE64 ENCODED QUESTION
        if (selectedLanguageCode != 'en') {
          setState(() => question = CommonService.decodeString(question));
        }

        // SYNTHESIZE SPEECH FOR THE QUESTION AND STORE THE AUDIO DATA
        questionVoice = await _textToSpeechService.synthesizeSpeech(
          question,
          CommonService.getLanguageCode(selectedLanguageCode),
        );

        await _toggleAudioPlayback();

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

  // FUNCTION TO TOGGLE AUDIO PLAYBACK
  Future<void> _toggleAudioPlayback() async {
    if (isAudioPlaying) {
      await _audioPlayer.stop();
    } else {
      await _audioPlayer.play(questionVoice);

      // SET PLAYBACK SPEED
      await _audioPlayer.setPlaybackRate(0.9);

      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() => isAudioPlaying = false);
      });
    }

    setState(() => isAudioPlaying = !isAudioPlaying);
  }

  // FUNCTION TO HANDLE USER ANSWERS
  Future<void> _handleAnswer(String userAnswer) async {
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
            DisorderTypes.verbal, accessToken, context);
      } else {
        updateStatus = await _userService.updateDisorderType(
            DisorderTypes.nonVerbal, accessToken, context);
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
                                            fontSize: 20,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400),
                                      ),
                                    )
                                  // DISPLAY QUESTION INSTRUCTIONS
                                  : Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .diagnoseVerbalMessagesListenAndAnswer,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  selectedLanguageCode == 'ta'
                                                      ? 16
                                                      : 20,
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
                                              isAudioPlaying,
                                            ),
                                            onTap: _toggleAudioPlayback,
                                            child: Opacity(
                                              opacity: 0.65,
                                              child: Container(
                                                height: 70,
                                                width: 125,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(18.0),
                                                  ),
                                                ),
                                                child: SvgPicture.asset(
                                                  isAudioPlaying
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
                                              currentQuestionNumber,
                                            ),
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: answers.map((answer) {
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
