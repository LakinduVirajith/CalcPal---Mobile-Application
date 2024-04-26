import 'package:calcpal/screens/diagnose_verbal.dart';
import 'package:calcpal/screens/diagnose_operational.dart';
import 'package:calcpal/screens/diagnose_graphical.dart';
import 'package:calcpal/screens/diagnose_visual_spatial.dart';
import 'package:calcpal/screens/login.dart';
import 'package:calcpal/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double flexTop, flexBottom;

            if (constraints.maxWidth > 1200) {
              flexTop = constraints.maxHeight * 0.25;
              flexBottom = constraints.maxHeight * 0.1;
            } else if (constraints.maxWidth > 700) {
              flexTop = constraints.maxHeight * 0.35;
              flexBottom = constraints.maxHeight * 0.1;
            } else {
              flexTop = constraints.maxHeight * 0.4;
              flexBottom = constraints.maxHeight * 0.15;
            }

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
                // BACK BUTTON
                Positioned(
                  top: constraints.maxHeight * 0.02,
                  left: 0,
                  right: constraints.maxWidth * 0.83,
                  bottom: constraints.maxHeight * 0.82,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/icons/back.png'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // PROFILE
                Positioned(
                  top: constraints.maxHeight * 0.02,
                  left: constraints.maxWidth * 0.75,
                  right: 0,
                  bottom: constraints.maxHeight * 0.82,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: Container(
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
                // DIAGNOSE QUIZ 1
                Positioned(
                  top: flexTop,
                  left: 0,
                  right: constraints.maxWidth * 0.7,
                  bottom: flexBottom,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DiagnoseVerbalScreen(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/diagnose_quiz_1.png'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // DIAGNOSE QUIZ 2
                Positioned(
                  top: flexTop,
                  left: 0,
                  right: constraints.maxWidth * 0.23,
                  bottom: flexBottom,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DiagnoseOperationalScreen(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/diagnose_quiz_2.png'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // DIAGNOSE QUIZ 3
                Positioned(
                  top: flexTop,
                  left: constraints.maxWidth * 0.23,
                  right: 0,
                  bottom: flexBottom,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DiagnoseGraphicalScreen(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/diagnose_quiz_3.png'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // DIAGNOSE QUIZ 4
                Positioned(
                  top: flexTop,
                  left: constraints.maxWidth * 0.7,
                  right: 0,
                  bottom: flexBottom,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DiagnoseVisualSpatialScreen(),
                            ),
                          );
                        },
                        child: Container(
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
