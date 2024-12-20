import 'package:audioplayers/audioplayers.dart';
import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/screens/activity_sequential_v2.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:calcpal/services/sequential_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/widgets/sequential_answer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer;

class ActivitySequentialScreen extends StatefulWidget {
  const ActivitySequentialScreen({super.key});

  static late BytesSource questionVoice;
  static late String question;
  static late List<String> answers;
  static late String correctAnswer;

  static List<bool> userResponses = [];
  static int currentQuestionNumber = 20;
  static String selectedLanguageCode = 'en-US';

  static bool isDataLoading = false;
  static bool isErrorOccurred = false;

  static int type = 1;

  @override
  State<ActivitySequentialScreen> createState() =>
      _ActivitySequentialScreenState();
}

class _ActivitySequentialScreenState extends State<ActivitySequentialScreen> {
  // FUTURE THAT HOLDS THE STATE OF THE QUESTION LOADING PROCESS
  late Future<void> _questionFuture;

  // INITIALIZING THE VERBAL SERVICE
  final SequentialService _questionService = SequentialService();
  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();
  // STOPWATCH INSTANCE FOR TIMING
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    // LOAD THE FIRST QUESTION WHEN THE WIDGET IS INITIALIZED
    _questionFuture = _loadQuestion();
  }

  @override
  void dispose() {
    ActivitySequentialScreen.currentQuestionNumber = 20;
    ActivitySequentialScreen.userResponses = [];
    print(ActivitySequentialScreen.correctAnswer);
    _stopwatch.reset();
    super.dispose();
  }

  // FUNCTION TO SET THE SELECTED LANGUAGE BASED ON THE STORED LANGUAGE CODE
  Future<void> _setupLanguage() async {
    // final prefs = await SharedPreferences.getInstance();
    const languageCode = "en";
    ActivitySequentialScreen.selectedLanguageCode = languageCode;
  }

  // FUNCTION TO LOAD AND PLAY QUESTION
  Future<void> _loadQuestion() async {
    try {
      await _setupLanguage();
      setState(() {
        ActivitySequentialScreen.isErrorOccurred = false;
        ActivitySequentialScreen.isDataLoading = true;
      });

      final question = await _questionService.fetchQuestion(
          ActivitySequentialScreen.currentQuestionNumber,
          CommonService.getLanguageForAPI(
              ActivitySequentialScreen.selectedLanguageCode),
          context);

      if (question != null) {
        setState(() {
          ActivitySequentialScreen.question = question.question;
          ActivitySequentialScreen.answers = question.answers;
          ActivitySequentialScreen.answers.shuffle();
          ActivitySequentialScreen.correctAnswer = question.correctAnswer;
        });

        // _buildStar(ActivitySequentialScreen.answers);
        // START THE STOPWATCH FOR THE FIRST QUESTION ONLY
        if (ActivitySequentialScreen.currentQuestionNumber == 20) {
          _stopwatch.start();
        }
      } else {
        setState(() {
          ActivitySequentialScreen.isErrorOccurred = true;
          ActivitySequentialScreen.isDataLoading = false;
        });
      }
    } catch (e) {
      developer.log(e.toString());
      setState(() {
        ActivitySequentialScreen.isErrorOccurred = true;
        ActivitySequentialScreen.isDataLoading = false;
      });
    } finally {
      setState(() => ActivitySequentialScreen.isDataLoading = false);
    }
  }

  // FUNCTION TO HANDLE USER ANSWERS
  Future<void> _handleAnswer(String userAnswer) async {
    late int correct;
    switch (ActivitySequentialScreen.type) {
      case 1:
        correct = int.parse(ActivitySequentialScreen.correctAnswer) * 4;
        break;
      case 2:
        correct = int.parse(ActivitySequentialScreen.correctAnswer) + 3;
        break;
      case 3:
        correct = int.parse(ActivitySequentialScreen.correctAnswer) - 6;
        break;
      case 4:
        correct = int.parse(ActivitySequentialScreen.correctAnswer) + 3;
        break;
      default:
        correct = int.parse(ActivitySequentialScreen.correctAnswer) - 3;
    }
    if (correct != int.parse(userAnswer)) {
      _toastService.warningToast(
          AppLocalizations.of(context)!.activityLexicalMessageWrongAnswer);
      return;
    } else {
      _toastService.successToast("Great !!!");
    }
    // CHECK IF THERE ARE MORE QUESTIONS LEFT
    if (ActivitySequentialScreen.currentQuestionNumber != 24) {
      ActivitySequentialScreen.currentQuestionNumber++;
      ActivitySequentialScreen.type++;
      _loadQuestion();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SequentialFinishPage()),
      );
    }
  }

// Function to generate a list of star widgets based on the count
  List<Widget> _buildStarSequence(int count) {
    List<Widget> stars = [];
    // int counts = int.parse(count);
    for (int i = 0; i < count; i++) {
      stars.add(
        Image.asset(
          'assets/icons/${ActivitySequentialScreen.question}.png', // Replace with your star image path
          width: 24,
          height: 24,
        ),
      );
      stars.add(const SizedBox(width: 4.0)); // Add spacing between stars
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // SET CUSTOM STATUS BAR COLOR
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        systemNavigationBarColor: Colors.black,
      ),
    );

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
                                'assets/images/activity_background_v3.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: constraints.maxHeight * 0.35,
                        right: constraints.maxWidth * 0.18,
                        left: constraints.maxWidth * 0.18,
                        bottom: constraints.maxHeight * 0.05,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              // vertical: 34.0,
                              // horizontal: 36.0,
                              ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(0, 96, 96, 96),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  ActivitySequentialScreen.isDataLoading)
                              ? // SHOW LOADER WHILE WAITING FOR THE QUESTION TO LOAD
                              const Center(
                                  child: SpinKitCubeGrid(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    size: 80.0,
                                  ),
                                )
                              : (snapshot.hasError ||
                                      ActivitySequentialScreen.isErrorOccurred)
                                  ? // DISPLAY ERROR IF LOADING FAILED
                                  Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .commonMessagesLoadQuestion,
                                        style: const TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
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
                                              .sequentialQuestion,
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: ActivitySequentialScreen
                                                        .selectedLanguageCode ==
                                                    'ta'
                                                ? 18
                                                : 22,
                                            fontFamily: 'Roboto-Bold',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Divider(
                                          color: Colors
                                              .grey, // Set the color of the line
                                          thickness:
                                              2, // Set the thickness of the line
                                          indent:
                                              20, // Optional: Add spacing before the line
                                          endIndent:
                                              20, // Optional: Add spacing after the line
                                        ),

                                        const SizedBox(height: 5.0),
                                        ItemBuilder(
                                            ActivitySequentialScreen.type),
                                        const SizedBox(height: 15.0),
                                        // ANSWER OPTIONS
                                        AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          child: Wrap(
                                            key: ValueKey<int>(
                                              ActivitySequentialScreen
                                                  .currentQuestionNumber,
                                            ),
                                            spacing:
                                                10.0, // spacing between items horizontally
                                            runSpacing:
                                                10.0, // spacing between items vertically (between rows)
                                            alignment: WrapAlignment
                                                .center, // centers the children horizontally
                                            children: ActivitySequentialScreen
                                                .answers
                                                .map((answer) {
                                              return GestureDetector(
                                                onTap: () =>
                                                    _handleAnswer(answer),
                                                child: SequentialAnswerBox(
                                                  width: 200.0,
                                                  height: 50,
                                                  value: answer,
                                                  type: ActivitySequentialScreen
                                                      .question,
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

  Row ItemBuilder(int type) {
    if (type == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: _buildStarSequence(
                  int.parse(ActivitySequentialScreen
                      .correctAnswer), // Sequence with 2 stars
                ),
              ),
              SizedBox(width: 20.0),
              Row(
                children: _buildStarSequence(
                  int.parse(ActivitySequentialScreen.correctAnswer) *
                      2, // Sequence with 4 stars
                ),
              ),
              SizedBox(width: 20.0),
              Row(
                children: _buildStarSequence(
                  int.parse(ActivitySequentialScreen.correctAnswer) * 3,
                ), // Sequence with 6 stars
              ),
            ],
          ),
        ],
      );
    } else if (type == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: _buildStarSequence(
                  int.parse(ActivitySequentialScreen
                      .correctAnswer), // Sequence with 2 stars
                ),
              ),
              SizedBox(width: 20.0),
              Row(
                children: _buildStarSequence(
                  int.parse(ActivitySequentialScreen.correctAnswer) +
                      1, // Sequence with 4 stars
                ),
              ),
              SizedBox(width: 20.0),
              Row(
                children: _buildStarSequence(
                  int.parse(ActivitySequentialScreen.correctAnswer) + 2,
                ), // Sequence with 6 stars
              ),
            ],
          ),
        ],
      );
    } else if (type == 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: _buildStarSequence(
                  int.parse(ActivitySequentialScreen
                      .correctAnswer), // Sequence with 2 stars
                ),
              ),
              SizedBox(width: 20.0),
              Row(
                children: _buildStarSequence(
                  int.parse(ActivitySequentialScreen.correctAnswer) -
                      2, // Sequence with 4 stars
                ),
              ),
              SizedBox(width: 20.0),
              Row(
                children: _buildStarSequence(
                  int.parse(ActivitySequentialScreen.correctAnswer) - 4,
                ), // Sequence with 6 stars
              ),
            ],
          ),
        ],
      );
    } else if (type == 4) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: _buildStarSequence(
                  int.parse(ActivitySequentialScreen
                      .correctAnswer), // Sequence with 2 stars
                ),
              ),
              SizedBox(width: 20.0),
              Row(
                children: _buildStarSequence(
                  int.parse(ActivitySequentialScreen.correctAnswer) +
                      1, // Sequence with 4 stars
                ),
              ),
              SizedBox(width: 20.0),
              Row(
                children: _buildStarSequence(
                  int.parse(ActivitySequentialScreen.correctAnswer) + 2,
                ), // Sequence with 6 stars
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: _buildStarSequence(
                  int.parse(ActivitySequentialScreen
                      .correctAnswer), // Sequence with 2 stars
                ),
              ),
              SizedBox(width: 20.0),
              Row(
                children: _buildStarSequence(
                  int.parse(ActivitySequentialScreen.correctAnswer) -
                      1, // Sequence with 4 stars
                ),
              ),
              SizedBox(width: 20.0),
              Row(
                children: _buildStarSequence(
                  int.parse(ActivitySequentialScreen.correctAnswer) - 2,
                ), // Sequence with 6 stars
              ),
            ],
          ),
        ],
      );
    }
  }
}

class SequentialFinishPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Finish Sequential Game"),
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/activity_background_v3.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.celebration,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                SizedBox(height: 20),
                Text(
                  "Congratulations!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "You've completed the Sequential Pattern Game",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NumberLineJumpScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Start Visual Spatial Game',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
