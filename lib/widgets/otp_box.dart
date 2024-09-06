import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPBox extends StatelessWidget {
  const OTPBox({
    Key? key,
    required this.inputController,
    required this.width,
    required this.height,
  }) : super(key: key);

  final TextEditingController inputController;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Colors.black87,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        child: TextField(
          controller: inputController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 12.0),
          ),
          style: const TextStyle(
            fontSize: 24.0,
          ),
          keyboardType: TextInputType.number,
          showCursor: false,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'\d')),
            LengthLimitingTextInputFormatter(1),
          ],
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
