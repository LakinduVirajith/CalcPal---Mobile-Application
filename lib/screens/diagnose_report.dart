import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/enums/disorder_types.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  // INITIALIZING THE USER SERVICE
  final UserService _userService = UserService();
  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments == null ||
        !arguments.containsKey('quizType') ||
        arguments['quizType'].isEmpty) {
      _showErrorAndPop();
      return;
    }

    quizType = arguments['quizType'];
    _resultFuture = _loadResult();
  }

  void _showErrorAndPop() {
    // SHOW ERROR MESSAGE AND POP THE CURRENT ROUTE
    _toastService.errorToast(
        AppLocalizations.of(context)!.diagnoseReportMessagesUnexpected);
    Navigator.of(context).pop();
    _resultFuture = Future.value();
  }

  // LOAD THE RESULT BASED ON THE QUIZ TYPE
  Future<void> _loadResult() async {
    switch (quizType) {
      case 'quiz1':
        diagnoseType1 = 'Verbal';
        diagnoseType2 = 'Lexical';
        await _processBaseType(DisorderTypes.verbal, DisorderTypes.lexical);
        break;
      case 'quiz2':
        diagnoseType1 = 'Operational';
        diagnoseType2 = 'Ideognostic';
        await _processBaseType(
            DisorderTypes.operational, DisorderTypes.ideognostic);
        break;
      case 'quiz3':
        diagnoseType1 = 'Graphical';
        diagnoseType2 = 'Practognostic';
        await _processBaseType(
            DisorderTypes.graphical, DisorderTypes.practognostic);
        break;
      case 'quiz4':
        diagnoseType1 = 'Visual Spatial';
        diagnoseType2 = 'Sequential';
        await _processBaseType(
            DisorderTypes.visualSpatial, DisorderTypes.sequential);
        break;
      default:
        // INVALID QUIZ TYPE - POP THE CURRENT ROUTE
        Navigator.of(context).pop();
    }
  }

  // PROCESS THE BASED ON THE GIVEN DISORDER TYPES
  Future<void> _processBaseType(
      DisorderTypes type1, DisorderTypes type2) async {
    try {
      // GET SHARED PREFERENCES INSTANCE
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken != null) {
        User? user = await _userService.getUser(accessToken, context);
        if (user != null && user.disorderTypes != null) {
          // SET FLAGS BASED ON DISORDER TYPES
          isDiagnoseType1 =
              user.disorderTypes!.contains(type1.toString().split('.').last);
          isDiagnoseType2 =
              user.disorderTypes!.contains(type2.toString().split('.').last);
        } else {
          // HANDLE EMPTY DISORDER TYPES
          isDiagnoseType1 = isDiagnoseType2 = false;
        }
      }
    } catch (e) {
      // SHOW ERROR MESSAGE ON EXCEPTION
      _toastService.errorToast(
        AppLocalizations.of(context)!.diagnoseReportMessagesUnexpected,
      );
    }
  }

  // METHOD TO HANDLE BUTTON PRESS ACTION
  Future<void> _handleButtonPress() async {
    // MAP OF DIAGNOSIS TYPES TO THEIR RESPECTIVE PAGES
    final Map<String, String> diagnosisRoutes = {
      'Verbal': activityVerbalRoute,
      'Operational': activityLexicalRoute,
      'Graphical': activityOperationalRoute,
      'Visual Spatial': activityIdeognosticRoute,
      'Lexical': activityGraphicalRoute,
      'Ideognostic': activityPractognosticRoute,
      'Practognostic': activitySequentialRoute,
      'Sequential': activityVisualSpatialRoute,
    };

    // CHECK IF ANY DIAGNOSIS TYPE IS PRESENT
    if (isDiagnoseType1 || isDiagnoseType2) {
      // NAVIGATE BASED ON DIAGNOSIS TYPE 1
      if (isDiagnoseType1 && diagnosisRoutes.containsKey(diagnoseType1)) {
        Navigator.of(context).pushNamed(diagnosisRoutes[diagnoseType1]!);
        return;
      }

      // NAVIGATE BASED ON DIAGNOSIS TYPE 2
      if (isDiagnoseType2 && diagnosisRoutes.containsKey(diagnoseType2)) {
        Navigator.of(context).pushNamed(diagnosisRoutes[diagnoseType2]!);
        return;
      }
    }

    // NAVIGATE TO MAIN DASHBOARD IF NO DIAGNOSIS TYPE
    Navigator.of(context).pushNamedAndRemoveUntil(
      mainDashboardRoute,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: SafeArea(
        left: false,
        right: false,
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
                                '$diagnoseType1: ${isDiagnoseType1 ? AppLocalizations.of(context)!.diagnoseReportRisk : AppLocalizations.of(context)!.diagnoseReportSafe}',
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
                                '$diagnoseType2: ${isDiagnoseType2 ? AppLocalizations.of(context)!.diagnoseReportRisk : AppLocalizations.of(context)!.diagnoseReportSafe}',
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
                                      ? AppLocalizations.of(context)!
                                          .diagnoseReportActivityButton
                                      : AppLocalizations.of(context)!
                                          .diagnoseReportMainDashboardButton,
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
