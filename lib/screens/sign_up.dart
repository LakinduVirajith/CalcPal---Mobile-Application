import 'package:calcpal/screens/main_dashboard.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/widgets/signup_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDayController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

// SIGNUP HANDLER
  Future<void> _signup() async {
    final String userName = _userNameController.text;
    final String email = _emailController.text;
    final String birthDay = _birthDayController.text;
    final String password = _passwordController.text;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
    );

    try {
      final response = await http.post(
        Uri.parse('https://api/v1/user/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': userName,
          'email': email,
          'birthDay': birthDay,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        ToastService.showSuccessToast("SignUp successful");

        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
        );
      } else {
        ToastService.showErrorToast("SignUp failed");
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

  @override
  Widget build(BuildContext context) {
    // FORCE PORTRAIT ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            // SIGNUP BACKGROUND
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_background.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          const Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'CalcPal',
                style: TextStyle(
                  fontSize: 48,
                  fontFamily: 'Aclonica',
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            // SIGNUP AREA
            left: 0,
            right: 0,
            bottom: 0,
            child: SignUpArea(
              userNameController: _userNameController,
              emailController: _emailController,
              birthDayController: _birthDayController,
              passwordController: _passwordController,
              onPressed: _signup,
            ),
          )
        ],
      ),
    );
  }
}
