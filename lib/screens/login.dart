import 'package:calcpal/screens/main_dashboard.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/widgets/login_area.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

// LOGIN HANDLER
  Future<void> _login() async {
    final String username = _userNameController.text;
    final String password = _passwordController.text;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
    );

    try {
      final response = await http.post(
        Uri.parse('https://api/v1/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        ToastService.showSuccessToast("Login successful");

        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
        );
      } else {
        ToastService.showErrorToast("Login failed");
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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            // LOGIN BACKGROUND
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
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Aclonica',
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            // LOGIN AREA
            left: 0,
            right: 0,
            bottom: 0,
            child: LoginArea(
              userNameController: _userNameController,
              passwordController: _passwordController,
              onPressed: _login,
            ),
          ),
        ],
      ),
    );
  }
}
