import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:calcpal/services/practognostic_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/widgets/answer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class ActivityPractonosticScreen extends StatefulWidget {
  const ActivityPractonosticScreen({super.key});

  @override
  State<ActivityPractonosticScreen> createState() =>
      _ActivityPractonosticScreenState();
}

class _ActivityPractonosticScreenState
    extends State<ActivityPractonosticScreen> {
  late String question;
  late List<String> answers;
  late String correctAnswer;
  late String activityLevelType;
  late String questionText;

  int currentActivityNumber = 1;
  int attempt = 0;
  String selectedLanguageCode = 'en-US';

  bool isDataLoading = false;
  bool isErrorOccurred = false;
  bool isMicrophoneOn = false;

  late Future<void> _activityFuture;

  // INITIALIZING SERVICEs
  final ToastService _toastService = ToastService();
  final PractognosticService _practognosticService = PractognosticService();

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
      await Future.delayed(const Duration(milliseconds: 200));
      developer.log('API CURRENT NUMBER: ${currentActivityNumber.toString()}');
      // FETCHING THE ACTIVITY FROM THE SERVICE
      final activity = await _practognosticService.fetchActivity(
        currentActivityNumber,
        CommonService.getLanguageForAPI(selectedLanguageCode),
        context,
      );

      if (activity != null) {
        setState(() {
          activityLevelType = activity.activityLevelType;
          questionText = activity.questionText!;
          question = activity.question;
          if (activity.answers.isNotEmpty) {
            answers = activity.answers;
          }
          correctAnswer = activity.correctAnswer;
        });

        // DECODE BASE64 ENCODED QUESTION
        if (selectedLanguageCode != 'en') {
          setState(() => question = CommonService.decodeString(question));
          setState(
              () => questionText = CommonService.decodeString(questionText));
          setState(() => answers = CommonService.decodeList(answers));
          setState(
              () => correctAnswer = CommonService.decodeString(correctAnswer));
        }
        // VALIDATING THE QUESTION DATA
        // await _validateQuestion();
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

  // FUNTION TO CHECK USER DROP ANSWER
  Future<void> _checkAnswer(String answer) async {
    if (answer == correctAnswer) {
      setState(() {
        currentActivityNumber++;
        attempt = 1;
      });

      await _loadActivity();
    } else {
      setState(() => attempt++);
      _toastService.infoToast(
        'Close! Let\'s try again and see if we can find the right answer!',
      );
      developer.log('ATTEMPTS: ${attempt}');
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
                      child: _buildContent(snapshot, constraints),
                    ),
                    // Add the back button at the top left corner
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(activityDashboardRoute);
                          },
                          child: Image.asset(
                            'assets/icons/back.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                    ),
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
          image: AssetImage('assets/images/practoActivity.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildContent(
      AsyncSnapshot<void> snapshot, BoxConstraints constraints) {
    // SHOW LOADING SPINNER IF DATA IS LOADING
    if (snapshot.connectionState == ConnectionState.waiting || isDataLoading) {
      return const Center(
        child: SpinKitCubeGrid(
          color: Color.fromARGB(255, 80, 80, 80),
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
      if (activityLevelType == "1") {
        return Stack(
          children: [
            Positioned(
              top: constraints.maxHeight * 0.1,
              right: constraints.maxWidth * 0.12,
              left: constraints.maxWidth * 0.12,
              bottom: constraints.maxHeight * 0.1,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(96, 96, 96, 0.5),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          question,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          questionText,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentActivityNumber == 1)
                          Image.asset(
                            'assets/images/activity1.png',
                            height: 150.0, // Specify the height
                            width: 150.0,
                          ),
                        if (currentActivityNumber == 2)
                          Image.asset('assets/images/activity2.png'),
                        if (currentActivityNumber == 3)
                          Image.asset('assets/images/activity3.png'),
                        if (currentActivityNumber == 4)
                          Image.asset('assets/images/activity4.png'),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    // ANSWER OPTIONS
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        key: ValueKey<int>(
                          currentActivityNumber,
                        ),
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: answers.map((answer) {
                          return GestureDetector(
                            onTap: () => _checkAnswer(answer),
                            child: AnswerBox(
                              width: 120.0,
                              height: 60,
                              value: answer,
                              size: 18.0,
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
      } else if (activityLevelType == "2") {
        return Stack(
          children: [
            Positioned(
              top: constraints.maxHeight * 0.1,
              right: constraints.maxWidth * 0.12,
              left: constraints.maxWidth * 0.12,
              bottom: constraints.maxHeight * 0.1,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(96, 96, 96, 0.5),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12.0),
                        Text(
                          question,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          questionText,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentActivityNumber == 5)
                          Image.asset(
                            'assets/images/activity5.png',
                            height: 150.0, // Specify the height
                            width: 150.0,
                          ),
                        if (currentActivityNumber == 6)
                          Image.asset(
                            'assets/images/activity6.png',
                            height: 150.0, // Specify the height
                            width: 150.0,
                          ),
                        if (currentActivityNumber == 7)
                          Image.asset(
                            'assets/images/activity7.png',
                            height: 150.0, // Specify the height
                            width: 150.0,
                          ),
                        if (currentActivityNumber == 8)
                          Image.asset(
                            'assets/images/activity8.png',
                            height: 150.0, // Specify the height
                            width: 150.0,
                          ),
                      ],
                    ),
                    // ANSWER OPTIONS
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        key: ValueKey<int>(
                          currentActivityNumber,
                        ),
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: answers.map((answer) {
                          return GestureDetector(
                            onTap: () => _checkAnswer(answer),
                            child: AnswerBox(
                              width: 120.0,
                              height: 60,
                              value: answer,
                              size: 18.0,
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
      } else if (activityLevelType == "3") {
        return Stack(
          children: [
            Positioned(
              top: constraints.maxHeight * 0.1,
              right: constraints.maxWidth * 0.12,
              left: constraints.maxWidth * 0.12,
              bottom: constraints.maxHeight * 0.1,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(96, 96, 96, 0.5),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          question,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          questionText,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentActivityNumber == 9)
                          Image.asset(
                            'assets/images/activity9.png',
                            height: 150.0, // Specify the height
                            width: 150.0,
                          ),
                        if (currentActivityNumber == 10)
                          Image.asset(
                            'assets/images/actibity10.png',
                            height: 150.0, // Specify the height
                            width: 150.0,
                          ),
                        if (currentActivityNumber == 11)
                          Image.asset(
                            'assets/images/actvity11.png',
                            height: 150.0, // Specify the height
                            width: 150.0,
                          ),
                        if (currentActivityNumber == 12)
                          Image.asset(
                            'assets/images/activity12.png',
                            height: 150.0, // Specify the height
                            width: 150.0,
                          ),
                      ],
                    ),
                    // ANSWER OPTIONS
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        key: ValueKey<int>(
                          currentActivityNumber,
                        ),
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: answers.map((answer) {
                          return GestureDetector(
                            onTap: () => _checkAnswer(answer),
                            child: AnswerBox(
                              width: 120.0,
                              height: 60,
                              value: answer,
                              size: 18.0,
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
      } else if (activityLevelType == "4") {
        return Stack(
          children: [
            Positioned(
              top: constraints.maxHeight * 0.1,
              right: constraints.maxWidth * 0.12,
              left: constraints.maxWidth * 0.12,
              bottom: constraints.maxHeight * 0.1,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(96, 96, 96, 0.5),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          question,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          questionText,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 38.0),
                    // ANSWER OPTIONS
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        key: ValueKey<int>(
                          currentActivityNumber,
                        ),
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: answers.map((answer) {
                          return GestureDetector(
                            onTap: () => _checkAnswer(answer),
                            child: AnswerBox(
                              width: 120.0,
                              height: 60,
                              value: answer,
                              size: 18.0,
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
      } else {
        // AFTER FINSH ALL ANSWER
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(96, 96, 96, 0.5),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.all(4.0),
                child: const Text(
                  "Well done! You've completed all the activities successfully",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25.0,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16.0),

              // DASHBOARD BUTTON
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(activityDashboardRoute),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 0, 0, 0),
                  ),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 24.0),
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
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }
}
