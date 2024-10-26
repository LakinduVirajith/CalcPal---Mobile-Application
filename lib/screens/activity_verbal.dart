import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:calcpal/services/text_to_speech_service.dart';
import 'package:calcpal/services/verbal_service.dart';
import 'package:calcpal/widgets/answer_box.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer;

class ActivityVerbalScreen extends StatefulWidget {
  const ActivityVerbalScreen({super.key});

  @override
  State<ActivityVerbalScreen> createState() => _ActivityVerbalScreenState();
}

class _ActivityVerbalScreenState extends State<ActivityVerbalScreen> {
  // VARIABLES TO HOLD ACTIVITY AND ANSWER DATA
  late String question;
  late String questionByLan;
  late String answer;
  late List<String> answers;
  late String correctAnswerAudioText;
  late String wrongAnswerAudioText;

  int currentActivityNumber = 1;
  int attempt = 0;

  // VARIABLES FOR AUDIO AND LANGUAGE SETTINGS
  late BytesSource correctAnswerVoice;
  late BytesSource wrongAnswerVoice;
  String selectedLanguageCode = 'en';

  bool isAudioPlaying = false;
  bool isDataLoading = false;
  bool isErrorOccurred = false;

  // FUTURE FOR QUESTION LOADING STATE
  late Future<void> _activityFuture;

  // INITIALIZING SERVICEs
  final TextToSpeechService _textToSpeechService = TextToSpeechService();
  final VerbalService _verbalService = VerbalService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final GlobalKey<FlipCardState> _cardKey = GlobalKey<FlipCardState>();

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

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
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
      await _setupLanguage();
      setState(() {
        isErrorOccurred = false;
        isDataLoading = true;
      });

      // VALIDATING THE QUESTION DATA
      await _validateQuestion();
      if (currentActivityNumber == 3) return;

      final activity = await _verbalService.fetchActivity(
        currentActivityNumber,
        CommonService.getLanguageForAPI(selectedLanguageCode),
        context,
      );

      if (activity != null) {
        setState(() {
          question = activity.question;
          answer = activity.answer;
          answers = activity.answers;
          answers.shuffle();
          correctAnswerAudioText = activity.correctAnswerAudioText;
          wrongAnswerAudioText = activity.wrongAnswerAudioText;
        });
        _changeQuestionByLan(question);

        // DECODE BASE64 ENCODED QUESTION IF LANGUAGE IS NOT ENGLISH
        if (selectedLanguageCode != 'en') {
          correctAnswerAudioText =
              CommonService.decodeString(correctAnswerAudioText);
          wrongAnswerAudioText =
              CommonService.decodeString(wrongAnswerAudioText);
        }

        // SYNTHESIZE SPEECH FOR THE QUESTION AND STORE THE AUDIO DATA
        correctAnswerVoice = await _textToSpeechService.synthesizeSpeech(
            correctAnswerAudioText, selectedLanguageCode);

        wrongAnswerVoice = await _textToSpeechService.synthesizeSpeech(
            wrongAnswerAudioText, selectedLanguageCode);
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

  // FUNCTION TO CHANGE QUESTION TEXT BASED ON SELECTED LANGUAGE CODE
  void _changeQuestionByLan(String question) {
    Map<String, Map<String, String>> translations = {
      'apples': {
        'en': 'apples',
        'si': 'ඇපල් ගෙඩි',
        'ta': 'ஆப்பிள்கள்',
      },
      'balloons': {
        'en': 'balloons',
        'si': 'බැලූන්',
        'ta': 'பலூன்கள்',
      },
      'cats': {
        'en': 'cats',
        'si': 'පූසන්',
        'ta': 'பூனைகள்',
      },
      'cupcakes': {
        'en': 'cupcakes',
        'si': 'කප්කේක්',
        'ta': 'கப்கேக்குகள்',
      },
      'stars': {
        'en': 'stars',
        'si': 'තරු',
        'ta': 'நட்சத்திரங்கள்',
      },
    };

    // DEFAULT TO ENGLISH IF QUESTION OR LANGUAGE CODE IS NOT FOUND
    questionByLan = translations[question]?[selectedLanguageCode] ?? question;
  }

  // VALIDATE QUESTION AND UPDATE STATE
  Future<void> _validateQuestion() async {
    if (attempt == 10) {
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

  // FUNCTION TO PLAY AUDIO BASED ON SELECTED ANSWER
  Future<void> _playAudio(String selectedAnswer) async {
    if (isAudioPlaying) return;
    isAudioPlaying = true;

    // CHECK IF SELECTED ANSWER IS CORRECT
    bool isCorrect = selectedAnswer == answer;

    // SET PLAYBACK SPEED
    await _audioPlayer.setPlaybackRate(0.9);

    // PLAY APPROPRIATE AUDIO
    if (isCorrect) {
      await _audioPlayer.play(correctAnswerVoice);
      _cardKey.currentState?.toggleCard();

      // SHOW A CONGRATULATORY DIALOG WHEN THE ANSWER IS CORRECT
      bool status = await CommonService.showCongratulatoryDialog(context);
      if (status) {
        await _loadActivity();
      }
    } else {
      await _audioPlayer.play(wrongAnswerVoice);
    }

    _audioPlayer.onPlayerComplete.listen((event) async {
      isAudioPlaying = false;
      if (isCorrect) {
        _cardKey.currentState?.toggleCard();
        isCorrect = false;
      }
    });
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
                      top: constraints.maxHeight * 0.0,
                      right: constraints.maxWidth * 0.50,
                      left: constraints.maxWidth * 0.10,
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
          image: AssetImage('assets/images/activity_background_v1.jpg'),
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
          child: Text(
            AppLocalizations.of(context)!.commonMessagesLoadActivity,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } // SHOW QUESTION BASED ON QUESTION NUMBER
    else {
      // IF QUESTION NUMBER IS 1, SHOW THE COUNTING QUESTION WIDGET
      if (currentActivityNumber == 1) {
        // CALL METHOD TO GET RANDOM POSITIONS FOR IMAGES
        int count = int.parse(answer);
        List<Positioned> objects =
            _generateRandomObjectPositions(count, 36.0, constraints, question);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${AppLocalizations.of(context)!.activityVerbalQuestion1Part1} $questionByLan ${AppLocalizations.of(context)!.activityVerbalQuestion1Part2}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
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
            // STACK CONTAINER FOR DYNAMICALLY PLACING IMAGES
            SizedBox(
              width: constraints.maxWidth * 0.32,
              height: constraints.maxHeight * 0.32,
              child: Stack(
                children: objects,
              ),
            ),
            const SizedBox(height: 12.0),
            Row(
              key: ValueKey<int>(attempt),
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: answers.map((answer) {
                return GestureDetector(
                  onTap: () => _playAudio(answer),
                  child: AnswerBox(
                    width: 48.0,
                    height: 48.0,
                    value: answer,
                    size: 24.0,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      } // IF QUESTION NUMBER IS 2, SHOW THE FLIP CARD WIDGET
      else if (currentActivityNumber == 2) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.activityVerbalQuestion2Text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
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
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: List.generate(2, (rowIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: Row(
                        children: List.generate(2, (colIndex) {
                          int index = rowIndex * 2 +
                              colIndex; // CALCULATE INDEX BASED ON ROW AND COLUMN
                          return Row(
                            children: [
                              GestureDetector(
                                onTap: () => _playAudio(answers[index]),
                                child: AnswerBox(
                                  width: 48.0,
                                  height: 48.0,
                                  value: answers[index],
                                  size: 24.0,
                                ),
                              ),
                              if (colIndex == 0)
                                const SizedBox(
                                    width: 18.0), // ADD SPACE BETWEEN COLUMNS
                            ],
                          );
                        }),
                      ),
                    );
                  }),
                ),
                FlipCard(
                  key: _cardKey,
                  flipOnTouch: false,
                  direction: FlipDirection.HORIZONTAL,
                  front: _buildFlipCardSide(
                    constraints,
                    'assets/images/flip_card_front_background.jpg',
                    question,
                  ),
                  back: _buildFlipCardSide(
                    constraints,
                    'assets/images/flip_card_back_background.jpg',
                    answer,
                  ),
                ),
              ],
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

  // METHOD TO GENERATE NON-OVERLAPPING RANDOM POSITIONS
  List<Positioned> _generateRandomObjectPositions(
      int count, double size, BoxConstraints constraints, String questionType) {
    final List<Positioned> positions = [];
    final Random random = Random();
    final double containerWidth = constraints.maxWidth * 0.32;
    final double containerHeight = constraints.maxHeight * 0.32;
    final List<Rect> existingRects = [];

    // DETERMINE THE IMAGE PATH BASED ON THE QUESTION TYPE
    String imagePath = _getImagePath(questionType);

    for (int i = 0; i < count; i++) {
      bool isValidPosition = false;
      Offset? position; // MAKE POSITION NULLABLE

      // LOOP TO FIND VALID POSITION WITHOUT OVERLAP
      while (!isValidPosition) {
        double x = random.nextDouble() * (containerWidth - size);
        double y = random.nextDouble() * (containerHeight - size);
        position = Offset(x, y);
        Rect newRect = Rect.fromLTWH(x, y, size, size);

        isValidPosition =
            existingRects.every((rect) => !rect.overlaps(newRect));

        if (isValidPosition) {
          existingRects.add(newRect);
        }
      }

      // ADD POSITIONED SVG IMAGE TO LIST
      positions.add(Positioned(
        left: position!.dx,
        top: position.dy,
        child: Image.asset(
          imagePath, // USE DYNAMIC IMAGE PATH
          width: size,
          height: size,
        ),
      ));
    }

    return positions;
  }

  // METHOD TO RETURN IMAGE PATH BASED ON QUESTION TYPE
  String _getImagePath(String questionType) {
    switch (questionType) {
      case "apples":
        return 'assets/icons/apple.png';
      case "balloons":
        return 'assets/icons/balloon.png';
      case "cats":
        return 'assets/icons/cat.png';
      case "cupcakes":
        return 'assets/icons/cupcake.png';
      case "stars":
        return 'assets/icons/star.png';
      default:
        return 'assets/icons/apple.png';
    }
  }

  // METHOD TO BUILD EACH SIDE OF FLIP CARD WITH GIVEN IMAGE AND TEXT
  Widget _buildFlipCardSide(
      BoxConstraints constraints, String imagePath, String text) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 8.0,
          ),
        ],
      ),
      height: constraints.maxHeight * 0.50,
      width: constraints.maxWidth * 0.16,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
