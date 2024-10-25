import 'package:flutter/material.dart';

class CommonWidgets {
  // Build Draggable Widget
  static Widget buildDraggableDigit(int digit) {
    return Draggable<int>(
      data: digit,
      child: buildDigitBox(digit),
      feedback: buildDigitBox(digit, isDragging: true),
      childWhenDragging: buildDigitBox(digit, isDragging: true, opacity: 0.5),
    );
  }

  // Build Drag Target Widget
  static Widget buildDragTarget({
    required int index,
    required int? currentDigit,
    required Function(int) onAccept,
  }) {
    return DragTarget<int>(
      onAccept: (receivedDigit) {
        onAccept(receivedDigit);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.blue,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              currentDigit?.toString() ?? '',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  // Build Digit Box Widget
  static Widget buildDigitBox(int digit,
      {bool isDragging = false, double opacity = 1}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDragging ? Colors.grey : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (!isDragging)
              BoxShadow(
                color: Colors.black26,
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
          ],
        ),
        child: Text(
          digit.toString(),
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
