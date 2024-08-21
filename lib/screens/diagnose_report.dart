import 'package:calcpal/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DiagnoseReportScreen extends StatefulWidget {
  const DiagnoseReportScreen({super.key});

  @override
  State<DiagnoseReportScreen> createState() => _DiagnoseReportScreenState();
}

class _DiagnoseReportScreenState extends State<DiagnoseReportScreen> {
  // DECLARE INSTANCE VARIABLES
  late String quizType;
  late String diagnoseType1;
  late String diagnoseType2;
  late bool isDiagnoseType1;
  late bool isDiagnoseType2;

  // FUTURE THAT HOLDS THE STATE OF THE RESULT LOADING PROCESS
  late Future<void> _resultFuture;

  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // RETRIEVE THE ARGUMENTS PASSED FROM THE PREVIOUS SCREEN
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments == null ||
        !arguments.containsKey('quizType') ||
        arguments['quizType'].isEmpty) {
      _toastService.errorToast(
        'An unexpected error occurred. Please try again.',
      );
      // NAVIGATE TO PREVIOUS ROUTE
      Navigator.of(context).pop();
      // INITIALIZE WITH FALLBACK VALUE
      _resultFuture = Future.value();
      return;
    }

    // INITIALIZE INSTANCE VARIABLES SAFELY
    quizType = arguments['quizType'];
    // LOAD THE RESULT OF QUIZES WHEN THE WIDGET IS INITIALIZED
    _resultFuture = _loadResult();
  }

  // LOAD THE RESULT BASED ON THE QUIZ TYPE
  Future<void> _loadResult() async {
    switch (quizType) {
      case 'quiz1':
        diagnoseType1 = 'Verbal';
        diagnoseType2 = 'Lexical';
        await _quizeType1();
        break;
      case 'quiz2':
        diagnoseType1 = 'Operational';
        diagnoseType2 = 'Ideognostic';
        await _quizeType2();
        break;
      case 'quiz3':
        diagnoseType1 = 'Graphical';
        diagnoseType2 = 'Practognostic';
        await _quizeType3();
        break;
      case 'quiz4':
        diagnoseType1 = 'Visual Spatial';
        diagnoseType2 = 'Sequential';
        await _quizeType4();
        break;
      default:
        // NAVIGATE TO PREVIOUS ROUTE IF QUIZ TYPE IS INVALID
        Navigator.of(context).pop();
    }
  }

  // LOAD RESULT FOR QUIZ TYPE 1
  Future<void> _quizeType1() async {
    // ADD A 5-SECOND DELAY
    await Future.delayed(const Duration(seconds: 5));

    // ASSIGN VALUES AFTER DELAY
    isDiagnoseType1 = true;
    isDiagnoseType2 = false;
  }

  // LOAD RESULT FOR QUIZ TYPE 2
  Future<void> _quizeType2() async {}

  // LOAD RESULT FOR QUIZ TYPE 3
  Future<void> _quizeType3() async {}

  // LOAD RESULT FOR QUIZ TYPE 4
  Future<void> _quizeType4() async {}

  // METHOD TO HANDLE BUTTON PRESS ACTION
  Future<void> _handleButtonPress() async {}

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _resultFuture,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // DISPLAY A LOADING INDICATOR WHILE THE FUTURE IS BEGIG PROCESSED
              return Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/diagnose_report_background.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Center(
                    child: SpinKitCubeGrid(
                      color: Colors.white,
                      size: 80.0,
                    ),
                  ),
                ],
              );
            } else {
              // ONCE THE FUTURE IS COMPLETED, DISPLAY THE ACTUAL CONTENT
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // SET BACKGROUND IMAGE
                      Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/diagnose_report_background.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: constraints.maxHeight * 0.12,
                        right: constraints.maxWidth * 0.07,
                        bottom: constraints.maxHeight * 0.12,
                        child: Column(
                          children: [
                            // DISPLAY DIAGNOSE TYPE 1 STATUS
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
                                '$diagnoseType1: ${isDiagnoseType1 ? 'Risk' : 'Safe'}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDiagnoseType1
                                      ? const Color.fromRGBO(219, 37, 37, 1)
                                      : const Color.fromRGBO(40, 40, 40, 1),
                                  fontSize: 24,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24.0),
                            // DISPLAY DIAGNOSE TYPE 2 STATUS
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
                                '$diagnoseType2: ${isDiagnoseType2 ? 'Risk' : 'Safe'}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDiagnoseType2
                                      ? const Color.fromRGBO(219, 37, 37, 1)
                                      : const Color.fromRGBO(40, 40, 40, 1),
                                  fontSize: 24,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // BUTTON AT THE BOTTOM
                            SizedBox(
                              width: 240,
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
                                child: Text(
                                  (isDiagnoseType1 || isDiagnoseType2)
                                      ? 'Activities'
                                      : 'Main Dashboard',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
