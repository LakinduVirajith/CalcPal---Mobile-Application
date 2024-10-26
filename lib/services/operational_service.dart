import 'dart:convert';
import 'package:calcpal/models/activity_result.dart';
import 'package:calcpal/models/diagnosis_result_op.dart';
import 'package:flutter/material.dart';
import 'package:calcpal/models/diagnosis.dart';
import 'package:calcpal/models/flask_diagnosis_result.dart';
import 'package:calcpal/models/operational_question.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:calcpal/services/common_service.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class OperationalService {
  final String _baseUrl = dotenv.env['OPERATIONAL_BASE_URL'] ?? '';
  final String _modelBaseUrl = dotenv.env['DIAGNOSIS_MODELS_BASE_URL'] ?? '';

  // COMMON SERVICE HANDLE HTTP RESPONSE
  final CommonService _commonService = CommonService();

  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

  // Fetch a question
  Future<OperationalQuestion?> fetchOperationalQuestion(
      int questionNumber) async {
    final url = Uri.parse('$_baseUrl/operational/questionbank/$questionNumber');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return OperationalQuestion.fromJson(jsonDecode(response.body));
      } else {
        _toastService.errorToast('Failed to load question');
        return null;
      }
    } on http.ClientException {
      _toastService
          .errorToast('Network error occurred. Please check your connection.');
      return null;
    } catch (e) {
      _toastService.errorToast('An unexpected error occurred.');
      return null;
    }
  }

  // Submit a diagnosis result
  Future<bool> addDiagnosisResult(DiagnosisResultOp result) async {
    final url = Uri.parse('$_baseUrl/operational/diagnosis/');

    try {
      final body = jsonEncode(result.toJson());

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(response.statusCode);
        return false;
      }
    } on http.ClientException {
      _toastService
          .errorToast('Network error occurred. Please check your connection.');
      return false;
    } catch (e) {
      _toastService.errorToast('An unexpected error occurred.');
      return false;
    }
  }

  // Fetch a diagnosis result
  Future<FlaskDiagnosisResult?> getDiagnosisResult(
      Diagnosis diagnosis, BuildContext context) async {
    final url = Uri.parse('$_modelBaseUrl/operational');

    try {
      final body = jsonEncode(diagnosis.toJson());

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // DECODE JSON RESPONSE
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final result = FlaskDiagnosisResult.fromJson(jsonResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return result;
      } else {
        developer.log(result.error!);
      }
    } on http.ClientException {
      _commonService.handleNetworkError(context);
    } catch (e) {
      _commonService.handleException(e, context);
    }

    return null;
  }

  //Activities Handlers

  // Submit a activity result
  Future<bool> addActivityResult(ActivityResult result) async {
    final url = Uri.parse('$_baseUrl/operational/activities/');

    try {
      final body = jsonEncode(result.toJson());

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(response.statusCode);
        return false;
      }
    } on http.ClientException {
      _toastService
          .errorToast('Network error occurred. Please check your connection.');
      return false;
    } catch (e) {
      _toastService.errorToast('An unexpected error occurred.');
      return false;
    }
  }

  // Fetch all activity results for a given user email
  Future<List<ActivityResult>?> getActivityResultsByEmailAndActivity(
      String userEmail, String activity, BuildContext context) async {
    String email = userEmail.replaceAll('@', '%40');
    final url = Uri.parse(
        '$_baseUrl/operational/activities/level?email=$email&activityname=$activity');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Parse the JSON response into a list of ActivityResult objects
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        final List<ActivityResult> results =
            jsonResponse.map((json) => ActivityResult.fromJson(json)).toList();

        return results;
      } else {
        developer
            .log('Failed to fetch activity results: ${response.statusCode}');
      }
    } on http.ClientException {
      _commonService.handleNetworkError(context);
    } catch (e) {
      _commonService.handleException(e, context);
    }

    return null;
  }
}
