import 'package:calcpal/services/lexical_service.dart';
import 'package:calcpal/widgets/answer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class DiagnoseLexicalScreen extends StatefulWidget {
  const DiagnoseLexicalScreen({super.key});

  static late String question;
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

  // INITIALIZING THE VERBAL SERVICE
  final LexicalService _questionService = LexicalService();
  // STOPWATCH INSTANCE FOR TIMING
  final Stopwatch _stopwatch = Stopwatch();

  // INITIALIZING SPEECH-TO-TEXT SERVICE
  final stt.SpeechToText _speechToText = stt.SpeechToText();

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
        });

        // START THE STOPWATCH FOR THE FIRST QUESTION ONLY
        if (DiagnoseLexicalScreen.currentQuestionNumber == 1) {
          _stopwatch.start();
        }
      }
    } catch (e) {
      setState(() {
        DiagnoseLexicalScreen.isErrorOccurred = true;
      });
    } finally {
      setState(() {
        DiagnoseLexicalScreen.isErrorOccurred = false;
      });
    }
  }

  Future<void> captureVoice() async {
    setState(() {
      DiagnoseLexicalScreen.isMicrophoneOn =
          !DiagnoseLexicalScreen.isMicrophoneOn; // TOGGLING ISPLAYING FLAG
    });

    if (DiagnoseLexicalScreen.isMicrophoneOn) {
      bool available = await _speechToText.initialize(
        onError: (error) => print('Error: $error'),
      );

      if (available) {
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              print(result.recognizedWords);
            });

            _speechToText.stop();
          },
        );
      } else {
        print('The user has denied the use of speech recognition');
      }
    } else {
      _speechToText.stop();
    }
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
                                            size: 96.0,
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
                      child: GestureDetector(
                        onTap: captureVoice,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: SvgPicture.asset(
                            DiagnoseLexicalScreen.isMicrophoneOn
                                ? 'assets/icons/microphone-radio.svg'
                                : 'assets/icons/microphone.svg',
                            semanticsLabel: 'Microphone Icon',
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
