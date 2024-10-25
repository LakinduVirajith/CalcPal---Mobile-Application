import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/models/auth_response.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/screens/activity_dashboard.dart';
import 'package:calcpal/screens/activity_graphical.dart';
import 'package:calcpal/screens/activity_ideognostic.dart';
import 'package:calcpal/screens/activity_lexical.dart';
import 'package:calcpal/screens/activity_operational.dart';
import 'package:calcpal/screens/activity_practonostic.dart';
import 'package:calcpal/screens/activity_sequential.dart';
import 'package:calcpal/screens/activity_verbal.dart';
import 'package:calcpal/screens/activity_visual_spatial.dart';

import 'package:calcpal/screens/activity_visual_v3.dart';

import 'package:calcpal/screens/activity_sequential_v2.dart';

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
import 'package:calcpal/screens/iq_test.dart';
import 'package:calcpal/screens/login.dart';
import 'package:calcpal/screens/main_dashboard.dart';
import 'package:calcpal/screens/profile.dart';
import 'package:calcpal/screens/report.dart';
import 'package:calcpal/screens/sign_up.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:calcpal/splash_screen.dart';
import 'package:calcpal/themes/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'screens/activity_visual_v3.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // LOAD THE ENVIRONMENT VARIABLES FROM THE .ENV FILE TO ACCESS CONFIGURATION DETAILS
  await dotenv.load(fileName: ".env");

  // RUN THE ROOT WIDGET OF THE APPLICATION
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // METHOD TO SET THE LOCALE FROM OUTSIDE THE WIDGET
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // INITIAL LOCALE SET TO 'en' BY DEFAULT
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    // LOAD LOCALE FROM SHARED PREFERENCES
    _loadLocale();
  }

  // METHOD TO LOAD THE LOCALE FROM SHARED PREFERENCES
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    setState(() {
      // UPDATE THE LOCALE BASED ON THE STORED LANGUAGE CODE
      _locale = Locale(languageCode);
    });
  }

  // METHOD TO SET THE LOCALE
  void setLocale(Locale newLocale) {
    setState(() {
      // UPDATE THE LOCALE AND REFRESH THE UI
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'CalcPal Application',
        locale: _locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: colorTheme,
        home: const ValidationScreen(),
        routes: {
          loginRoute: (context) => const LoginScreen(),
          signUpRoute: (context) => const SignUpScreen(),
          forgotPasswordRoute: (context) => const ForgotPasswordScreen(),
          profileRoute: (context) => const ProfileScreen(),
          mainDashboardRoute: (context) => const MainDashboardScreen(),
          iqTestRoute: (context) => const IQTestScreen(),
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
          diagnoseVisualSpatialRoute: (context) => const DiagnoseVisualScreen(),
          diagnoseResultRoute: (context) => const DiagnoseResultScreen(),
          diagnoseReportRoute: (context) => const DiagnoseReportScreen(),
          reportRoute: (context) => const ReportScreen(),
          activityDashboardRoute: (context) => const ActivityDashboardScreen(),
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
          activityV2SequentialRoute: (context) => NumberLineJumpScreen(),
          activityVisualSpatialRoute: (context) =>
              const ActivityVisualSpatialScreen(),
          activityDrawVisualSpatialRoute: (context) => ShapeDrawingApp(),
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

    // WAIT FOR 2500 MILLISECONDS
    await Future.delayed(const Duration(milliseconds: 2500));

    // CHECK IF THE USER HAS REGISTERED BY LOOKING FOR THEIR EMAIL
    final String? userEmail = prefs.getString('user-email');
    if (userEmail == null) {
      Navigator.of(context).pushNamed(signUpRoute);
      return;
    }

    // CHECK IF THE USER HAS A VALID ACCESS TOKEN
    final String? accessToken = prefs.getString('access_token');
    if (accessToken != null && !JwtDecoder.isExpired(accessToken)) {
      User? user = await _userService.getUser(accessToken, context);

      if (user == null) {
        Navigator.of(context).pushNamed(loginRoute);
      } else if (user.iqScore == null) {
        Navigator.of(context).pushNamed(iqTestRoute);
      } else if (user.disorderTypes!.isNotEmpty) {
        Navigator.of(context).pushNamed(activityDashboardRoute);
      } else {
        Navigator.of(context).pushNamed(mainDashboardRoute);
      }
      return;
    }

    // CHECK IF THE USER HAS A VALID REFRESH TOKEN
    final String? refreshToken = prefs.getString('refresh_token');
    if (refreshToken != null && !JwtDecoder.isExpired(refreshToken)) {
      // ATTEMPT TO REFRESH THE ACCESS TOKEN USING THE REFRESH TOKEN
      final AuthResponse? newToken =
          await _userService.generateNewToken(refreshToken, context);
      if (newToken != null) {
        // NEW ACCESS TOKEN OBTAINED, SAVE IT AND NAVIGATE TO THE DASHBOARD
        await prefs.setString('access_token', newToken.accessToken);
        await prefs.setString('refresh_token', newToken.refreshToken);

        User? user = await _userService.getUser(newToken.accessToken, context);
        if (user!.disorderTypes!.isNotEmpty) {
          Navigator.of(context).pushNamed(activityDashboardRoute);
        } else {
          Navigator.of(context).pushNamed(mainDashboardRoute);
        }
        return;
      }
    }

    // NO VALID ACCESS OR REFRESH TOKEN, NAVIGATE TO THE LOGIN SCREEN
    Navigator.of(context).pushNamed(loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initialRoute,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // SHOW SPLASH SCREEN WHILE DETERMINING INITIAL ROUTE
            return const SplashScreen();
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
