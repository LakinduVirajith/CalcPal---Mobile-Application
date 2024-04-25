import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserNameInput extends StatelessWidget {
  const UserNameInput({
    Key? key,
    required this.userNameController,
  }) : super(key: key);

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
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "User Name",
                hintStyle: TextStyle(
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
