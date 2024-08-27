import 'package:calcpal/services/toast_service.dart';
import 'package:http/http.dart' as http;

class CommonService {
  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

  // RETURNS THE LANGUAGE CODE FOR THE GIVEN LANGUAGE NAME.
  static String getLanguageCode(String language) {
    switch (language) {
      case 'English':
        return 'en-US';
      case 'Sinhala':
        return 'si-LK';
      case 'Tamil':
        return 'ta-IN';
      default:
        return 'en-US';
    }
  }

  // HANDLE HTTP RESPONSE
  void handleHttpResponse(http.Response response,
      [String? successMessage, Map<int, String>? errorMessages]) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (successMessage != null) {
        _toastService.successToast(successMessage);
      }
    } else {
      final errorMessage = errorMessages?[response.statusCode] ??
          'An unexpected error occurred. Please try again later.';
      _toastService.errorToast('${response.statusCode}: $errorMessage');
    }
  }

  // HANDLE NETWORK ERRORS
  void handleNetworkError() {
    _toastService.errorToast(
      'Network error occurred. Please check your connection.',
    );
  }

  // HANDLE OTHER EXCEPTIONS
  void handleException(dynamic e) {
    _toastService.errorToast(
      'An unexpected error occurred: ${e.toString()}',
    );
  }
}
