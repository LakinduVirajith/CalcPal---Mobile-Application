import 'dart:convert';
import 'package:calcpal/models/auth_response.dart';
import 'package:calcpal/models/sign_up.dart';
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
        {
          404: 'Resource not found. Please check the details and try again.',
          409: 'Email already in use. Please log in or use a different email.',
          500: 'Server error occurred. Please try again later.',
        },
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
        {
          403:
              'Your account is not activated. Please verify your email to activate your account.',
          404: 'Resource not found. Please check the details and try again.',
          500: 'Server error occurred. Please try again later.',
        },
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
        'Login successful! Welcome back.',
        {
          400:
              'The token you provided is invalid. Please check the token and try again.',
          404: 'Resource not found. Please check the details and try again.',
          500: 'Server error occurred. Please try again later.',
        },
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
        {
          400: 'Invalid logout request.',
          404: 'Resource not found. Please check the details and try again.',
          500: 'Server error occurred. Please try again later.',
        },
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

  // HANDLE HTTP RESPONSE
  void _handleHttpResponse(http.Response response, String successMessage,
      Map<int, String> errorMessages) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      _toastService.successToast(successMessage);
    } else {
      final errorMessage =
          errorMessages[response.statusCode] ?? 'An unexpected error occurred.';
      _toastService.errorToast(errorMessage);
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