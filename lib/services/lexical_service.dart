import 'dart:convert';
import 'package:calcpal/models/diagnosis.dart';
import 'package:calcpal/models/flask_diagnosis_result.dart';
import 'package:calcpal/models/lexical_question.dart';
import 'package:calcpal/models/diagnosis_result.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class LexicalService {
  // RETRIEVE THE BASE URL FROM ENVIRONMENT VARIABLES
  final String _baseUrl = dotenv.env['LEXICAL_BASE_URL'] ?? '';
  final String _modelBaseUrl = dotenv.env['DIAGNOSIS_MODELS_BASE_URL'] ?? '';

  // COMMON SERVICE HANDLE HTTP RESPONSE
  final CommonService _commonService = CommonService();

  // FETCH A QUESTION BASED ON NUMBER AND LANGUAGE
  Future<LexicalQuestion?> fetchQuestion(
      int questionNumber, BuildContext context) async {
    final url = Uri.parse('$_baseUrl/lexical/question/$questionNumber');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LexicalQuestion.fromJson(data);
      } else {
        _commonService.handleHttpResponse(response, context, null,
            {404: AppLocalizations.of(context)!.lexicalServiceNoQuestionError});
        return null;
      }
    } on http.ClientException {
      _commonService.handleNetworkError(context);
      return null;
    } catch (e) {
      _commonService.handleException(e, context);
      return null;
    }
  }

  // SUBMIT A DIAGNOSIS RESULT TO THE SERVER
  Future<bool> addDiagnosisResult(
      DiagnosisResult result, BuildContext context) async {
    final url = Uri.parse('$_baseUrl/lexical/diagnosis/');

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
      _commonService.handleNetworkError(context);
      return false;
    } catch (e) {
      _commonService.handleException(e, context);
      return false;
    }
  }

  // FETCH A DIAGNOSIS RESULT FROM THE SERVER
  Future<FlaskDiagnosisResult?> getDiagnosisResult(
      Diagnosis diagnosis, BuildContext context) async {
    final url = Uri.parse('$_modelBaseUrl/lexical');

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
