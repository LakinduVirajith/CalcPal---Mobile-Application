import 'dart:convert';

import 'package:calcpal/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class CommonService {
  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

  // RETURNS THE LANGUAGE CODE FOR THE GIVEN LANGUAGE NAME.
  static String getLanguageCode(String language) {
    switch (language) {
      case 'en':
        return 'en-US';
      case 'si':
        return 'si-LK';
      case 'ta':
        return 'ta-IN';
      default:
        return 'en-US';
    }
  }

  // METHOD TO GET LANGUAGE FROM CODE TO API
  static String getLanguageForAPI(String language) {
    switch (language) {
      case 'en':
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
      case 'en':
        return 'English';
      case 'si':
        return 'සිංහල';
      case 'ta':
        return 'தமிழ்';
      default:
        return 'English';
    }
  }

  // FUNCTION TO DECODE A SINGLE BASE64 ENCODED STRING
  static String decodeString(String encodeValue) {
    try {
      return utf8.decode(base64Decode(encodeValue));
    } catch (e) {
      developer.log('Error decoding answers: ${e.toString()}');
      return '';
    }
  }

  // FUNCTION TO DECODE A LIST OF BASE64 ENCODED STRINGS
  static List<String> decodeList(List<String> encodedList) {
    try {
      return encodedList.map((encoded) => decodeString(encoded)).toList();
    } catch (e) {
      developer.log('Error decoding list of strings: ${e.toString()}');
      return [];
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
    developer.log('An unexpected error occurred: ${e.toString()}');
    _toastService.errorToast(
      '400: ${AppLocalizations.of(context)!.commonServiceOtherError}',
    );
  }
}
