import 'package:calcpal/constants/routes.dart';
import 'package:calcpal/main.dart';
import 'package:calcpal/models/update_user.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/services/user_service.dart';
import 'package:calcpal/widgets/date_input.dart';
import 'package:calcpal/widgets/normal_button.dart';
import 'package:calcpal/widgets/normal_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  // VARIABLES TO TRACK STATE
  static bool isUpdating = false;
  static int selectedToggle = 0;
  // DEFAULT SELECTED LANGUAGE
  static String selectedLanguage = 'English';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // TEXT EDITING CONTROLLERS FOR FORM FIELDS
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _iqScoreController = TextEditingController();

  // INITIALIZING THE USER SERVICE
  final UserService _userService = UserService();
  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

  // FUTURE FOR LOADING INITIAL DETAILS
  late Future<void> _initialDetails;

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
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _initialDetails = _loadDetails();
  }

  @override
  void dispose() {
    // DISPOSE CONTROLLERS TO FREE UP RESOURCES
    _userNameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _ageController.dispose();
    _iqScoreController.dispose();

    // FORCE LANDSCAPE ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  // METHOD TO LOAD INITIAL DETAILS
  Future<void> _loadDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken != null) {
      User? user = await _userService.getUser(accessToken, context);

      if (user != null) {
        _userNameController.text = user.name;
        _emailController.text = user.email;
        _birthdayController.text = user.birthday;
        _ageController.text = user.age.toString();
        if (user.iqScore != null) {
          _iqScoreController.text = user.iqScore.toString();
        }
      } else {
        _handleErrorAndRedirect(
            AppLocalizations.of(context)!.commonMessagesUserInformationError);
        return;
      }
    } else {
      _handleErrorAndRedirect(
          AppLocalizations.of(context)!.commonMessagesAccessTokenError);
      return;
    }

    // SET THE SELECTED LANGUAGE BASED ON THE STORED LANGUAGE CODE
    final languageCode = prefs.getString('language_code') ?? 'en';
    ProfileScreen.selectedLanguage =
        CommonService.getLanguageFromCode(languageCode);
  }

  // HANDLER FOR THE UPDATE PROCESS
  Future<void> _update() async {
    try {
      setState(() => ProfileScreen.isUpdating = true);

      final String username = _userNameController.text;
      final String birthday = _birthdayController.text;

      if (username.isEmpty) {
        _toastService.errorToast(
            AppLocalizations.of(context)!.profileMessagesUpdateDetailsError1);
      } else if (birthday.isEmpty) {
        _toastService.errorToast(
            AppLocalizations.of(context)!.profileMessagesUpdateDetailsError2);
      } else {
        final prefs = await SharedPreferences.getInstance();
        final accessToken = prefs.getString('access_token');

        if (accessToken != null) {
          _userService.updateUser(accessToken,
              UpdateUser(name: username, birthday: birthday), context);
        } else {
          _handleErrorAndRedirect(
              AppLocalizations.of(context)!.commonMessagesAccessTokenError);
          return;
        }
      }
    } catch (e) {
      developer.log(e.toString());
      setState(() => ProfileScreen.isUpdating = false);
    } finally {
      setState(() => ProfileScreen.isUpdating = false);
    }
  }

  // CHANGES THE APP LANGUAGE TO BASED ON THE SELECTED VALUE.
  Future<void> _switchLanguage(String? newValue) async {
    if (newValue != null) {
      String languageCode;

      switch (newValue) {
        case 'English':
          languageCode = 'en';
          break;
        case 'සිංහල':
          languageCode = 'si';
          break;
        case 'தமிழ்':
          languageCode = 'ta';
          break;
        default:
          languageCode = 'en';
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);

      setState(() {
        ProfileScreen.selectedLanguage = newValue;
        Locale newLocale = Locale(languageCode);
        MyApp.setLocale(context, newLocale);
      });
    }
  }

  // FUNCTION TO SHOW ERROR TOAST WHEN ATTEMPTING TO EDIT A LOCKED FIELD
  Future<void> _notEditableError() async {
    _toastService.warningToast(
        AppLocalizations.of(context)!.profileMessagesNotEditableError);
  }

  // FUNCTION TO HANDLE ERRORS AND REDIRECT TO LOGIN PAGE
  void _handleErrorAndRedirect(String message) {
    _toastService.warningToast(message);
    Navigator.of(context).pushNamedAndRemoveUntil(
      loginRoute,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildToggleButtons(
                      constraints), // TOGGLE BUTTONS FOR SECTIONS
                  Expanded(
                    child: ProfileScreen.selectedToggle == 0
                        ? _buildDetailsSection() // DETAILS SECTION
                        : _buildSettingsSection(), // SETTINGS SECTION
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // METHOD TO BUILD APP BAR
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        AppLocalizations.of(context)!.profileTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
      backgroundColor: Colors.black,
      elevation: 4,
      centerTitle: true,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }

  // METHOD TO BUILD TOGGLE BUTTONS
  Widget _buildToggleButtons(BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: ToggleButtons(
        isSelected: [
          ProfileScreen.selectedToggle == 0,
          ProfileScreen.selectedToggle == 1
        ],
        onPressed: (int index) {
          setState(() {
            ProfileScreen.selectedToggle = index;
          });
        },
        color: Colors.black,
        selectedColor: Colors.white,
        fillColor: Colors.black,
        borderWidth: 2.0,
        borderColor: Colors.black,
        selectedBorderColor: Colors.black,
        borderRadius: BorderRadius.circular(8.0),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.15,
            ),
            child: Text(
              AppLocalizations.of(context)!.profileToggleButton1,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.15,
            ),
            child: Text(
              AppLocalizations.of(context)!.profileToggleButton2,
            ),
          ),
        ],
      ),
    );
  }

  // METHOD TO BUILD GENERAL DETAILS SECTION
  Widget _buildDetailsSection() {
    return FutureBuilder(
      future: _initialDetails,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitCubeGrid(
                  color: Colors.black,
                  size: 80.0,
                ),
                SizedBox(height: 160.0),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 8.0),
                  _buildInputLabel(
                      AppLocalizations.of(context)!.profileUserName),
                  const SizedBox(height: 4.0),
                  NormalInput(
                    placeholderText: AppLocalizations.of(context)!
                        .profileUserNamePlaceholder,
                    iconPath: 'assets/icons/user.svg',
                    normalController: _userNameController,
                  ), // USER NAME INPUT
                  const SizedBox(height: 16.0),
                  _buildInputLabel(AppLocalizations.of(context)!.profileEmail),
                  const SizedBox(height: 4.0),
                  GestureDetector(
                    onTap: _notEditableError,
                    child: NormalInput(
                      placeholderText:
                          AppLocalizations.of(context)!.profileEmailPlaceholder,
                      iconPath: 'assets/icons/email.svg',
                      normalController: _emailController,
                      lockable: true,
                    ),
                  ), // EMAIL INPUT
                  const SizedBox(height: 16.0),
                  _buildInputLabel(
                      AppLocalizations.of(context)!.profileBirthday),
                  const SizedBox(height: 4.0),
                  DateInput(
                    placeholderText: AppLocalizations.of(context)!
                        .profileBirthdayPlaceholder,
                    iconPath: 'assets/icons/cake.svg',
                    dateController: _birthdayController,
                  ), // BIRTHDAY INPUT
                  const SizedBox(height: 16.0),
                  _buildInputLabel(AppLocalizations.of(context)!.profileAge),
                  const SizedBox(height: 4.0),
                  GestureDetector(
                    onTap: _notEditableError,
                    child: NormalInput(
                      placeholderText:
                          AppLocalizations.of(context)!.profileAgePlaceholder,
                      iconPath: 'assets/icons/age.svg',
                      normalController: _ageController,
                      lockable: true,
                    ),
                  ), // AGE INPUT
                  if (_iqScoreController.text.isNotEmpty) ...[
                    const SizedBox(height: 16.0),
                    _buildInputLabel(
                        AppLocalizations.of(context)!.profileIQScore),
                    const SizedBox(height: 4.0),
                    GestureDetector(
                      onTap: _notEditableError,
                      child: NormalInput(
                        placeholderText: AppLocalizations.of(context)!
                            .profileIQScorePlaceholder,
                        iconPath: 'assets/icons/score.svg',
                        normalController: _iqScoreController,
                        lockable: true,
                      ),
                    ), // IQ SCORE INPUT
                  ],
                  const SizedBox(height: 28.0),
                  NormalButton(
                    buttonText:
                        AppLocalizations.of(context)!.profileUpdateButtonText,
                    isLoading: ProfileScreen.isUpdating,
                    onPressed: _update,
                    height: 54.0,
                  ), // UPDATE BUTTON
                  const SizedBox(height: 28.0),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  // METHOD TO BUILD SETTINGS SECTION
  Widget _buildSettingsSection() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 8.0),
            _buildInputLabel(
                AppLocalizations.of(context)!.profileSelectLanguage),
            const SizedBox(height: 4.0),
            _buildLanguageDropdown(ProfileScreen.selectedLanguage),
          ],
        ),
      ),
    );
  }

  // METHOD TO BUILD LANGUAGE DROPDOWN
  Widget _buildLanguageDropdown(String selectedLanguage) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white, // BACKGROUND COLOR FOR DROPDOWN
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.black, width: 2.0),
          ),
          child: DropdownButton<String>(
            value: selectedLanguage,
            icon: const Icon(Icons.arrow_downward, color: Colors.black),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.black, fontSize: 18),
            dropdownColor: Colors.white, // DROPDOWN MENU BACKGROUND COLOR
            underline: Container(), // REMOVE UNDERLINE
            isExpanded: true, // MAKE DROPDOWN FULL-WIDTH
            onChanged: (String? newValue) {
              _switchLanguage(newValue);
            },
            items: <String>['English', 'සිංහල', 'தமிழ்']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    // DISPLAY FLAG ICON NEXT TO LANGUAGE NAME
                    Image.asset(
                      _getFlagIcon(value),
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 8.0),
                    Text(value, style: const TextStyle(color: Colors.black)),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // FUNCTION TO RETURN FLAG ICON PATH BASED ON LANGUAGE
  String _getFlagIcon(String language) {
    switch (language) {
      case 'English':
        return 'assets/icons/united-states.png'; // PATH TO USA FLAG ICON
      case 'සිංහල':
        return 'assets/icons/sri-lanka.png'; // PATH TO SRI LANKA FLAG ICON
      case 'தமிழ்':
        return 'assets/icons/india.png'; // PATH TO INDIA FLAG ICON
      default:
        return 'assets/icon/united-states.png'; // DEFAULT FLAG ICON PATH
    }
  }

  // METHOD TO BUILD INPUT LABELS
  Widget _buildInputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
