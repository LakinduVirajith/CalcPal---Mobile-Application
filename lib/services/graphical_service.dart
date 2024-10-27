import 'dart:convert';
import 'package:calcpal/models/diagnosis.dart';
import 'package:calcpal/models/diagnosis_result.dart';
import 'package:calcpal/models/flask_diagnosis_result.dart';
import 'package:calcpal/models/verbal_activity.dart';
import 'package:calcpal/models/verbal_question.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class GraphicalService {
  // RETRIEVE THE BASE URL FROM ENVIRONMENT VARIABLES
  final String _baseUrl = dotenv.env['GRAPHICAL_BASE_URL'] ?? '';
  final String _modelBaseUrl = dotenv.env['DIAGNOSIS_MODELS_BASE_URL'] ?? '';

  // COMMON SERVICE HANDLE HTTP RESPONSE
  final CommonService _commonService = CommonService();

  // SUBMIT A DIAGNOSIS RESULT TO THE SERVER

  Future<bool> addDiagnosisResult(
      DiagnosisResult result, BuildContext context) async {
    final url = Uri.parse('$_baseUrl/graphical/diagnosis/');
    print(result.userEmail);
    print(result.timeSeconds);
    print(result.q1);
    print(result.q2);
    print(result.q3);
    print(result.q4);
    print(result.q5);
    print(result.totalScore);
    print(result.label);

    try {
      final body = jsonEncode(result.toJson());
      print(body);

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
    final url = Uri.parse('$_modelBaseUrl/graphical');

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
