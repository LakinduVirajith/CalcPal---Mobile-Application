import 'package:calcpal/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnoseResultScreen extends StatefulWidget {
  const DiagnoseResultScreen({super.key});

  @override
  State<DiagnoseResultScreen> createState() => _DiagnoseResultScreenState();
}

class _DiagnoseResultScreenState extends State<DiagnoseResultScreen> {
  // DECLARE INSTANCE VARIABLES
  late String diagnoseType;
  late int totalScore;
  late int elapsedTime;

  // METHOD TO HANDLE BUTTON PRESS ACTION
  Future<void> _handleButtonPress() async {
    switch (diagnoseType) {
      case 'verbal':
        Navigator.of(context).pushNamedAndRemoveUntil(
          diagnoseLexicalRoute,
          (route) => false,
        );
        break;
      default:
        Navigator.of(context).pushNamedAndRemoveUntil(
          mainDashboardRoute,
          (route) => false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // RETRIEVE THE ARGUMENTS PASSED FROM THE PREVIOUS SCREEN
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // INITIALIZE INSTANCE VARIABLES WITH THE ARGUMENTS
    diagnoseType = arguments['diagnoseType'];
    totalScore = arguments['totalScore'];
    elapsedTime = arguments['elapsedTime'];

    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

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
                          'assets/images/diagnose_result_background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: constraints.maxHeight * 0.05,
                  right: constraints.maxWidth * 0.15,
                  left: constraints.maxWidth * 0.15,
                  bottom: constraints.maxHeight * 0.15,
                  child: Row(
                    children: [
                      Container(
                        height: 200,
                        width: 200,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/icons/well-done.png'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // DISPLAY ELAPSED TIME
                          Container(
                            width: 240,
                            padding: const EdgeInsets.all(12.0),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                            ),
                            child: Text(
                              'Elapsed Time: ${elapsedTime}s',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color.fromRGBO(40, 40, 40, 1),
                                fontSize: 24,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          // DISPLAY TOTAL SCORE
                          Container(
                            width: 240,
                            padding: const EdgeInsets.all(12.0),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                            ),
                            child: Text(
                              'Total Score: $totalScore/5',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color.fromRGBO(40, 40, 40, 1),
                                fontSize: 24,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                // POSITION BUTTON AT THE BOTTOM RIGHT
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: _handleButtonPress,
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
                      'Let\'s Go',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
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
