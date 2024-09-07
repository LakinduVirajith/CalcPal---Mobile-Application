import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/main.dart';
import 'package:calcpal/models/iq_question.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:calcpal/services/iq_test_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:calcpal/widgets/answer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer;

class IQTestScreen extends StatefulWidget {
  const IQTestScreen({super.key});

  @override
  State<IQTestScreen> createState() => _IQTestScreenState();
}

class _IQTestScreenState extends State<IQTestScreen> {
  // VARIABLES TO HOLD QUESTION AND ANSWER DATA
  late String question;
  late List<String> answers;
  late String correctAnswer;

  late List<bool> userResponses = [];
  late int currentQuestionNumber = 1;

  String selectedLanguageCode = 'en';
  bool isDataLoading = false;
  bool isErrorOccurred = false;

  // INITIALIZING THE SERVICES
  final IqTestService _questionService = IqTestService();
  final UserService _userService = UserService();
  final ToastService _toastService = ToastService();

  // FUTURE FOR QUESTION LOADING STATE
  late Future<void> _activityFuture;

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
    _activityFuture = _loadQuestion();
  }

  // FUNCTION TO SET THE SELECTED LANGUAGE BASED ON THE STORED LANGUAGE CODE
  Future<void> _setupLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    selectedLanguageCode = languageCode;
  }

  Future<void> _showLanguageSelectionDialog() async {
    String? selectedLanguage = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  'English',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.of(context).pop('en');
                },
              ),
              ListTile(
                title: const Text(
                  'Sinhala',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.of(context).pop('si');
                },
              ),
              ListTile(
                title: const Text(
                  'Tamil',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.of(context).pop('ta');
                },
              ),
            ],
          ),
        );
      },
    );

    if (selectedLanguage != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', selectedLanguage);

      setState(() {
        selectedLanguageCode = selectedLanguage;
        Locale newLocale = Locale(selectedLanguage);
        MyApp.setLocale(context, newLocale);
      });

      await _loadQuestion();
    }
  }

  // FUNCTION TO LOAD THE ACTIVITY
  Future<void> _loadQuestion() async {
    try {
      setState(() {
        isErrorOccurred = false;
        isDataLoading = true;
      });

      IqQuestion? iqQuestion = await _questionService.fetchQuestion(
        currentQuestionNumber,
        CommonService.getLanguageForAPI(selectedLanguageCode),
        context,
      );

      if (iqQuestion != null) {
        setState(() {
          question = iqQuestion.question;
          answers = iqQuestion.answers;
          answers.shuffle();
          correctAnswer = iqQuestion.correctAnswer;
        });

        // DECODE BASE64 ENCODED QUESTION IF LANGUAGE IS NOT ENGLISH
        if (selectedLanguageCode != 'en') {
          question = CommonService.decodeString(question);
          answers = CommonService.decodeList(answers);
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
      _submitResults();
    }
  }

  // FUNCTION TO SUBMIT RESULTS
  Future<void> _submitResults() async {
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

    // UPDATE USER IQ TEST VALUE
    final bool status = await _userService.updateIQScore(
      totalScore,
      accessToken,
      context,
    );
    if (status) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        mainDashboardRoute,
        (route) => false,
      );
    } else {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.iqTestMessagesIQError);
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
      // PREVENT ROUTE FROM POPPING
      canPop: false,
      // PREVENT ROUTE FROM POPPING
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context).pushNamed(loginRoute);
      },
      child: Scaffold(
        body: SafeArea(
          right: false,
          left: false,
          child: FutureBuilder(
            future: _activityFuture,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image:
                                AssetImage('assets/images/iq_background.png'),
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
                                            fontSize: 20.0,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w500),
                                      ),
                                    )
                                  // DISPLAY QUESTION INSTRUCTIONS
                                  : Column(
                                      children: [
                                        Text(
                                          '0$currentQuestionNumber. $question',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400),
                                        ),
                                        const SizedBox(height: 24.0),
                                        AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          child: Wrap(
                                            key: ValueKey<int>(
                                                currentQuestionNumber),
                                            spacing:
                                                20.0, // HORIZONTAL SPACING BETWEEN ANSWER BOXES
                                            runSpacing:
                                                20.0, // VERTICAL SPACING BETWEEN ROWS
                                            alignment: WrapAlignment.center,
                                            children: answers.map((answer) {
                                              return GestureDetector(
                                                onTap: () =>
                                                    _handleAnswer(answer),
                                                child: AnswerBox(
                                                  width: 180.0,
                                                  height: 60.0,
                                                  value: answer,
                                                  size: 16.0,
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                      Positioned(
                        top: constraints.maxHeight * 0.1,
                        right: constraints.maxWidth * 0.05,
                        left: constraints.maxWidth * 0.85,
                        bottom: constraints.maxHeight * 0.75,
                        child: ElevatedButton(
                          onPressed: _showLanguageSelectionDialog,
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.white,
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          child: const Text(
                            "LAN",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
