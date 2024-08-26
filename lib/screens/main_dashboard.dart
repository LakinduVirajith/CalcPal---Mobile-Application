import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  // INITIALIZING THE USER SERVICE
  final UserService _userService = UserService();

  Future<void> _logout() async {
    // SHOW A CONFIRMATION DIALOG TO THE USER
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      barrierDismissible:
          false, // PREVENT DISMISSING THE DIALOG BY TAPPING OUTSIDE
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          backgroundColor: Colors.white,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
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
        await _userService.logout(accessToken);

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
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // SET CUSTOM STATUS BAR COLOR
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        systemNavigationBarColor: Colors.black,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
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
                            width: constraints.maxWidth * 0.08,
                            height: constraints.maxWidth * 0.08,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/icons/back.png'),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(profileRoute);
                          },
                          child: Container(
                            width: constraints.maxWidth * 0.14,
                            height: constraints.maxWidth * 0.07,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/icons/profile.png'),
                              ),
                            ),
                          ),
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
                          Navigator.of(context).pushNamed(diagnoseVerbalRoute);
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
        ),
      ),
    );
  }
}
