import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:calcpal/services/text_to_speech_service.dart';
import 'package:calcpal/widgets/answer_box.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class ActivityVerbalScreen extends StatefulWidget {
  const ActivityVerbalScreen({super.key});

  @override
  State<ActivityVerbalScreen> createState() => _ActivityVerbalScreenState();
}

class _ActivityVerbalScreenState extends State<ActivityVerbalScreen> {
  // VARIABLES TO HOLD QUESTION AND ANSWER DATA
  late String question;
  late String answer;
  late List<String> answers;
  late String correctAnswerAudioText;
  late String wrongAnswerAudioText;

  int questionNumber = 1;
  int attempt = 0;

  // VARIABLES FOR AUDIO AND LANGUAGE SETTINGS
  late BytesSource correctAnswerVoice;
  late BytesSource wrongAnswerVoice;
  String selectedLanguageCode = 'en-US';

  bool isAudioPlaying = false;
  bool isDataLoading = false;
  bool isErrorOccurred = false;

  // FUTURE FOR QUESTION LOADING STATE
  late Future<void> _questionFuture;

  // INITIALIZING SERVICEs
  final TextToSpeechService _textToSpeechService = TextToSpeechService();
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
        systemNavigationBarColor: Colors.black,
      ),
    );

    // LOADING QUESTION DATA
    _questionFuture = _loadQuestion();
  }

  // SET SELECTED LANGUAGE BASED ON STORED LANGUAGE CODE
  Future<void> _setupLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    selectedLanguageCode = languageCode;
  }

  // FUNCTION TO LOAD THE QUESTION
  Future<void> _loadQuestion() async {
    try {
      await _setupLanguage();
      isErrorOccurred = false;
      isDataLoading = true;

      // TODO: NEED TO LOAD QUESTIONS
      // SAMPLE QUESTION DATA
      question = "8 + 5";
      answer = "13";
      answers = ["13", "12", "14", "15"];
      correctAnswerAudioText =
          "Great job! Eight plus five equals thirteen. Well done!";
      wrongAnswerAudioText =
          "Not quite. Try again! Remember, eight plus five is a bit more than ten.";

      // question = "stars";
      // answer = "8";
      // answers = ["8", "5", "6", "7"];
      // correctAnswerAudioText =
      //     "Yes! That's right, there are 8 stars! Well done!";
      // wrongAnswerAudioText =
      //     "Not quite. Try again! Count the stars carefully, there are 8 of them.";

      // VALIDATE QUESTION AND UPDATE STATE
      await _validateQuestion();

      // SYNTHESIZE SPEECH FOR THE QUESTION AND STORE THE AUDIO DATA
      correctAnswerVoice = await _textToSpeechService.synthesizeSpeech(
        correctAnswerAudioText,
        CommonService.getLanguageCode(selectedLanguageCode),
      );

      wrongAnswerVoice = await _textToSpeechService.synthesizeSpeech(
        wrongAnswerAudioText,
        CommonService.getLanguageCode(selectedLanguageCode),
      );
    } catch (e) {
      developer.log(e.toString());
      isErrorOccurred = true;
    } finally {
      isDataLoading = false;
    }
  }

  // VALIDATE QUESTION AND UPDATE STATE
  Future<void> _validateQuestion() async {
    if (attempt >= 10) {
      if (questionNumber == 2) {
        Navigator.of(context).pushNamed(activityDashboardRoute);
      } else {
        questionNumber++;
      }
    } else {
      attempt++;
    }

    // DECODE BASE64 ENCODED QUESTION IF LANGUAGE IS NOT ENGLISH
    if (selectedLanguageCode != 'en') {
      _decodeQuestion(correctAnswerAudioText);
      _decodeQuestion(wrongAnswerAudioText);
    }
  }

  // FUNCTION TO DECODE BASE64 ENCODED STRING
  Future _decodeQuestion(String question) async {
    try {
      setState(() {
        question = utf8.decode(base64Decode(question));
      });
    } catch (e) {
      developer.log('Error decoding answers: ${e.toString()}');
    }
  }

  // FUNCTION TO PLAY AUDIO BASED ON SELECTED ANSWER
  Future<void> _playAudio(String selectedAnswer) async {
    if (isAudioPlaying) return;
    isAudioPlaying = true;

    // CHECK IF SELECTED ANSWER IS CORRECT
    bool isCorrect = selectedAnswer == answer;

    // PLAY APPROPRIATE AUDIO
    if (isCorrect) {
      await _audioPlayer.play(correctAnswerVoice);
      _cardKey.currentState?.toggleCard();
    } else {
      await _audioPlayer.play(wrongAnswerVoice);
    }

    _audioPlayer.onPlayerComplete.listen((event) async {
      isAudioPlaying = false;
      if (isCorrect) {
        _cardKey.currentState?.toggleCard();
        isCorrect = false;
        await _loadQuestion();
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
            future: _questionFuture,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              return LayoutBuilder(builder: (context, constraints) {
                return Stack(
                  children: [
                    _buildBackgound(),
                    Positioned(
                      top: constraints.maxHeight * 0.03,
                      right: constraints.maxWidth * 0.55,
                      left: constraints.maxWidth * 0.08,
                      bottom: constraints.maxHeight * 0.29,
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
          child: SpinKitCubeGrid(color: Colors.black, size: 80.0));
    } // SHOW ERROR MESSAGE IF AN ERROR OCCURRED
    else if (snapshot.hasError || isErrorOccurred) {
      return const Center(
        child: Text(
          "Failed to load question. Please try again.",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    } // SHOW QUESTION BASED ON QUESTION NUMBER
    else {
      // IF QUESTION NUMBER IS 1, SHOW THE COUNTING QUESTION WIDGET
      if (questionNumber == 1) {
        // CALL METHOD TO GET RANDOM POSITIONS FOR IMAGES
        int count = int.parse(answer);
        List<Positioned> objects =
            _generateRandomObjectPositions(count, 36.0, constraints, question);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "How many $question can you count?",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
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
      else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Tap an answer to see if you got it right!",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 1.0,
              child: Container(
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12.0),
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
