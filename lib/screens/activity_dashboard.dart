import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityDashboardScreen extends StatefulWidget {
  const ActivityDashboardScreen({super.key});

  @override
  State<ActivityDashboardScreen> createState() =>
      _ActivityDashboardScreenState();
}

class _ActivityDashboardScreenState extends State<ActivityDashboardScreen> {
  // VARIABLES TO HOLD DISORDER TYPES
  late List<String> types;
  // MAP TO ASSOCIATE TYPES WITH ROUTE NAMES
  final Map<String, String> _routeNames = {
    'Verbal': activityVerbalRoute,
    'Lexical': activityLexicalRoute,
    'operational': activityOperationalRoute,
    'ideognostic': activityIdeognosticRoute,
    'graphical': activityGraphicalRoute,
    'practognostic': activityPractognosticRoute,
    'visualSpatial': activitySequentialRoute,
    'sequential': activityVisualSpatialRoute,
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
    _dashboardFuture = _loadDashboard();
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
      _toastService.errorToast("Access token not available. Please log in.");
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
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return ListView.builder(
                  itemCount: types.length,
                  itemBuilder: (context, index) {
                    final type = types[index];
                    final routeName = _routeNames[type] ?? mainDashboardRoute;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(routeName);
                        },
                        child: Text(type),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
