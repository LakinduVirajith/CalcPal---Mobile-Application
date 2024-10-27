import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/models/auth_response.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:calcpal/widgets/login_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static bool isLoading = false;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // CONTROLLERS FOR FORM FIELDS
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // INITIALIZING THE USER SERVICE
  final UserService _userService = UserService();
  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();
  // SHARED PREFERENCES INSTANCE
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    // FORCE PORTRAIT ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // SET CUSTOM STATUS BAR COLOR
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _initializeServices();
  }

  @override
  void dispose() {
    super.dispose();
    // DISPOSE CONTROLLERS TO FREE UP RESOURCES
    _userNameController.dispose();
    _passwordController.dispose();

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
  }

  // INITIALIZE SHARED PREFERENCES
  Future<void> _initializeServices() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // HANDLER FOR THE LOGIN PROCESS
  Future<void> _login() async {
    try {
      setState(() => LoginScreen.isLoading = true);

      final String username = _userNameController.text;
      final String password = _passwordController.text;

      if (username.isEmpty || password.isEmpty) {
        _toastService
            .errorToast(AppLocalizations.of(context)!.loginMessagesFillAll);
      } else {
        // CALL THE SIGN-UP SERVICE
        final AuthResponse? authResponse =
            await _userService.login(username, password, context);

        if (authResponse != null) {
          // STORE TOKEN IN SHAREDPREFERENCES
          await _prefs.setString('user-email', username);
          await _prefs.setString('access_token', authResponse.accessToken);
          await _prefs.setString('refresh_token', authResponse.refreshToken);

          User? user =
              await _userService.getUser(authResponse.accessToken, context);
          if (user?.iqScore == null) {
            Navigator.of(context).pushNamed(iqTestRoute);
          } else if (user!.disorderTypes != null) {
            Navigator.of(context).pushNamed(activityDashboardRoute);
          } else {
            Navigator.of(context).pushNamed(mainDashboardRoute);
          }
        }
      }
    } catch (e) {
      setState(() => LoginScreen.isLoading = false);
    } finally {
      setState(() => LoginScreen.isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Container(
              // LOGIN BACKGROUND
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/login_background.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'CalcPal',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Aclonica',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              // LOGIN AREA
              left: 0,
              right: 0,
              bottom: 0,
              child: LoginArea(
                userNameController: _userNameController,
                passwordController: _passwordController,
                isLoading: LoginScreen.isLoading,
                onPressed: _login,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
