import 'package:calcpal/models/activity_result.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/ideognostic_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TableScreenIde extends StatefulWidget {
  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreenIde> {
  String selectedOption = '';
  List<ActivityResult>? _activityResults;

  final UserService _userService = UserService();
  final IdeognosticService _activityService = IdeognosticService();

  List<DataRow> getTableRows() {
    if (_activityResults == null) return [];
    return _activityResults!.map((result) {
      return DataRow(
        cells: [
          DataCell(Text(result.date)),
          DataCell(Text(result.totalScore.toString())),
          DataCell(Text(result.retries.toString())),
          DataCell(Text('${result.timeTaken}')),
        ],
      );
    }).toList();
  }

  Future<void> _submitResultsToDB(String activity) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesAccessTokenError);
      return;
    }

    User? user = await _userService.getUser(accessToken, context);

    if (user == null) {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesIQScoreError);
      return;
    }

    List<ActivityResult>? results = await _activityService
        .getActivityResultsByEmailAndActivity(user.email, activity, context);

    if (results != null) {
      setState(() {
        _activityResults = results;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.noResultsFound),
      ));
    }
  }

  void _handleErrorAndRedirect(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> activities = [
      {
        'english': 'Number Line',
        'localized': AppLocalizations.of(context)!.level1NumberLinesLbl
      },
      {
        'english': 'Number Creation',
        'localized': AppLocalizations.of(context)!.level2NumberCreationLbl
      },
      {
        'english': 'Fractions',
        'localized': AppLocalizations.of(context)!.level2FractionsLbl
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.activityReportsTitle),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade50, // Light background color
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Center-aligned dropdown label and dropdown button
            Center(
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.selectActivity,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedOption.isEmpty ? null : selectedOption,
                    hint:
                        Text(AppLocalizations.of(context)!.noActivitySelected),
                    items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(AppLocalizations.of(context)!
                                .noActivitySelected),
                          ),
                        ] +
                        activities.map((Map<String, String> activity) {
                          return DropdownMenuItem<String>(
                            value: activity['english'],
                            child: Text(activity['localized']!),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedOption = value;
                        });
                        _submitResultsToDB(value);
                      } else {
                        setState(() {
                          _activityResults = null;
                        });
                      }
                    },
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    dropdownColor: Colors.lightBlueAccent,
                    iconEnabledColor: Colors.blue,
                    iconSize: 30,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Center-aligned data table with scrollable container
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context)!.datePlayed,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context)!.score,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context)!.correctNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context)!.timePlayedInSecs,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    rows: getTableRows(),
                    dataRowColor:
                        MaterialStateProperty.all(Colors.lightBlue.shade100),
                    headingRowColor:
                        MaterialStateProperty.all(Colors.teal.shade700),
                    headingTextStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
