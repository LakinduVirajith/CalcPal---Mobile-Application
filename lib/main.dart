import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/models/auth_response.dart';
import 'package:calcpal/screens/activity_graphical.dart';
import 'package:calcpal/screens/activity_ideognostic.dart';
import 'package:calcpal/screens/activity_lexical.dart';
import 'package:calcpal/screens/activity_operational.dart';
import 'package:calcpal/screens/activity_practonostic.dart';
import 'package:calcpal/screens/activity_sequential.dart';
import 'package:calcpal/screens/activity_verbal.dart';
import 'package:calcpal/screens/activity_visual_spatial.dart';
import 'package:calcpal/screens/diagnose_graphical.dart';
import 'package:calcpal/screens/diagnose_ideognostic.dart';
import 'package:calcpal/screens/diagnose_lexical.dart';
import 'package:calcpal/screens/diagnose_operational.dart';
import 'package:calcpal/screens/diagnose_practonostic.dart';
import 'package:calcpal/screens/diagnose_report.dart';
import 'package:calcpal/screens/diagnose_result.dart';
import 'package:calcpal/screens/diagnose_sequential.dart';
import 'package:calcpal/screens/diagnose_verbal.dart';
import 'package:calcpal/screens/diagnose_visual_spatial.dart';
import 'package:calcpal/screens/forgot_password.dart';
import 'package:calcpal/screens/login.dart';
import 'package:calcpal/screens/main_dashboard.dart';
import 'package:calcpal/screens/profile.dart';
import 'package:calcpal/screens/sign_up.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:calcpal/themes/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // LOAD THE ENVIRONMENT VARIABLES FROM THE .ENV FILE TO ACCESS CONFIGURATION DETAILS
  await dotenv.load(fileName: ".env");

  // SET CUSTOM STATUS BAR COLOR
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // RUN THE ROOT WIDGET OF THE APPLICATION
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'CalcPal Application',
        theme: colorTheme,
        home: const ValidationScreen(),
        routes: {
          loginRoute: (context) => const LoginScreen(),
          signUpRoute: (context) => const SignUpScreen(),
          forgotPasswordRoute: (context) => const ForgotPasswordScreen(),
          profileRoute: (context) => const ProfileScreen(),
          mainDashboardRoute: (context) => const MainDashboardScreen(),
          diagnoseVerbalRoute: (context) => const DiagnoseVerbalScreen(),
          diagnoseLexicalRoute: (context) => const DiagnoseLexicalScreen(),
          diagnoseOperationalRoute: (context) =>
              const DiagnoseOperationalScreen(),
          diagnoseIdeognosticRoute: (context) =>
              const DiagnoseIdeognosticScreen(),
          diagnoseGraphicalRoute: (context) => const DiagnoseGraphicalScreen(),
          diagnosePractognosticRoute: (context) =>
              const DiagnosePractonosticScreen(),
          diagnoseSequentialRoute: (context) =>
              const DiagnoseSequentialScreen(),
          diagnoseVisualSpatialRoute: (context) =>
              const DiagnoseVisualSpatialScreen(),
          diagnoseResultRoute: (context) => const DiagnoseResultScreen(),
          diagnoseReportRoute: (context) => const DiagnoseReportScreen(),
          activityVerbalRoute: (context) => const ActivityVerbalScreen(),
          activityLexicalRoute: (context) => const ActivityLexicalScreen(),
          activityOperationalRoute: (context) =>
              const ActivityOperationalScreen(),
          activityIdeognosticRoute: (context) =>
              const ActivityIdeognosticScreen(),
          activityGraphicalRoute: (context) => const ActivityGraphicalScreen(),
          activityPractognosticRoute: (context) =>
              const ActivityPractonosticScreen(),
          activitySequentialRoute: (context) =>
              const ActivitySequentialScreen(),
          activityVisualSpatialRoute: (context) =>
              const ActivityVisualSpatialScreen(),
        },
        debugShowCheckedModeBanner: true,
      ),
    );
  }
}

class ValidationScreen extends StatefulWidget {
  const ValidationScreen({super.key});

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  // INITIALIZING THE SERVICES
  final UserService _userService = UserService();
  late Future<void> _initialRoute;

  @override
  void initState() {
    super.initState();
    _initialRoute = _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // CHECK IF USER HAS REGISTERED
    final String? userEmail = prefs.getString('user-email');
    if (userEmail == null) {
      // USER IS NEW, GO TO REGISTER SCREEN
      Navigator.of(context).pushNamed(signUpRoute);
      return;
    }

    // CHECK IF USER HAS AN ACCESS TOKEN
    final String? accessToken = prefs.getString('access_token');
    if (accessToken != null && !JwtDecoder.isExpired(accessToken)) {
      // ACCESS TOKEN IS VALID, GO TO MAIN DASHBOARD
      Navigator.of(context).pushNamed(mainDashboardRoute);
      return;
    }

    // ACCESS TOKEN IS INVALID, CHECK REFRESH TOKEN
    final String? refreshToken = prefs.getString('refresh_token');
    if (refreshToken != null && !JwtDecoder.isExpired(refreshToken)) {
      // TRY TO REFRESH THE ACCESS TOKEN USING THE REFRESH TOKEN
      final AuthResponse? newToken = await _userService.generateNewToken(
        refreshToken,
      );
      if (newToken != null) {
        // NEW ACCESS TOKEN ACQUIRED, SAVE IT AND GO TO MAIN DASHBOARD
        await prefs.setString('access_token', newToken.accessToken);
        await prefs.setString('refresh_token', newToken.refreshToken);
        Navigator.of(context).pushNamed(mainDashboardRoute);
        return;
      }
    }

    // IF NO ACCESS TOKEN OR REFRESH TOKEN IS INVALID, GO TO LOGIN SCREEN
    Navigator.of(context).pushNamed(loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _initialRoute,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // SHOW LOADING INDICATOR WHILE DETERMINING INITIAL ROUTE
              return const CircularProgressIndicator();
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
