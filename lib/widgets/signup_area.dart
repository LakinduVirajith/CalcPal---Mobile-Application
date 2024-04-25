import 'package:calcpal/screens/login.dart';
import 'package:calcpal/widgets/birthday_input.dart';
import 'package:calcpal/widgets/login_button.dart';
import 'package:calcpal/widgets/password_input.dart';
import 'package:calcpal/widgets/email_input.dart';
import 'package:calcpal/widgets/user_name_input.dart';
import 'package:flutter/material.dart';

class SignUpArea extends StatelessWidget {
  const SignUpArea({
    Key? key,
    required this.userNameController,
    required this.emailController,
    required this.birthDayController,
    required this.passwordController,
    required this.onPressed,
  }) : super(key: key);

  final TextEditingController userNameController;
  final TextEditingController emailController;
  final TextEditingController birthDayController;
  final TextEditingController passwordController;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
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
              'Sign Up',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 36),
          UserNameInput(
              userNameController: userNameController), // USER NAME INPUT
          const SizedBox(height: 20),
          EmailInput(
            placeholderText: 'Email',
            userNameController: emailController,
          ), // EMAIL INPUT
          const SizedBox(height: 20),
          BirthDayInput(
              birthDayController: birthDayController), // BIRTHDAY INPUT
          const SizedBox(height: 20),
          PasswordInput(
              passwordController: passwordController), // PASSWORD INPUT
          const SizedBox(height: 20),
          LoginButton(
            buttonText: 'Sign Up',
            onPressed: onPressed,
          ), // SIGNUP BUTTON
          const SizedBox(height: 20),
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
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
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    'Login',
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
