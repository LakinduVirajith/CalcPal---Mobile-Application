import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PasswordInput extends StatefulWidget {
  const PasswordInput({
    Key? key,
    required TextEditingController passwordController,
  })  : _passwordController = passwordController,
        super(key: key);

  final TextEditingController _passwordController;

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.black87),
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: widget._passwordController,
              obscureText: _obscureText,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Password',
                hintStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: SizedBox(
              width: 20,
              height: 20,
              child: SvgPicture.asset(
                _obscureText
                    ? 'assets/icons/closed-eye.svg'
                    : 'assets/icons/open-eye.svg',
                semanticsLabel: 'Password Icon',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
