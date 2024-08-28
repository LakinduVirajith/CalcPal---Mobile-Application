import 'dart:convert';
import 'package:calcpal/enums/disorder_types.dart';
import 'package:calcpal/models/auth_response.dart';
import 'package:calcpal/models/sign_up.dart';
import 'package:calcpal/models/update_user.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class UserService {
  // RETRIEVE THE BASE URL FROM ENVIRONMENT VARIABLES
  final String _baseUrl = dotenv.env['USER_BASE_URL'] ?? '';

  // COMMON SERVICE HANDLE HTTP RESPONSE
  final CommonService _commonService = CommonService();

  // SUBMIT THE SIGN-UP DATA TO THE SERVER FOR REGISTRATION
  Future<bool> signUp(SignUp signUp, BuildContext context) async {
    final url = Uri.parse('$_baseUrl/user/sign-up');

    try {
      final body = jsonEncode(signUp.toJson());

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // HANDLE HTTP RESPONSE
      _commonService.handleHttpResponse(response, context,
          AppLocalizations.of(context)!.userServiceSignup200, {
        403: AppLocalizations.of(context)!.userServiceSignup403,
        409: AppLocalizations.of(context)!.userServiceSignup409,
        500: AppLocalizations.of(context)!.userServiceSignup500
      });

      return response.statusCode == 200 || response.statusCode == 201;
    } on http.ClientException {
      _commonService.handleNetworkError(context);
      return false;
    } catch (e) {
      _commonService.handleException(e, context);
      return false;
    }
  }

  // SUBMIT THE DATA TO THE SERVER FOR LOGIN
  Future<AuthResponse?> login(
      String email, String password, BuildContext context) async {
    final url = Uri.parse('$_baseUrl/user/login');

    try {
      final body = jsonEncode({
        "email": email,
        "password": password,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // HANDLE HTTP RESPONSE
      _commonService.handleHttpResponse(response, context,
          AppLocalizations.of(context)!.userServiceLogin200, {
        401: AppLocalizations.of(context)!.userServiceLogin401,
        403: AppLocalizations.of(context)!.userServiceLogin403,
        404: AppLocalizations.of(context)!.userServiceLogin404,
        500: AppLocalizations.of(context)!.userServiceLogin500,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // DECODE JSON RESPONSE
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return AuthResponse.fromJson(jsonResponse);
      }
    } on http.ClientException {
      _commonService.handleNetworkError(context);
    } catch (e) {
      _commonService.handleException(e, context);
    }
    return null;
  }

  // SUBMIT THE DATA TO THE SERVER FOR NEW TOKEN
  Future<AuthResponse?> generateNewToken(
      String refreshToken, BuildContext context) async {
    final url = Uri.parse('$_baseUrl/user/refresh-token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: refreshToken,
      );

      // HANDLE HTTP RESPONSE
      _commonService.handleHttpResponse(response, context,
          AppLocalizations.of(context)!.userServiceGenerateNewToken200, {
        400: AppLocalizations.of(context)!.userServiceGenerateNewToken400,
        403: AppLocalizations.of(context)!.userServiceGenerateNewToken403,
        404: AppLocalizations.of(context)!.userServiceGenerateNewToken404,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // DECODE JSON RESPONSE
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return AuthResponse.fromJson(jsonResponse);
      }
    } on http.ClientException {
      _commonService.handleNetworkError(context);
    } catch (e) {
      _commonService.handleException(e, context);
    }
    return null;
  }

  // LOG OUT THE USER BY SENDING A REQUEST TO THE SERVER
  Future<bool> logout(String accessToken, BuildContext context) async {
    final url = Uri.parse('$_baseUrl/user/logout');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      // HANDLE HTTP RESPONSE
      _commonService.handleHttpResponse(response, context,
          AppLocalizations.of(context)!.userServiceLogout200, {
        400: AppLocalizations.of(context)!.userServiceLogout400,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on http.ClientException {
      _commonService.handleNetworkError(context);
    } catch (e) {
      _commonService.handleException(e, context);
    }
    return false;
  }

// SENDS AN OTP TO THE PROVIDED EMAIL ADDRESS.
  Future<bool> sendOTP(String email, BuildContext context) async {
    final url = Uri.parse('$_baseUrl/user/reset-password-otp?email=$email');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // HANDLE HTTP RESPONSE
      _commonService.handleHttpResponse(response, context,
          AppLocalizations.of(context)!.userServiceSendOTP200, {
        404: AppLocalizations.of(context)!.userServiceSendOTP404,
        500: AppLocalizations.of(context)!.userServiceSendOTP500,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on http.ClientException {
      _commonService.handleNetworkError(context);
    } catch (e) {
      _commonService.handleException(e, context);
    }
    return false;
  }

  // VALIDATES THE OTP FOR THE PROVIDED EMAIL ADDRESS.
  Future<bool> validatOTP(
      String email, String otpString, BuildContext context) async {
    final otp = int.tryParse(otpString);
    final url = Uri.parse(
        '$_baseUrl/user/reset-password-validation?email=$email&otp=$otp');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // HANDLE HTTP RESPONSE
      _commonService.handleHttpResponse(response, context,
          AppLocalizations.of(context)!.userServiceValidateOTP200, {
        400: AppLocalizations.of(context)!.userServiceValidateOTP400,
        404: AppLocalizations.of(context)!.userServiceValidateOTP404,
        410: AppLocalizations.of(context)!.userServiceValidateOTP410,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on http.ClientException {
      _commonService.handleNetworkError(context);
    } catch (e) {
      _commonService.handleException(e, context);
    }
    return false;
  }

  // RESETS THE PASSWORD FOR THE PROVIDED EMAIL ADDRESS.
  Future<bool> resetPassword(
      String email, String password, BuildContext context) async {
    final url = Uri.parse('$_baseUrl/user/reset-password');

    try {
      final body = jsonEncode({
        "email": email,
        "password": password,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // HANDLE HTTP RESPONSE
      _commonService.handleHttpResponse(response, context,
          AppLocalizations.of(context)!.userServiceResetPassword200, {
        404: AppLocalizations.of(context)!.userServiceResetPassword404,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on http.ClientException {
      _commonService.handleNetworkError(context);
    } catch (e) {
      _commonService.handleException(e, context);
    }
    return false;
  }

  // UPDATES THE DISORDER TYPE FOR THE USER
  Future<bool> updateDisorderType(
      DisorderTypes disorder, String accessToken, BuildContext context) async {
    final url =
        Uri.parse('$_baseUrl/user/update/disorder?disorder=${disorder.name}');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on http.ClientException {
      _commonService.handleNetworkError(context);
    } catch (e) {
      _commonService.handleException(e, context);
    }
    return false;
  }

  // GET THE USER DETAILS
  Future<User?> getUser(String accessToken, BuildContext context) async {
    final url = Uri.parse('$_baseUrl/user/details');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // DECODE JSON RESPONSE
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return User.fromJson(jsonResponse);
      }
    } on http.ClientException {
      _commonService.handleNetworkError(context);
    } catch (e) {
      _commonService.handleException(e, context);
    }
    return null;
  }

  // UPDATE THE USER DETAILS
  Future<bool> updateUser(
      String accessToken, UpdateUser updateUser, BuildContext context) async {
    final url = Uri.parse('$_baseUrl/user/update');

    try {
      final body = jsonEncode(updateUser.toJson());

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: body,
      );

      // HANDLE HTTP RESPONSE
      _commonService.handleHttpResponse(response, context,
          AppLocalizations.of(context)!.userServiceUpdateUser200, {
        404: AppLocalizations.of(context)!.userServiceUpdateUser404,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on http.ClientException {
      _commonService.handleNetworkError(context);
    } catch (e) {
      _commonService.handleException(e, context);
    }
    return false;
  }
}
