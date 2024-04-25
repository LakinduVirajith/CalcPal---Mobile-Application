import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmailInput extends StatelessWidget {
  const EmailInput({
    Key? key,
    required this.placeholderText,
    required this.userNameController,
  }) : super(key: key);

  final String placeholderText;
  final TextEditingController userNameController;

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
              controller: userNameController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: placeholderText,
                hintStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset(
              'assets/icons/email.svg',
              semanticsLabel: 'Email Icon',
            ),
          )
        ],
      ),
    );
  }
}
