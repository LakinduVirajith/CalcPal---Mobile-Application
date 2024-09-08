import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:calcpal/services/lexical_service.dart';
import 'package:calcpal/services/speech_to_text_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  int attempt = 0;
  String selectedLanguageCode = 'en';

  bool isMicrophoneOn = false;
  bool isDataLoading = false;
  bool isErrorOccurred = false;

  // FUTURE FOR QUESTION LOADING STATE
  late Future<void> _activityFuture;

  // INITIALIZING SERVICEs
  final ToastService _toastService = ToastService();
  final LexicalService _lexicalService = LexicalService();
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
    _setupLanguage();
    _activityFuture = _loadActivity();
  }

  // SET SELECTED LANGUAGE BASED ON STORED LANGUAGE CODE
  Future<void> _setupLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    selectedLanguageCode = languageCode;
  }

  // FUNCTION TO LOAD THE ACTIVITY
  Future<void> _loadActivity() async {
    try {
      setState(() {
        isErrorOccurred = false;
        isDataLoading = true;
      });

      // VALIDATING THE QUESTION DATA
      await _validateQuestion();
      if (currentActivityNumber == 3) return;

      // FETCHING THE ACTIVITY FROM THE SERVICE
      final activity = await _lexicalService.fetchActivity(
        currentActivityNumber,
        CommonService.getLanguageForAPI(selectedLanguageCode),
        context,
      );

      if (activity != null) {
        setState(() {
          question = activity.question;
          if (activity.answers != null && activity.answers!.isNotEmpty) {
            answers = activity.answers!;
            answers.shuffle();
          }
          correctAnswer = activity.correctAnswer;
        });

        // DECODE BASE64 ENCODED QUESTION IF LANGUAGE IS NOT ENGLISH
        if (selectedLanguageCode != 'en') {
          if (currentActivityNumber == 1) {
            answers = CommonService.decodeList(answers);
          }
          correctAnswer = CommonService.decodeString(correctAnswer);
        }
      } else {
        setState(() {
          isErrorOccurred = true;
          isDataLoading = false;
        });
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
    if (attempt == 2) {
      setState(() {
        currentActivityNumber++;
        attempt = 1;
      });
    } else {
      setState(() => attempt++);
    }

    developer.log('currentActivityNumber: ${currentActivityNumber.toString()}');
    developer.log('attempt: ${attempt.toString()}');
  }

  // FUNTION TO CHECK USER DROP ANSWER
  Future<void> _checkAnswer(String answer) async {
    if (answer == correctAnswer) {
      await _loadActivity();
    } else {
      _toastService.infoToast(
        AppLocalizations.of(context)!.activityLexicalMessageWrongAnswer,
      );
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
                await _loadActivity();
              } else {
                // CHECK IF THERE ARE MORE QUESTIONS LEFT
                _toastService.infoToast(AppLocalizations.of(context)!
                    .activityLexicalMessageWrongAnswer);
                await _captureVoice(); // RETRY ON FAILURE
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
                      right: constraints.maxWidth * 0.52,
                      left: constraints.maxWidth * 0.08,
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
          color: Color.fromARGB(255, 40, 40, 40),
          size: 60.0,
        ),
      );
    } // SHOW ERROR MESSAGE IF AN ERROR OCCURRED
    else if (snapshot.hasError || isErrorOccurred) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            AppLocalizations.of(context)!.commonMessagesLoadActivity,
            style: const TextStyle(
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
                const SizedBox(width: 32.0),
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
                        child: Text(
                          AppLocalizations.of(context)!
                              .activityLexicalQuestion1Text,
                          style: const TextStyle(
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
            Text(
              AppLocalizations.of(context)!.activityLexicalQuestion2Text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: constraints.maxWidth * 0.38,
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
            const SizedBox(height: 24.0),
            // MICROPHONE
            GestureDetector(
              key: ValueKey<bool>(
                isMicrophoneOn,
              ),
              onTap: _captureVoice,
              child: Opacity(
                opacity: 0.8,
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                AppLocalizations.of(context)!
                    .commonMessageMainDashboardNavigation,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24.0),

            // DASHBOARD BUTTON
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(activityDashboardRoute),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  const Color.fromARGB(255, 40, 40, 40),
                ),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.commonactivityDashboardButtonText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
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
        color: const Color.fromARGB(255, 40, 40, 40),
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
          fontSize: (selectedLanguageCode == 'ta') ? 10.0 : 12.0,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
