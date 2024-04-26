import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class DateInput extends StatelessWidget {
  const DateInput({
    Key? key,
    required this.placeholderText,
    required this.iconPath,
    required this.dateController,
  }) : super(key: key);

  final String placeholderText;
  final String iconPath;
  final TextEditingController dateController;

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
              controller: dateController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: placeholderText,
                hintStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  dateController.text =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                }
              },
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
