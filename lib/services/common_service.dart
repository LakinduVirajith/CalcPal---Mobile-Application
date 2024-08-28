import 'package:calcpal/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class CommonService {
  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

  // RETURNS THE LANGUAGE CODE FOR THE GIVEN LANGUAGE NAME.
  static String getLanguageCode(String language) {
    switch (language) {
      case 'English':
        return 'en-US';
      case 'සිංහල':
        return 'si-LK';
      case 'தமிழ்':
        return 'ta-IN';
      default:
        return 'en-US';
    }
  }

  // METHOD TO GET LANGUAGE FROM CODE TO API
  static String getLanguageForAPI(String language) {
    switch (language) {
      case 'en-US':
        return 'English';
      case 'si':
        return 'Sinhala';
      case 'ta':
        return 'Tamil';
      default:
        return 'English';
    }
  }

  // METHOD TO GET LANGUAGE FROM CODE
  static String getLanguageFromCode(String code) {
    switch (code) {
      case 'en-US':
        return 'English';
      case 'si':
        return 'සිංහල';
      case 'ta':
        return 'தமிழ்';
      default:
        return 'English';
    }
  }

  // HANDLE HTTP RESPONSE
  void handleHttpResponse(http.Response response, BuildContext context,
      [String? successMessage, Map<int, String>? errorMessages]) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (successMessage != null) {
        _toastService.successToast(successMessage);
      }
    } else {
      final errorMessage = errorMessages?[response.statusCode] ??
          AppLocalizations.of(context)!.commonServiceResponseError;
      _toastService.errorToast('${response.statusCode}: $errorMessage');
    }
  }

  // HANDLE NETWORK ERRORS
  void handleNetworkError(BuildContext context) {
    _toastService.errorToast(
      AppLocalizations.of(context)!.commonServiceNetworkError,
    );
  }

  // HANDLE OTHER EXCEPTIONS
  void handleException(dynamic e, BuildContext context) {
    _toastService.errorToast(
      '${AppLocalizations.of(context)!.commonServiceOtherError}: ${e.toString()}',
    );
  }
}
