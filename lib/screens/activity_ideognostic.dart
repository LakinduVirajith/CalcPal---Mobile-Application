import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/number_line_activity.dart';
import '../screens/fraction_activity.dart';
import '../screens/number_creation_activity.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ActivityIdeognosticScreen extends StatelessWidget {
  const ActivityIdeognosticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/operational_activity_dashboard.png'), // Background image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Buttons
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return FractionallySizedBox(
                  widthFactor: 0.5, // 60% of the screen width
                  heightFactor: 0.5, // 60% of the screen height
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 1.5, // Adjust as needed
                    ),
                    padding: EdgeInsets.all(10.0),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return DashboardButton(
                            text: AppLocalizations.of(context)!
                                .level1NumberLinesLbl,
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NumberLineActivity())),
                          );
                        case 1:
                          return DashboardButton(
                            text: AppLocalizations.of(context)!
                                .level2FractionsLbl,
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FractionActivityScreen())),
                          );
                        case 2:
                          return DashboardButton(
                            text: AppLocalizations.of(context)!
                                .level2NumberCreationLbl,
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NumberCreationActivityScreen())),
                          );
                        default:
                          return SizedBox
                              .shrink(); // Return an empty widget if out of range
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  DashboardButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(80, 40), // Reduce width and height
        backgroundColor: Colors.grey, // Button color
        foregroundColor: Colors.white, // Text color
        padding: EdgeInsets.symmetric(
            horizontal: 12.0, vertical: 8.0), // Adjust padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(fontSize: 14.0), // Adjust font size
        textAlign: TextAlign.center,
      ),
    );
  }
}
