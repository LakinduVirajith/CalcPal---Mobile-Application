import 'package:calcpal/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActivityDashboardScreen extends StatefulWidget {
  const ActivityDashboardScreen({super.key});

  @override
  State<ActivityDashboardScreen> createState() =>
      _ActivityDashboardScreenState();
}

class _ActivityDashboardScreenState extends State<ActivityDashboardScreen> {
  // FUTURE THAT HOLDS THE STATE OF THE DASHBOARD LOADING PROCESS
  late Future<void> _dashboardFuture;

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
        systemNavigationBarColor: Colors.black,
      ),
    );

    // LOADING QUESTION DATA
    _dashboardFuture = _loadDashboard();
  }

  // FUNCTION LOAD THE DASHBOARD DATA
  Future<void> _loadDashboard() async {
    // WAIT FOR 500 MILLISECONDS
    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.of(context).pushNamed(activityVerbalRoute);
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
              return Container();
            }),
      ),
    );
  }
}
