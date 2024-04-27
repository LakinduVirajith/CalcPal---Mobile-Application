import 'package:flutter/material.dart';

class AnswerBox extends StatelessWidget {
  const AnswerBox({
    Key? key,
    required this.width,
    required this.height,
    required this.value,
    required this.size,
  }) : super(key: key);

  final double width;
  final double height;
  final String value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(40, 40, 40, 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontSize: size,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
