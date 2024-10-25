import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ActivityDashboardScreen extends StatefulWidget {
  const ActivityDashboardScreen({super.key});

  @override
  State<ActivityDashboardScreen> createState() =>
      _ActivityDashboardScreenState();
}

class _ActivityDashboardScreenState extends State<ActivityDashboardScreen> {
  // VARIABLES TO HOLD DISORDER TYPES
  late List<String> types;
  String selectedLanguageCode = 'en';

  // MAP TO ASSOCIATE TYPES WITH ROUTE NAMES
  final Map<String, String> _routeNames = {
    'Verbal': activityVerbalRoute,
    'Lexical': activityLexicalRoute,
    'Operational': activityOperationalRoute,
    'Ideognostic': activityIdeognosticRoute,
    'Graphical': activityGraphicalRoute,
    'Practognostic': activityPractognosticRoute,
    'Visualspatial': activityVisualSpatialRoute,
    'Sequential': activitySequentialRoute,
  };
  // FUTURE THAT HOLDS THE STATE OF THE DASHBOARD LOADING PROCESS
  late Future<void> _dashboardFuture;

  // INITIALIZING SERVICES
  final UserService _userService = UserService();
  final ToastService _toastService = ToastService();

  @override
  void initState() {
    super.initState();
    // SETTING DEVICE ORIENTATION TO LANDSCAPE MODE
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // CONFIGURING STATUS AND NAVIGATION BAR COLORS
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // LOADING QUESTION DATA
    _setupLanguage();
    _dashboardFuture = _loadDashboard();
  }

  // SET SELECTED LANGUAGE BASED ON STORED LANGUAGE CODE
  Future<void> _setupLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    setState(() => selectedLanguageCode = languageCode);
  }

  // FUNCTION LOAD THE DASHBOARD DATA
  Future<void> _loadDashboard() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // CHECK IF THE USER HAS A VALID ACCESS TOKEN
    final String? accessToken = prefs.getString('access_token');
    if (accessToken != null) {
      User? user = await _userService.getUser(accessToken, context);
      if (user!.disorderTypes!.isNotEmpty) {
        setState(() {
          types = user.disorderTypes!
              .map((type) => capitalizeFirstLetter(type))
              .toList();
        });
      }
    } else {
      _toastService.errorToast(
          AppLocalizations.of(context)!.commonMessagesAccessTokenError);
      Navigator.of(context).pushNamed(loginRoute);
    }
  }

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // PREVENT ROUTE FROM POPPING
      canPop: false,
      // HANDLING BACK BUTTON PRESS
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          mainDashboardRoute,
          (route) => false,
        );
      },
      child: Scaffold(
        body: SafeArea(
          right: false,
          left: false,
          child: FutureBuilder(
            future: _dashboardFuture,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.black,
                    child: const SpinKitWave(
                      color: Colors.white,
                      size: 60.0,
                    ),
                  ),
                );
              } else {
                return Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/images/activity_dashboard_background.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 36.0,
                            vertical: 12.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    mainDashboardRoute,
                                    (route) => false,
                                  );
                                },
                                child: Container(
                                  width: 70.0,
                                  height: 70.0,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          AssetImage('assets/icons/back.png'),
                                    ),
                                  ),
                                ),
                              ),
                              Row(children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed(profileRoute);
                                  },
                                  child: Container(
                                    width: 150.0,
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/icons/settings-$selectedLanguageCode.png'),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed(reportRoute);
                                  },
                                  child: Container(
                                    width: 150.0,
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/icons/report-$selectedLanguageCode.png'),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: types.length,
                            itemBuilder: (context, index) {
                              final type = types[index];
                              final routeName =
                                  _routeNames[type] ?? mainDashboardRoute;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 44.0,
                                  vertical: 8.0,
                                ),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                      Colors.white,
                                    ),
                                    padding: WidgetStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          vertical: 12.0, horizontal: 24.0),
                                    ),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(routeName);
                                  },
                                  child: Text(
                                    '${AppLocalizations.of(context)!.activityDashboardActivityText} - $type',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
