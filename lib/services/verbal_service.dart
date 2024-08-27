import 'dart:convert';
import 'package:calcpal/models/diagnosis.dart';
import 'package:calcpal/models/diagnosis_result.dart';
import 'package:calcpal/models/flask_diagnosis_result.dart';
import 'package:calcpal/models/verbal_question.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class VerbalService {
  // RETRIEVE THE BASE URL FROM ENVIRONMENT VARIABLES
  final String _baseUrl = dotenv.env['VERBAL_BASE_URL'] ?? '';
  final String _modelBaseUrl = dotenv.env['DIAGNOSIS_MODELS_BASE_URL'] ?? '';

  // COMMON SERVICE HANDLE HTTP RESPONSE
  final CommonService _commonService = CommonService();

  // FETCH A QUESTION BASED ON NUMBER AND LANGUAGE
  Future<VerbalQuestion?> fetchQuestion(
      int questionNumber, String language) async {
    final url = Uri.parse(
        '$_baseUrl/verbal/question/$questionNumber?language=$language');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VerbalQuestion.fromJson(data);
      } else {
        _commonService.handleHttpResponse(response, null, {
          404:
              'No questions found on the server for the provided question number.'
        });
        return null;
      }
    } on http.ClientException {
      _commonService.handleNetworkError();
      return null;
    } catch (e) {
      _commonService.handleException(e);
      return null;
    }
  }

  // SUBMIT A DIAGNOSIS RESULT TO THE SERVER
  Future<bool> addDiagnosisResult(DiagnosisResult result) async {
    final url = Uri.parse('$_baseUrl/verbal/diagnosis/');

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
        return false;
      }
    } on http.ClientException {
      _commonService.handleNetworkError();
      return false;
    } catch (e) {
      _commonService.handleException(e);
      return false;
    }
  }

  // FETCH A DIAGNOSIS RESULT FROM THE SERVER
  Future<FlaskDiagnosisResult?> getDiagnosisResult(Diagnosis diagnosis) async {
    final url = Uri.parse('$_modelBaseUrl/verbal');

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
      _commonService.handleNetworkError();
    } catch (e) {
      _commonService.handleException(e);
    }

    return null;
  }
}
