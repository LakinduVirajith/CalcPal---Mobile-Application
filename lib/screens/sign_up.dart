import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/models/sign_up.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:calcpal/widgets/signup_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static bool isLoading = false;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // CONTROLLERS FOR FORM FIELDS
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // INITIALIZING THE USER SERVICE
  final UserService _userService = UserService();
  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

  @override
  void dispose() {
    // DISPOSE CONTROLLERS TO FREE UP RESOURCES
    _usernameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // HANDLER FOR THE SIGN-UP PROCESS
  Future<void> _signup() async {
    try {
      setState(() {
        SignUpScreen.isLoading = true;
      });

      final String username = _usernameController.text;
      final String email = _emailController.text;
      final String birthday = _birthdayController.text;
      final String password = _passwordController.text;

      if (username.isEmpty ||
          email.isEmpty ||
          birthday.isEmpty ||
          password.isEmpty) {
        _toastService.errorToast("Please fill in all fields.");
      } else {
        // CALL THE SIGN-UP SERVICE
        final status = await _userService.signUp(
          SignUp(
            name: username,
            email: email,
            birthday: birthday,
            password: password,
          ),
        );

        if (status) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            loginRoute,
            (route) => false,
          );
        }
      }
    } catch (e) {
      setState(() {
        SignUpScreen.isLoading = false;
      });
    } finally {
      setState(() {
        SignUpScreen.isLoading = false;
      });
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
      body: SafeArea(
        child: Stack(
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
                userNameController: _usernameController,
                emailController: _emailController,
                birthDayController: _birthdayController,
                passwordController: _passwordController,
                isLoading: SignUpScreen.isLoading,
                onPressed: _signup,
              ),
            )
          ],
        ),
      ),
    );
  }
}
