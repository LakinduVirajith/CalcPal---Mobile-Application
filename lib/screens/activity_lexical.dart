import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:calcpal/services/speech_to_text_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class ActivityLexicalScreen extends StatefulWidget {
  const ActivityLexicalScreen({super.key});

  @override
  State<ActivityLexicalScreen> createState() => _ActivityLexicalScreenState();
}

class _ActivityLexicalScreenState extends State<ActivityLexicalScreen> {
  // VARIABLES TO HOLD QUESTION AND ANSWER DATA
  late String question;
  late List<String> answers;
  late String correctAnswer;

  int currentActivityNumber = 1;
  int attempt = 1;
  String selectedLanguageCode = 'en-US';

  bool isMicrophoneOn = false;
  bool isDataLoading = false;
  bool isErrorOccurred = false;

  // FUTURE FOR QUESTION LOADING STATE
  late Future<void> _activityFuture;

  // INITIALIZING SERVICEs
  final ToastService _toastService = ToastService();
  final SpeechToTextService _speechService = SpeechToTextService();

  @override
  void initState() {
    super.initState();
    // SETTING DEVICE ORIENTATION TO LANDSCAPE MODE
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // CONFIGURING STATUS AND NAVIGATION BAR COLORS
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // LOADING ACTIVITY DATA
    _initiated();
    _activityFuture = _loadActivity();
  }

  // SET SELECTED LANGUAGE BASED ON STORED LANGUAGE CODE
  Future<void> _setupLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    selectedLanguageCode = languageCode;
  }

  Future<void> _initiated() async {
    await _setupLanguage();
  }

  // FUNCTION TO LOAD THE ACTIVITY
  Future<void> _loadActivity() async {
    try {
      setState(() {
        isErrorOccurred = false;
        isDataLoading = true;
      });

      //SAMPLE DATA
      await Future.delayed(const Duration(milliseconds: 2500));
      if (currentActivityNumber == 1) {
        if (attempt == 1) {
          question = '54';
          answers = [
            'Fifty three',
            'Fifty four',
            'Fifty five',
            'Fifty six',
          ];
          answers.shuffle();
          correctAnswer = 'Fifty four';
        } else if (attempt == 2) {
          question = '35';
          answers = [
            'තිස් තුන',
            'තිස් හතර',
            'තිස් පහ',
            'තිස් හය',
          ];
          answers.shuffle();
          correctAnswer = 'තිස් පහ';
        } else if (attempt == 3) {
          question = '88';
          answers = [
            'எண்பத்தி ஆறு',
            'எண்பத்தி ஏழு',
            'எண்பத்தி எட்டு',
            'எண்பத்தி ஒன்பது',
          ];
          answers.shuffle();
          correctAnswer = 'எண்பத்தி எட்டு';
        }
      } else if (currentActivityNumber == 2) {
        if (attempt == 1) {
          question = '54';
          correctAnswer = 'Fifty four';
        } else if (attempt == 2) {
          question = '35';
          correctAnswer = 'තිස් පහ';
        } else if (attempt == 3) {
          question = '88';
          correctAnswer = 'எண்பத்தி எட்டு';
        }
      }
    } catch (e) {
      developer.log(e.toString());
      setState(() => isErrorOccurred = true);
    } finally {
      setState(() => isDataLoading = false);
    }
  }

  // FUNTION VALIDATE QUESTION AND UPDATE STATE
  Future<void> _validateQuestion() async {
    if (attempt >= 10) {
      setState(() {
        currentActivityNumber++;
        attempt = 1;
      });
    } else {
      setState(() => attempt++);
    }
  }

  // FUNTION TO CHECK USER DROP ANSWER
  Future<void> _checkAnswer(String answer) async {
    if (answer == correctAnswer) {
      await _validateQuestion();
      await _loadActivity();
    } else {
      _toastService.infoToast(
        'Close! Let\'s try again and see if we can find the right answer!',
      );
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
    setState(() => isMicrophoneOn = true);

    // INITIALIZE THE SPEECH TO TEXT SERVICE
    bool isInitialized = await _speechService.initializeSpeechToText(
      onError: (error) {
        setState(() => isMicrophoneOn = false);
        _toastService.infoToast('No speech detected. Let\'s try that again!');
        developer.log('Error: $error');
      },
      onStatus: (status) => developer.log('Status: $status'),
    );

    if (isInitialized) {
      // SET LOCALEID BASED ON SELECTED LANGUAGE
      String localeId = CommonService.getLanguageCode(selectedLanguageCode);

      // START LISTENING FOR SPEECH INPUT
      _speechService.startListening(
          localeId: localeId,
          onResult: (recognizedWords) async {
            if (recognizedWords.isNotEmpty) {
              developer.log('recognizedWord: $recognizedWords');

              // COMPARE RECOGNIZED WORDS WITH THE EXPECTED
              bool isCorrectAnswer = recognizedWords == question ||
                  recognizedWords == correctAnswer;

              if (isCorrectAnswer) {
                await _validateQuestion();
                await _loadActivity();
              } else {
                // CHECK IF THERE ARE MORE QUESTIONS LEFT
                _toastService.infoToast(
                    'Close! Let\'s try again and see if we can find the right answer!');
                await _captureVoice(); // RETRY ON FAILURE
              }
            }
          },
          onDone: () async {
            setState(() => isMicrophoneOn = false);
          });
    } else {
      _toastService.errorToast(
          'Failed to initialize the voice recognition service. Please try again.');
      setState(() => isMicrophoneOn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // PREVENT ROUTE FROM POPPING
      canPop: false,
      // HANDLING BACK BUTTON PRESS
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context).pushNamed(activityDashboardRoute);
      },
      child: Scaffold(
        body: SafeArea(
          right: false,
          left: false,
          child: FutureBuilder(
            future: _activityFuture,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              return LayoutBuilder(builder: (context, constraints) {
                return Stack(
                  children: [
                    _buildBackgound(),
                    Positioned(
                      top: constraints.maxHeight * 0.01,
                      right: constraints.maxWidth * 0.54,
                      left: constraints.maxWidth * 0.07,
                      bottom: constraints.maxHeight * 0.24,
                      child: _buildContent(snapshot, constraints),
                    )
                  ],
                );
              });
            },
          ),
        ),
      ),
    );
  }

  // METHOD TO BUILD BACKGROUND CONTAINER WITH IMAGE
  Container _buildBackgound() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/activity_background_v2.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // METHOD TO BUILD CONTENT BASED ON SNAPSHOT AND CONSTRAINTS
  Widget _buildContent(
      AsyncSnapshot<void> snapshot, BoxConstraints constraints) {
    // SHOW LOADING SPINNER IF DATA IS LOADING
    if (snapshot.connectionState == ConnectionState.waiting || isDataLoading) {
      return const Center(
        child: SpinKitCubeGrid(
          color: Color.fromRGBO(40, 40, 40, 1),
          size: 60.0,
        ),
      );
    } // SHOW ERROR MESSAGE IF AN ERROR OCCURRED
    else if (snapshot.hasError || isErrorOccurred) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(4.0),
          child: const Text(
            "Failed to load activity. Please try again.",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } // SHOW QUESTION BASED ON QUESTION NUMBER
    else {
      if (currentActivityNumber == 1) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // QUESTION AND ANSWER AREA
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  question,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 64.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 36.0),
                DragTarget<String>(
                  builder: (context, candidateData, rejectedData) {
                    return DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(8.0),
                      child: Container(
                        width: constraints.maxWidth * 0.24,
                        height: constraints.maxWidth * 0.12,
                        padding: const EdgeInsets.all(10.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'Drop your answer here!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                  onAcceptWithDetails: (answer) => _checkAnswer(answer.data),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            // LIST OF ANSWERS
            SizedBox(
              height: constraints.maxWidth * 0.10,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  return Draggable<String>(
                    data: answers[index],
                    feedback: _buildAnswerBox(answers[index], constraints,
                        isDragging: true),
                    childWhenDragging: _buildAnswerBox(
                        answers[index], constraints,
                        isDragging: true, isDragged: true),
                    child: _buildAnswerBox(answers[index], constraints),
                  );
                },
              ),
            ),
          ],
        );
      } else if (currentActivityNumber == 2) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Read this number aloud',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 1.0,
              child: Container(
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '$question - $correctAnswer',
              style: TextStyle(
                color: Colors.black,
                fontSize: (selectedLanguageCode == 'ta') ? 24.0 : 36.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 48.0),
            // MICROPHONE
            GestureDetector(
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
                    color: isMicrophoneOn ? Colors.black : Colors.white,
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
          ],
        );
      } else {
        // AFTER FINSH ALL ANSWER
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4.0),
              child: const Text(
                "Well done! You've completed all the activities successfully today",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 1.0,
              child: Container(
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16.0),
            // DASHBOARD BUTTON
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(activityDashboardRoute),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  const Color.fromRGBO(40, 40, 40, 1),
                ),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.all(18.0),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              child: const Text(
                'Navigate to Dashboard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      }
    }
  }

  // BUILD ANSWER BOX WIDGET
  Widget _buildAnswerBox(String answer, BoxConstraints constraints,
      {bool isDragging = false, bool isDragged = false}) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      width: constraints.maxWidth * 0.08,
      height: constraints.maxWidth * 0.08,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(40, 40, 40, 1),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: isDragging
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      alignment: Alignment.center,
      child: Text(
        answer,
        style: TextStyle(
          color: Colors.white,
          fontSize: (selectedLanguageCode == 'ta') ? 10.0 : 14.0,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
