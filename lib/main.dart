import 'package:calcpal/constants/routes.dart';
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
import 'package:calcpal/themes/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:toastification/toastification.dart';

void main() async {
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
        home: const LoginScreen(), // LOGIN SCREEN
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
        },
        debugShowCheckedModeBanner: true,
      ),
    );
  }
}
