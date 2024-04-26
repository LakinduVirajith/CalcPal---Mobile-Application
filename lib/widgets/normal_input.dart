import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NormalInput extends StatelessWidget {
  const NormalInput({
    Key? key,
    required this.placeholderText,
    required this.iconPath,
    required this.normalController,
  }) : super(key: key);

  final String placeholderText;
  final String iconPath;
  final TextEditingController normalController;

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
              controller: normalController,
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
              iconPath,
              semanticsLabel: '$placeholderText Icon',
            ),
          )
        ],
      ),
    );
  }
}
