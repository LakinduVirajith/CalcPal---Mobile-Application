import 'package:calcpal/services/toast_service.dart';
import 'package:calcpal/widgets/date_input.dart';
import 'package:calcpal/widgets/normal_button.dart';
import 'package:calcpal/widgets/normal_input.dart';
import 'package:calcpal/widgets/normal_input_lockable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import 'package:flutter_spinkit/flutter_spinkit.dart';

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

  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

  // FUTURE FOR LOADING INITIAL DETAILS
  late Future<void> _initialDetails;

  @override
  void initState() {
    super.initState();
    _initialDetails = _loadDetails();
  }

  // METHOD TO LOAD INITIAL DETAILS
  Future<void> _loadDetails() async {
    _userNameController.text = 'Lakindu';
    _emailController.text = 'lakinduvirajith@gmail.com';
    _birthdayController.text = '200-10-31';
    _ageController.text = '24';
    _iqScoreController.text = '4';

    // TODO: IMPLEMENT LOAD LOGIC HERE
  }

  // HANDLER FOR THE UPDATE PROCESS
  Future<void> _update() async {
    try {
      setState(() => ProfileScreen.isUpdating = true);

      final String username = _userNameController.text;
      final String birthday = _birthdayController.text;

      if (username.isEmpty) {
        _toastService.errorToast("Please enter your username.");
      } else if (birthday.isEmpty) {
        _toastService.errorToast("Please select your birthday.");
      } else {
        // TODO: IMPLEMENT UPDATE LOGIC HERE
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
    setState(() => ProfileScreen.selectedLanguage = newValue!);

    // TODO: IMPLEMENT UPDATE LANGUAGE LOGIC HERE
  }

  // FUNCTION TO SHOW ERROR TOAST WHEN ATTEMPTING TO EDIT A LOCKED FIELD
  Future<void> _notEditableError() async {
    _toastService.warningToast("This field cannot be edited.");
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
        systemNavigationBarColor: Colors.black,
      ),
    );

    // MAIN SCAFFOLD WIDGET
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
      title: const Text(
        'Profile',
        style: TextStyle(
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
            child: const Text('General'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.15,
            ),
            child: const Text('System'),
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
                  _buildInputLabel(' User Name:'),
                  const SizedBox(height: 4.0),
                  NormalInput(
                    placeholderText: 'Name',
                    iconPath: 'assets/icons/user.svg',
                    normalController: _userNameController,
                  ), // USER NAME INPUT
                  const SizedBox(height: 16.0),
                  _buildInputLabel(' Email:'),
                  const SizedBox(height: 4.0),
                  GestureDetector(
                    onTap: _notEditableError,
                    child: NormalInputLockable(
                      placeholderText: 'Email',
                      iconPath: 'assets/icons/email.svg',
                      normalController: _emailController,
                      lockable: true,
                    ),
                  ), // EMAIL INPUT
                  const SizedBox(height: 16.0),
                  _buildInputLabel(' Birthday:'),
                  const SizedBox(height: 4.0),
                  DateInput(
                    placeholderText: 'Birthday',
                    iconPath: 'assets/icons/cake.svg',
                    dateController: _birthdayController,
                  ), // BIRTHDAY INPUT
                  const SizedBox(height: 16.0),
                  _buildInputLabel(' Age:'),
                  const SizedBox(height: 4.0),
                  GestureDetector(
                    onTap: _notEditableError,
                    child: NormalInputLockable(
                      placeholderText: 'Age',
                      iconPath: 'assets/icons/age.svg',
                      normalController: _ageController,
                      lockable: true,
                    ),
                  ), // AGE INPUT
                  if (_iqScoreController.text.isNotEmpty) ...[
                    const SizedBox(height: 16.0),
                    _buildInputLabel(' IQ Score:'),
                    const SizedBox(height: 4.0),
                    GestureDetector(
                      onTap: _notEditableError,
                      child: NormalInputLockable(
                        placeholderText: 'IQ Score',
                        iconPath: 'assets/icons/score.svg',
                        normalController: _iqScoreController,
                        lockable: true,
                      ),
                    ), // IQ SCORE INPUT
                  ],
                  const SizedBox(height: 28.0),
                  NormalButton(
                    buttonText: 'Update',
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
            _buildInputLabel('Select Language:'),
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
            items: <String>['English', 'Sinhala', 'Tamil']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
          ),
        );
      },
    );
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
