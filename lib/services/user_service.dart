import 'dart:convert';
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

      // HANDLE SUCCESSFUL REGISTRATION
      if (response.statusCode == 200 || response.statusCode == 201) {
        _toastService.successToast(
          'Registration successful! Please verify your email before logging in.',
        );
        return true;
      } // HANDLE EMAIL CONFLICT
      else if (response.statusCode == 404) {
        _toastService.warningToast(
          'The requested resource was not found.',
        );
        return false;
      } // HANDLE EMAIL CONFLICT
      else if (response.statusCode == 409) {
        _toastService.warningToast(
          'Email already in use. Please log in or use a different email.',
        );
        return false;
      } // HANDLE INTERNAL SERVER ERROR
      else if (response.statusCode == 500) {
        _toastService.errorToast(
          'Server error occurred. Please try again later.',
        );
        return false;
      } // HANDLE OTHER HTTP ERRORS
      else {
        _toastService.errorToast(
          'An unexpected error occurred.',
        );
        return false;
      }
    } // HANDLE NETWORK ERRORS
    on http.ClientException {
      _toastService.errorToast(
        'Network error occurred. Please check your connection.',
      );
      return false;
    }
    // HANDLE OTHER EXCEPTIONS
    catch (e) {
      _toastService.errorToast(
        'An unexpected error occurred.',
      );
      return false;
    }
  }
}
