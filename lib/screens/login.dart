import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/models/auth_response.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:calcpal/widgets/login_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _initializeServices();
  }

  @override
  void dispose() {
    // DISPOSE CONTROLLERS TO FREE UP RESOURCES
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // INITIALIZE SHARED PREFERENCES
  Future<void> _initializeServices() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // HANDLER FOR THE LOGIN PROCESS
  Future<void> _login() async {
    try {
      setState(() {
        LoginScreen.isLoading = true;
      });

      final String username = _userNameController.text;
      final String password = _passwordController.text;

      if (username.isEmpty || password.isEmpty) {
        _toastService.errorToast("Please fill in all fields.");
      } else {
        // CALL THE SIGN-UP SERVICE
        final AuthResponse? authResponse = await _userService.login(
          username,
          password,
        );

        if (authResponse != null) {
          print(authResponse);
          // STORE TOKEN IN SHAREDPREFERENCES
          await _prefs.setString('user-email', username);
          await _prefs.setString('access_token', authResponse.accessToken);
          await _prefs.setString('refresh_token', authResponse.refreshToken);

          Navigator.of(context).pushNamedAndRemoveUntil(
            mainDashboardRoute,
            (route) => false,
          );
        }
      }
    } catch (e) {
      setState(() {
        LoginScreen.isLoading = false;
      });
    } finally {
      setState(() {
        LoginScreen.isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // FORCE PORTRAIT ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      body: SafeArea(
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
