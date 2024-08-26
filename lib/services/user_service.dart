import 'dart:convert';
import 'package:calcpal/enums/disorder.dart';
import 'package:calcpal/models/auth_response.dart';
import 'package:calcpal/models/sign_up.dart';
import 'package:calcpal/models/user.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UserService {
  // RETRIEVE THE BASE URL FROM ENVIRONMENT VARIABLES
  final String _baseUrl = dotenv.env['USER_BASE_URL'] ?? '';

  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

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
      _handleHttpResponse(
        response,
        'Registration successful! Please verify your email before logging in.',
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on http.ClientException {
      _handleNetworkError();
      return false;
    } catch (e) {
      _handleException(e);
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
      _handleHttpResponse(
        response,
        'Login successful! Welcome back.',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // DECODE JSON RESPONSE
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return AuthResponse.fromJson(jsonResponse);
      }
    } on http.ClientException {
      _handleNetworkError();
    } catch (e) {
      _handleException(e);
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
      _handleHttpResponse(
        response,
        'Authentication was successful using the refresh token.',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // DECODE JSON RESPONSE
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return AuthResponse.fromJson(jsonResponse);
      }
    } on http.ClientException {
      _handleNetworkError();
    } catch (e) {
      _handleException(e);
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
      _handleHttpResponse(
        response,
        'Logout successful. You have been logged out.',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on http.ClientException {
      _handleNetworkError();
    } catch (e) {
      _handleException(e);
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
      _handleHttpResponse(
        response,
        'Forgot password email sent successfully',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on http.ClientException {
      _handleNetworkError();
    } catch (e) {
      _handleException(e);
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
      _handleHttpResponse(
        response,
        'User OTP validated successfully',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on http.ClientException {
      _handleNetworkError();
    } catch (e) {
      _handleException(e);
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
      _handleHttpResponse(
        response,
        'Password reset successfully',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on http.ClientException {
      _handleNetworkError();
    } catch (e) {
      _handleException(e);
    }
    return false;
  }

  // UPDATES THE DISORDER TYPE FOR THE USER
  Future<bool> updateDisorderType(Disorder disorder, String accessToken) async {
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

      // HANDLE HTTP RESPONSE
      _handleHttpResponse(
        response,
        'Disorder types updated successfully',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on http.ClientException {
      _handleNetworkError();
    } catch (e) {
      _handleException(e);
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
      _handleNetworkError();
    } catch (e) {
      _handleException(e);
    }
    return null;
  }

  // HANDLE HTTP RESPONSE
  void _handleHttpResponse(http.Response response, String successMessage) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      _toastService.successToast(successMessage);
    } else {
      if (response.body.isNotEmpty) {
        _toastService.errorToast(response.body);
      } else if (response.body.isEmpty) {
        _toastService.errorToast(
          'An unexpected error occurred. Please try again later.',
        );
      }
    }
  }

  // HANDLE NETWORK ERRORS
  void _handleNetworkError() {
    _toastService.errorToast(
      'Network error occurred. Please check your connection.',
    );
  }

  // HANDLE OTHER EXCEPTIONS
  void _handleException(dynamic e) {
    _toastService.errorToast(
      'An unexpected error occurred: ${e.toString()}',
    );
  }
}
