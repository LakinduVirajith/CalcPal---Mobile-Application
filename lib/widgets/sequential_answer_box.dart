import 'package:flutter/material.dart';

class SequentialAnswerBox extends StatelessWidget {
  const SequentialAnswerBox({
    Key? key,
    required this.width,
    required this.height,
    required this.value,
    required this.type,
  }) : super(key: key);

  final double width;
  final double height;
  final String value;
  final String type; // value represents the number of stars

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 211, 235, 115),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            // Border property
            color: const Color.fromARGB(255, 150, 200, 100), // Border color
            width: 2.0,
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          int.parse(value),
          (index) => Image.asset(
            "assets/icons/${type}.png", // USE DYNAMIC IMAGE PATH
            width: 20.0,
            height: 20.0,
          ),
        ),
      ),
    );
  }
}
