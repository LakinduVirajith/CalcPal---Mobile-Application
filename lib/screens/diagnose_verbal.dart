import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/widgets/answer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

class DiagnoseVerbalScreen extends StatefulWidget {
  const DiagnoseVerbalScreen({super.key});

  static late String voiceUrl;
  static late String question;
  static late List<String> answers;
  static late String correctAnswer;

  static late List<bool> userAnswers;
  static int questionNumber = 1;

  static bool isPlaying = false;

  @override
  State<DiagnoseVerbalScreen> createState() => _DiagnoseVerbalScreenState();
}

class _DiagnoseVerbalScreenState extends State<DiagnoseVerbalScreen> {
  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // CREATING AN INSTANCE OF AUDIOPLAYER FOR AUDIO PLAYBACK
    final player = AudioPlayer();

    // API HANDLING
    Future<void> apiHandler() async {
      try {
        final response = await http.post(
          Uri.parse(
              'https://api/v1/verbal/question/${DiagnoseVerbalScreen.questionNumber}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        if (response.statusCode == 200) {
          // PARSE THE JSON RESPONSE
          final jsonResponse = response.body;
          final data = jsonDecode(jsonResponse);

          // EXTRACT THE VALUES
          DiagnoseVerbalScreen.voiceUrl = data['voiceUrl'] as String;
          DiagnoseVerbalScreen.question = data['question'] as String;
          DiagnoseVerbalScreen.answers =
              List<String>.from(data['answers'] as List<dynamic>);
          DiagnoseVerbalScreen.correctAnswer = data['correctAnswer'] as String;

          // PLAYING AUDIO
          await player.play(UrlSource(DiagnoseVerbalScreen.voiceUrl));
          setState(() {
            DiagnoseVerbalScreen.isPlaying = true;
          });
        }
      } on SocketException catch (_) {
        // CONNECTION ERROR
        ToastService.showErrorToast("Failed to connect to the server");
      } on HttpException catch (_) {
        // HTTP ERROR
        ToastService.showErrorToast("An HTTP error occurred during login");
      } catch (e) {
        // OTHER ERRORS
        ToastService.showErrorToast("An error occurred during login");
      }
    }

    Future<void> toggleAudio() async {
      if (DiagnoseVerbalScreen.isPlaying) {
        await player.pause(); // PAUSING AUDIO PLAYBACK IF IT'S PLAYING
      } else {
        await apiHandler(); // OTHERWISE, PLAY THE AUDIO
      }
      setState(() {
        DiagnoseVerbalScreen.isPlaying =
            !DiagnoseVerbalScreen.isPlaying; // TOGGLING ISPLAYING FLAG
      });
    }

    Future<void> answerHandler(String userAsnwer) async {
      if (userAsnwer == DiagnoseVerbalScreen.correctAnswer) {
        DiagnoseVerbalScreen.questionNumber =
            DiagnoseVerbalScreen.questionNumber++;
        DiagnoseVerbalScreen.userAnswers.add(true);
        apiHandler();
      } else {
        DiagnoseVerbalScreen.questionNumber =
            DiagnoseVerbalScreen.questionNumber++;
        DiagnoseVerbalScreen.userAnswers
            .add(false); // ADDING THE USER'S ANSWER TO THE LIST
        apiHandler(); // PLAYING THE NEXT QUESTION
      }
    }

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
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
                    child: Column(
                      children: [
                        // DISPLAY QUESTION
                        const Text(
                          'Listen and answer the question',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 24.0),
                        // PLAY AUDIO
                        GestureDetector(
                          onTap: toggleAudio,
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: SvgPicture.asset(
                              DiagnoseVerbalScreen.isPlaying
                                  ? 'assets/icons/pause-button.svg'
                                  : 'assets/icons/play-button.svg',
                              semanticsLabel: 'Play Icon',
                            ),
                          ),
                        ),
                        const SizedBox(height: 48.0),
                        // QUESTION ANSWERS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () => answerHandler("10"),
                              child: const AnswerBox(
                                width: 60.0,
                                height: 60,
                                value: '10',
                                size: 32.0,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => answerHandler("9"),
                              child: const AnswerBox(
                                width: 60.0,
                                height: 60,
                                value: '9',
                                size: 32.0,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => answerHandler("8"),
                              child: const AnswerBox(
                                width: 60.0,
                                height: 60,
                                value: '8',
                                size: 32.0,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => answerHandler("11"),
                              child: const AnswerBox(
                                width: 60.0,
                                height: 60,
                                value: '11',
                                size: 32.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
