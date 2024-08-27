import 'dart:convert';
import 'package:calcpal/enums/disorder_types.dart';
import 'package:calcpal/models/auth_response.dart';
import 'package:calcpal/models/sign_up.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UserService {
  // RETRIEVE THE BASE URL FROM ENVIRONMENT VARIABLES
  final String _baseUrl = dotenv.env['USER_BASE_URL'] ?? '';

  // COMMON SERVICE HANDLE HTTP RESPONSE
  final CommonService _commonService = CommonService();

  // SUBMIT THE SIGN-UP DATA TO THE SERVER FOR REGISTRATION
  Future<bool> signUp(SignUp signUp) async {
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
      _commonService.handleHttpResponse(
          response,
          'Sign-up successful! Please check your email to verify your account before logging in.',
          {
            409:
                'Email already in use. Please log in or use a different email.',
            403:
                'Invalid email address. Please provide a valid email to proceed.',
            500: 'Error sending activation email. Please try again later.'
          });

      return response.statusCode == 200 || response.statusCode == 201;
    } on http.ClientException {
      _commonService.handleNetworkError();
      return false;
    } catch (e) {
      _commonService.handleException(e);
      return false;
    }
  }

  // SUBMIT THE DATA TO THE SERVER FOR LOGIN
  Future<AuthResponse?> login(String email, String password) async {
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
      _commonService
          .handleHttpResponse(response, 'Login successful! Welcome back.', {
        401: 'Incorrect password. Please check and try again.',
        403:
            'Your account is not activated. Please check your email and verify your account.',
        404: 'No user found with the provided email address.',
        500: 'Error sending activation email. Please try again later.',
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // DECODE JSON RESPONSE
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return AuthResponse.fromJson(jsonResponse);
      }
    } on http.ClientException {
      _commonService.handleNetworkError();
    } catch (e) {
      _commonService.handleException(e);
    }
    return null;
  }

  // SUBMIT THE DATA TO THE SERVER FOR NEW TOKEN
  Future<AuthResponse?> generateNewToken(String refreshToken) async {
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
      _commonService.handleHttpResponse(
          response, 'Authentication successful. New tokens have been issued.', {
        400: 'Refresh token is invalid or expired. Please log in again.',
        403:
            'Your account is not activated. Please activate your account to proceed.',
        404:
            'User account not found. Please check your email or register a new account.',
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // DECODE JSON RESPONSE
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return AuthResponse.fromJson(jsonResponse);
      }
    } on http.ClientException {
      _commonService.handleNetworkError();
    } catch (e) {
      _commonService.handleException(e);
    }
    return null;
  }

  // LOG OUT THE USER BY SENDING A REQUEST TO THE SERVER
  Future<bool> logout(String accessToken) async {
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
      _commonService.handleHttpResponse(response,
          'You\'ve been successfully logged out. See you next time!', {
        400: 'Invalid logout request',
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on http.ClientException {
      _commonService.handleNetworkError();
    } catch (e) {
      _commonService.handleException(e);
    }
    return false;
  }

// SENDS AN OTP TO THE PROVIDED EMAIL ADDRESS.
  Future<bool> sendOTP(String email) async {
    final url = Uri.parse('$_baseUrl/user/reset-password-otp?email=$email');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // HANDLE HTTP RESPONSE
      _commonService.handleHttpResponse(
          response,
          'A password reset email has been sent. Please check your inbox for further instructions.',
          {
            404: 'No account found with the provided email.',
            500:
                'An error occurred while sending the reset email. Please try again.',
          });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on http.ClientException {
      _commonService.handleNetworkError();
    } catch (e) {
      _commonService.handleException(e);
    }
    return false;
  }

  // VALIDATES THE OTP FOR THE PROVIDED EMAIL ADDRESS.
  Future<bool> validatOTP(String email, String otpString) async {
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
      _commonService
          .handleHttpResponse(response, 'OTP validated successfully.', {
        400: 'The OTP provided is incorrect. Please try again.',
        404: 'No account found with the provided email.',
        410: 'The OTP has expired. Please request a new one.',
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on http.ClientException {
      _commonService.handleNetworkError();
    } catch (e) {
      _commonService.handleException(e);
    }
    return false;
  }

  // RESETS THE PASSWORD FOR THE PROVIDED EMAIL ADDRESS.
  Future<bool> resetPassword(String email, String password) async {
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
      _commonService.handleHttpResponse(
          response, 'Your password has been reset successfully.', {
        404: 'No account found with the provided email.',
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on http.ClientException {
      _commonService.handleNetworkError();
    } catch (e) {
      _commonService.handleException(e);
    }
    return false;
  }

  // UPDATES THE DISORDER TYPE FOR THE USER
  Future<bool> updateDisorderType(
      DisorderTypes disorder, String accessToken) async {
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
      _commonService.handleNetworkError();
    } catch (e) {
      _commonService.handleException(e);
    }
    return false;
  }

  // GET THE USER DETAILS
  Future<User?> getUser(String accessToken) async {
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
      _commonService.handleNetworkError();
    } catch (e) {
      _commonService.handleException(e);
    }
    return null;
  }
}
