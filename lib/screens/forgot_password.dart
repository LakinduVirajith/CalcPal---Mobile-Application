import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:calcpal/widgets/normal_button.dart';
import 'package:calcpal/widgets/normal_input.dart';
import 'package:calcpal/widgets/otp_box.dart';
import 'package:calcpal/widgets/password_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  // STATE VARIABLES FOR OTP AND PASSWORD RESET PROCESS
  static bool isSendingOTP = false;
  static bool isOTPSent = false;
  static bool isValidatingOTP = false;
  static bool isOTPValidated = false;
  static bool isResetting = false;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  // CONTROLLERS FOR FORM FIELDS
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _inputOTP1Controller = TextEditingController();
  final TextEditingController _inputOTP2Controller = TextEditingController();
  final TextEditingController _inputOTP3Controller = TextEditingController();
  final TextEditingController _inputOTP4Controller = TextEditingController();

  // INITIALIZING THE USER SERVICE
  final UserService _userService = UserService();
  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

  // ANIMATION CONTROLLER
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // INITIALIZE THE ANIMATION CONTROLLER
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // DEFINE THE HORIZONTAL SLIDE ANIMATION
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // DEFINE OPACITY ANIMATION IF NEEDED
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didChangeDependencies() {
    // RETRIEVE THE ARGUMENTS PASSED FROM THE PREVIOUS SCREEN
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // INITIALIZE INSTANCE VARIABLES SAFELY
    if (arguments != null && arguments.containsKey('email')) {
      if (arguments['email'].isNotEmpty) {
        _userEmailController.text = arguments['email'];
      }
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // DISPOSE OF CONTROLLERS TO FREE RESOURCES
    _userEmailController.dispose();
    _passwordController.dispose();
    _inputOTP1Controller.dispose();
    _inputOTP2Controller.dispose();
    _inputOTP3Controller.dispose();
    _inputOTP4Controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // SENDS THE OTP TO THE USER'S EMAIL ADDRESS
  Future<void> _sendInstructions() async {
    try {
      setState(() => ForgotPasswordScreen.isSendingOTP = true);

      final String userEmail = _userEmailController.text;
      if (userEmail.isEmpty) {
        _toastService.errorToast(AppLocalizations.of(context)!
            .forgotPasswordMessagesSendInstructionsError1);
      } else {
        // CALL THE USER SERVICE TO SEND THE OTP
        final status = await _userService.sendOTP(userEmail, context);
        if (status) {
          setState(() => ForgotPasswordScreen.isOTPSent = true);
          // START THE ANIMATION
          _animationController.forward();
        }
      }
    } catch (e) {
      _toastService.errorToast(AppLocalizations.of(context)!
          .forgotPasswordMessagesSendInstructionsError2);
    } finally {
      setState(() => ForgotPasswordScreen.isSendingOTP = false);
    }
  }

  // VERIFIES THE OTP ENTERED BY THE USER
  Future<void> _validateOTP() async {
    try {
      setState(() => ForgotPasswordScreen.isValidatingOTP = true);

      final String otp1 = _inputOTP1Controller.text;
      final String otp2 = _inputOTP2Controller.text;
      final String otp3 = _inputOTP3Controller.text;
      final String otp4 = _inputOTP4Controller.text;
      final String userEmail = _userEmailController.text;
      if (otp1.isEmpty || otp2.isEmpty || otp3.isEmpty || otp4.isEmpty) {
        _toastService.errorToast(AppLocalizations.of(context)!
            .forgotPasswordMessagesValidateOTPError1);
      } else {
        final combinedOtp = otp1 + otp2 + otp3 + otp4;
        // CALL THE USER SERVICE TO VALIDATE THE OTP
        final status =
            await _userService.validatOTP(userEmail, combinedOtp, context);
        if (status) {
          setState(() => ForgotPasswordScreen.isOTPValidated = true);
          // START THE ANIMATION
          _animationController.forward();
        }
      }
    } catch (e) {
      _toastService.errorToast(AppLocalizations.of(context)!
          .forgotPasswordMessagesValidateOTPError2);
    } finally {
      setState(() => ForgotPasswordScreen.isValidatingOTP = false);
    }
  }

  // RESETS THE USER'S PASSWORD
  Future<void> _resetPassword() async {
    try {
      setState(() => ForgotPasswordScreen.isResetting = true);

      final String userEmail = _userEmailController.text;
      final String password = _passwordController.text;
      if (userEmail.isEmpty || password.isEmpty) {
        _toastService.errorToast(AppLocalizations.of(context)!
            .forgotPasswordMessagesResetPasswordError1);
      } else {
        // CALL THE USER SERVICE TO RESET THE PASSWORD
        final status =
            await _userService.resetPassword(userEmail, password, context);
        if (status) {
          setState(() => ForgotPasswordScreen.isOTPValidated = true);
          // NAVIGATE TO THE LOGIN ROUTE AND REMOVE ALL PREVIOUS ROUTES
          Navigator.of(context).pushNamed(loginRoute);
        }
      }
    } catch (e) {
      _toastService.errorToast(AppLocalizations.of(context)!
          .forgotPasswordMessagesResetPasswordError2);
    } finally {
      setState(() => ForgotPasswordScreen.isResetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // FORCE PORTRAIT ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.forgotPasswordBackButton,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 4,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!
                          .forgotPasswordForgotPasswordButton,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(AppLocalizations.of(context)!
                      .forgotPasswordInstructionText),
                  const SizedBox(height: 12.0),
                  // EMAIL INPUT FIELD
                  NormalInput(
                    placeholderText: AppLocalizations.of(context)!
                        .forgotPasswordEmailAddress,
                    iconPath: 'assets/icons/email.svg',
                    normalController: _userEmailController,
                    lockable: ForgotPasswordScreen.isOTPSent,
                  ),
                  const SizedBox(height: 18.0),
                  // SEND INSTRUCTIONS BUTTON
                  NormalButton(
                    buttonText: !ForgotPasswordScreen.isOTPSent
                        ? AppLocalizations.of(context)!
                            .forgotPasswordSendInstructionButton
                        : AppLocalizations.of(context)!
                            .forgotPasswordResendInstructionsButton,
                    isLoading: ForgotPasswordScreen.isSendingOTP,
                    onPressed: _sendInstructions,
                  ),
                  const SizedBox(height: 24.0),
                  if (ForgotPasswordScreen.isOTPSent &&
                      !ForgotPasswordScreen.isOTPValidated) ...[
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // OTP INPUT FIELD 1
                                OTPBox(
                                  inputController: _inputOTP1Controller,
                                  width: constraints.maxWidth * 0.16,
                                  height: constraints.maxWidth * 0.16,
                                ),
                                // OTP INPUT FIELD 2
                                OTPBox(
                                  inputController: _inputOTP2Controller,
                                  width: constraints.maxWidth * 0.16,
                                  height: constraints.maxWidth * 0.16,
                                ),
                                // OTP INPUT FIELD 3
                                OTPBox(
                                  inputController: _inputOTP3Controller,
                                  width: constraints.maxWidth * 0.16,
                                  height: constraints.maxWidth * 0.16,
                                ),
                                // OTP INPUT FIELD 4
                                OTPBox(
                                  inputController: _inputOTP4Controller,
                                  width: constraints.maxWidth * 0.16,
                                  height: constraints.maxWidth * 0.16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18.0),
                            // VERIFY OTP BUTTON
                            NormalButton(
                              buttonText: AppLocalizations.of(context)!
                                  .forgotPasswordValidateOTPButton,
                              isLoading: ForgotPasswordScreen.isValidatingOTP,
                              onPressed: _validateOTP,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (ForgotPasswordScreen.isOTPValidated) ...[
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppLocalizations.of(context)!
                                    .forgotPasswordCreatePasswordButton,
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Text(
                              AppLocalizations.of(context)!
                                  .forgotPasswordPasswordText,
                            ),
                            const SizedBox(height: 12.0),
                            // PASSWORD INPUT FIELD
                            PasswordInput(
                              passwordController: _passwordController,
                            ),
                            const SizedBox(height: 18.0),
                            // RESET PASSWORD BUTTON
                            NormalButton(
                              buttonText: AppLocalizations.of(context)!
                                  .forgotPasswordResetPasswordButton,
                              isLoading: ForgotPasswordScreen.isResetting,
                              onPressed: _resetPassword,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
