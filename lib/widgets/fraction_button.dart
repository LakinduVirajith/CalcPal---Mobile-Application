import 'package:flutter/material.dart';

class FractionButton extends StatelessWidget {
  final String numerator;
  final String denominator;
  final VoidCallback onPressed;

  const FractionButton({
    required this.numerator,
    required this.denominator,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            vertical: 20, horizontal: 30), // Button size
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            numerator,
            style: const TextStyle(
              fontSize: 20, // Font size
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            height: 2,
            width: 30,
            color: Colors.white,
          ),
          Text(
            denominator,
            style: const TextStyle(
              fontSize: 20, // Font size
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
