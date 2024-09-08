import 'dart:convert';
import 'package:calcpal/models/diagnosis_result_ideo.dart';
import 'package:flutter/material.dart';
import 'package:calcpal/models/diagnosis.dart';
import 'package:calcpal/models/flask_diagnosis_result.dart';
import 'package:calcpal/models/operational_question.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:calcpal/services/common_service.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class IdeognosticService {
  final String _baseUrl = dotenv.env['IDEOGNOSTIC_BASE_URL'] ?? '';
  final String _modelBaseUrl = dotenv.env['DIAGNOSIS_MODELS_BASE_URL'] ?? '';

  // COMMON SERVICE HANDLE HTTP RESPONSE
  final CommonService _commonService = CommonService();

  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

  // Fetch a question
  Future<OperationalQuestion?> fetchIdeognosticQuestion(
      int questionNumber) async {
    final url = Uri.parse('$_baseUrl/ideognostic/questionbank/$questionNumber');

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
  Future<bool> addDiagnosisResult(DiagnosisResultIdeo result) async {
    final url = Uri.parse('$_baseUrl/ideognostic/diagnosis/');

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
    final url = Uri.parse('$_modelBaseUrl/ideognostic');

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
}
