import 'dart:convert';
import 'dart:io';

import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/widgets/answer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class DiagnoseLexicalScreen extends StatefulWidget {
  const DiagnoseLexicalScreen({super.key});

  static int questionNumber = 1;
  static late String question;
  static late String answers;

  static bool isPlaying = false;

  @override
  State<DiagnoseLexicalScreen> createState() => _DiagnoseLexicalScreenState();
}

class _DiagnoseLexicalScreenState extends State<DiagnoseLexicalScreen> {
  stt.SpeechToText _speechToText = stt.SpeechToText();

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    final ToastService _toastService = ToastService();

    // API HANDLING
    Future<void> apiHandler() async {
      try {
        final response = await http.post(
          Uri.parse(
              'https://api/v1/lexical/question/${DiagnoseLexicalScreen.questionNumber}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        if (response.statusCode == 200) {
          // PARSE THE JSON RESPONSE
          final jsonResponse = response.body;
          final data = jsonDecode(jsonResponse);

          // EXTRACT THE VALUES
          DiagnoseLexicalScreen.question = data['question'] as String;
          DiagnoseLexicalScreen.answers = data['answers'] as String;
        }
      } on SocketException catch (_) {
        // CONNECTION ERROR
        _toastService.errorToast("Failed to connect to the server");
      } on HttpException catch (_) {
        // HTTP ERROR
        _toastService.errorToast("An HTTP error occurred during login");
      } catch (e) {
        // OTHER ERRORS
        _toastService.errorToast("An error occurred during login");
      }
    }

    Future<void> captureVoice() async {
      setState(() {
        DiagnoseLexicalScreen.isPlaying =
            !DiagnoseLexicalScreen.isPlaying; // TOGGLING ISPLAYING FLAG
      });

      if (DiagnoseLexicalScreen.isPlaying) {
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

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
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
                    child: const Column(
                      children: [
                        // DISPLAY QUESTION
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Read the number aloud',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.0),
                        // QUESTION NUMBER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AnswerBox(
                              width: 160.0,
                              height: 160.0,
                              value: '10',
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
                        DiagnoseLexicalScreen.isPlaying
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
        ),
      ),
    );
  }
}
