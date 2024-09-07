import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  // FUTURE THAT HOLDS THE STATE OF THE DASHBOARD LOADING PROCESS
  late Future<void> _dashboardFuture;

  // INITIALIZING THE USER SERVICE
  final UserService _userService = UserService();
  final ToastService _toastService = ToastService();

  // VARIABLES TO HOLD STATUS
  bool isDisorder = false;
  String selectedLanguageCode = 'en';

  @override
  void initState() {
    super.initState();
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // SET CUSTOM STATUS BAR COLOR
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // LOADING QUESTION DATA
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
    await _setupLanguage();
    // CHECK IF THE USER HAS A VALID ACCESS TOKEN
    final String? accessToken = prefs.getString('access_token');
    if (accessToken != null) {
      User? user = await _userService.getUser(accessToken, context);
      if (user!.disorderTypes!.isNotEmpty) {
        setState(() {
          isDisorder = true;
        });
      }
    } else {
      _toastService.errorToast("Access token not available. Please log in.");
      Navigator.of(context).pushNamed(loginRoute);
    }
  }

  Future<void> _logout() async {
    // SHOW A CONFIRMATION DIALOG TO THE USER
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      barrierDismissible:
          false, // PREVENT DISMISSING THE DIALOG BY TAPPING OUTSIDE
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.mainDashboardConfirmLogout),
          content: Text(AppLocalizations.of(context)!.mainDashboardAreYouSure),
          backgroundColor: Colors.white,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.mainDashboardCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.mainDashboardLogout),
            ),
          ],
        );
      },
    );

    // CHECK IF THE USER CONFIRMED LOGOUT
    if (confirmLogout == true) {
      // GET THE INSTANCE OF SHARED PREFERENCES
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final accessToken = prefs.getString('access_token');
      if (accessToken != null) {
        // LOG OUT THE USER BY CALLING THE LOGOUT SERVICE
        await _userService.logout(accessToken, context);

        // REMOVE THE STORED ACCESS TOKEN AND REFRESH TOKEN FROM SHARED PREFERENCES
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');

        // NAVIGATE TO THE LOGIN SCREEN AND REMOVE ALL PREVIOUS ROUTES FROM THE STACK
        Navigator.of(context).pushNamedAndRemoveUntil(
          loginRoute,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        right: false,
        left: false,
        child: FutureBuilder(
            future: _dashboardFuture,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              // SHOW LOADING SPINNER IF DATA IS LOADING
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
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/main_dashboard_background.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // BACK BUTTON & PROFILE
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: constraints.maxHeight * 0.75,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: constraints.maxHeight * 0.09),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: _logout,
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
                                Row(
                                  children: [
                                    if (isDisorder)
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                              activityDashboardRoute);
                                        },
                                        child: Container(
                                          width: 140.0,
                                          height: 60.0,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/icons/activities-$selectedLanguageCode.png'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 12.0),
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
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: constraints.maxHeight * 0.25,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // DIAGNOSE QUIZ 1
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(diagnoseVerbalRoute);
                                },
                                child: Container(
                                  width: constraints.maxWidth * 0.24,
                                  height: constraints.maxWidth * 0.24,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/diagnose_quiz_1.png'),
                                    ),
                                  ),
                                ),
                              ),
                              // DIAGNOSE QUIZ 2
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(diagnoseOperationalRoute);
                                },
                                child: Container(
                                  width: constraints.maxWidth * 0.24,
                                  height: constraints.maxWidth * 0.24,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/diagnose_quiz_2.png'),
                                    ),
                                  ),
                                ),
                              ),
                              // DIAGNOSE QUIZ 3
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(diagnoseGraphicalRoute);
                                },
                                child: Container(
                                  width: constraints.maxWidth * 0.24,
                                  height: constraints.maxWidth * 0.24,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/diagnose_quiz_3.png'),
                                    ),
                                  ),
                                ),
                              ),
                              // DIAGNOSE QUIZ 4
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(diagnoseSequentialRoute);
                                },
                                child: Container(
                                  width: constraints.maxWidth * 0.24,
                                  height: constraints.maxWidth * 0.24,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/diagnose_quiz_4.png'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            }),
      ),
    );
  }
}
