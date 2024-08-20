import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/widgets/date_input.dart';
import 'package:calcpal/widgets/normal_button.dart';
import 'package:calcpal/widgets/password_input.dart';
import 'package:calcpal/widgets/normal_input.dart';
import 'package:flutter/material.dart';

class SignUpArea extends StatelessWidget {
  const SignUpArea({
    Key? key,
    required this.userNameController,
    required this.emailController,
    required this.birthDayController,
    required this.passwordController,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);

  final TextEditingController userNameController;
  final TextEditingController emailController;
  final TextEditingController birthDayController;
  final TextEditingController passwordController;
  final bool isLoading;
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
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 36),
          NormalInput(
            placeholderText: 'Name',
            iconPath: 'assets/icons/user.svg',
            normalController: userNameController,
          ), // USER NAME INPUT
          const SizedBox(height: 20),
          NormalInput(
            placeholderText: 'Email',
            iconPath: 'assets/icons/email.svg',
            normalController: emailController,
          ), // EMAIL INPUT
          const SizedBox(height: 20),
          DateInput(
            placeholderText: 'Birthday',
            iconPath: 'assets/icons/cake.svg',
            dateController: birthDayController,
          ), // BIRTHDAY INPUT
          const SizedBox(height: 20),
          PasswordInput(
              passwordController: passwordController), // PASSWORD INPUT
          const SizedBox(height: 20),
          NormalButton(
            buttonText: 'Sign Up',
            isLoading: isLoading,
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(loginRoute);
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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
