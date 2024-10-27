import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlaceValueTable extends StatelessWidget {
  final int number;
  final IconData iconType;

  PlaceValueTable({required this.number, required this.iconType});

  @override
  Widget build(BuildContext context) {
    int hundreds = (number ~/ 100) % 10;
    int tens = (number ~/ 10) % 10;
    int ones = number % 10;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          margin: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade300, // Set grey background color
            border: Border.all(),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.hundredsLbl,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  VerticalDivider(
                      color: Colors.black,
                      thickness: 2), // Add a black line between columns
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.tensLbl,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  VerticalDivider(
                      color: Colors.black,
                      thickness: 2), // Add a black line between columns
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.onesLbl,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.black), // Black line below the headers
              Row(
                children: [
                  Expanded(child: createCounters(hundreds, iconType)),
                  VerticalDivider(
                      color: Colors.black,
                      thickness: 2), // Add a black line between columns
                  Expanded(child: createCounters(tens, iconType)),
                  VerticalDivider(
                      color: Colors.black,
                      thickness: 2), // Add a black line between columns
                  Expanded(child: createCounters(ones, iconType)),
                ],
              ),
            ],
          ),
        ),
        // Display number below the place value table
        Text(
          '$number',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget createCounters(int count, IconData iconType) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      runSpacing: 8.0,
      children: List.generate(
        count,
        (index) => Icon(iconType, size: 22, color: Colors.black),
      ),
    );
  }
}
