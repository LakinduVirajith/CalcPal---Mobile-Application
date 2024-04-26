import 'package:calcpal/screens/forgot_password.dart';
import 'package:calcpal/screens/sign_up.dart';
import 'package:calcpal/widgets/normal_button.dart';
import 'package:calcpal/widgets/normal_input.dart';
import 'package:calcpal/widgets/password_input.dart';
import 'package:flutter/material.dart';

class LoginArea extends StatelessWidget {
  const LoginArea({
    Key? key,
    required this.userNameController,
    required this.passwordController,
    required this.onPressed,
  }) : super(key: key);

  final TextEditingController userNameController;
  final TextEditingController passwordController;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 32,
        horizontal: 48,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 36),
          NormalInput(
            placeholderText: 'User Name',
            iconPath: 'assets/icons/email.svg',
            normalController: userNameController,
          ), // USERNAME INPUT
          const SizedBox(height: 20),
          PasswordInput(
            passwordController: passwordController,
          ), // PASSWORD INPUT
          const SizedBox(height: 10),
          Container(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen()),
                );
              },
              child: Text(
                'Forgot Password',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          NormalButton(
            buttonText: 'Login',
            onPressed: onPressed,
          ), // LOGIN BUTTON
          const SizedBox(height: 20),
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Don’t have an account? ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
