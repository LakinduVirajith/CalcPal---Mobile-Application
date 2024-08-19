import 'package:calcpal/constants/routes.dart';
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
                          onTap: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              loginRoute,
                              (route) => false,
                            );
                          },
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
