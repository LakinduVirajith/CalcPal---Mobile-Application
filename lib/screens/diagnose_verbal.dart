import 'package:calcpal/services/verbal_service.dart';
import 'package:calcpal/widgets/answer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DiagnoseVerbalScreen extends StatefulWidget {
  const DiagnoseVerbalScreen({super.key});

  static late String question;
  static late List<String> answers;
  static late String correctAnswer;

  static List<bool> userResponses = [];
  static int currentQuestionNumber = 1;
  static String selectedLanguage = 'English';

  static bool isAudioPlaying = false;
  static bool isDataLoaded = false;

  @override
  State<DiagnoseVerbalScreen> createState() => _DiagnoseVerbalScreenState();
}

class _DiagnoseVerbalScreenState extends State<DiagnoseVerbalScreen> {
  // INITIALIZING TEXT-TO-SPEECH
  final FlutterTts flutterTts = FlutterTts();
  // INITIALIZING THE VERBAL SERVICE
  final VerbalService questionService = VerbalService();
  // FUTURE THAT HOLDS THE STATE OF THE QUESTION LOADING PROCESS
  late Future<void> _questionFuture;
  // STOPWATCH INSTANCE FOR TIMING
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    // INITIALIZE TTS WITH LANGUAGE SETTINGS
    _initializeTtsLanguage();
    // LOAD THE FIRST QUESTION WHEN THE WIDGET IS INITIALIZED
    _questionFuture = _loadQuestion();
  }

  @override
  void dispose() {
    DiagnoseVerbalScreen.currentQuestionNumber = 1;
    DiagnoseVerbalScreen.isAudioPlaying = false;
    _stopwatch.reset();
    super.dispose();
  }

  // FUNCTION TO SET LANGUAGE CODE BASED ON SELECTED LANGUAGE
  Future<void> _initializeTtsLanguage() async {
    String languageCode;

    switch (DiagnoseVerbalScreen.selectedLanguage) {
      case 'English':
        languageCode = 'en';
        break;
      case 'Sinhala':
        languageCode = 'si';
        break;
      case 'Tamil':
        languageCode = 'ta';
        break;
      default:
        languageCode = 'en';
    }

    await flutterTts.setLanguage(languageCode);
  }

  // FUNCTION TO LOAD AND PLAY QUESTION
  Future<void> _loadQuestion() async {
    final question = await questionService.fetchQuestion(
      DiagnoseVerbalScreen.currentQuestionNumber,
      DiagnoseVerbalScreen.selectedLanguage,
    );

    if (question != null) {
      setState(() {
        DiagnoseVerbalScreen.isDataLoaded = true;
        DiagnoseVerbalScreen.question = question.question;
        DiagnoseVerbalScreen.answers = question.answers[0]
            .split(',')
            .map((answer) => answer.trim())
            .toList();
        DiagnoseVerbalScreen.correctAnswer = question.correctAnswer;
      });

      // START THE TIMER WHEN QUESTION IS LOADED
      _stopwatch.start();
    } else {
      setState(() {
        DiagnoseVerbalScreen.isDataLoaded = false;
      });
    }
  }

  // FUNCTION TO TOGGLE AUDIO PLAYBACK
  Future<void> _toggleAudioPlayback() async {
    if (DiagnoseVerbalScreen.isAudioPlaying) {
      await flutterTts.stop();
    } else {
      await flutterTts.speak(DiagnoseVerbalScreen.question);

      flutterTts.setCompletionHandler(() {
        setState(() {
          DiagnoseVerbalScreen.isAudioPlaying = false;
        });
      });
    }

    setState(() {
      DiagnoseVerbalScreen.isAudioPlaying =
          !DiagnoseVerbalScreen.isAudioPlaying;
    });
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

    // ROUND TO THE NEAREST WHOLE SECOND
    final roundedElapsedTimeInSeconds = elapsedTimeInSeconds.round();

    print(DiagnoseVerbalScreen.userResponses);
    print(roundedElapsedTimeInSeconds);
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
            // SHOW LOADER WHILE WAITING FOR THE QUESTION TO LOAD
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            // SHOW QUESTION AND ANSWERS IF LOADING SUCCEEDED
            else {
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
                          child: (snapshot.hasError ||
                                  !DiagnoseVerbalScreen.isDataLoaded)
                              ? // DISPLAY ERROR IF LOADING FAILED
                              const Center(
                                  child: Text(
                                    'Failed to load question. Please try again.',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400),
                                  ),
                                )
                              // DISPLAY QUESTION INSTRUCTIONS
                              : Column(
                                  children: [
                                    const Text(
                                      'Listen and answer the question',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 24.0),
                                    // PLAY AUDIO BUTTON
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: GestureDetector(
                                        key: ValueKey<bool>(DiagnoseVerbalScreen
                                            .isAudioPlaying),
                                        onTap: _toggleAudioPlayback,
                                        child: Opacity(
                                          opacity: 0.7,
                                          child: SizedBox(
                                            width: 180,
                                            height: 90,
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
                                        key: ValueKey<int>(DiagnoseVerbalScreen
                                            .currentQuestionNumber),
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: DiagnoseVerbalScreen.answers
                                            .map((answer) {
                                          return GestureDetector(
                                            onTap: () => _handleAnswer(answer),
                                            child: AnswerBox(
                                              width: 60.0,
                                              height: 60,
                                              value: answer,
                                              size: 32.0,
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
            }
          },
        ),
      ),
    );
  }
}
