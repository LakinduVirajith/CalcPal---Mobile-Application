import 'dart:convert';
import 'package:calcpal/models/verbal_diagnosis.dart';
import 'package:calcpal/models/verbal_question.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class VerbalService {
  // RETRIEVE THE BASE URL FROM ENVIRONMENT VARIABLES
  final String _baseUrl = dotenv.env['VERBAL_BASE_URL'] ?? '';

  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

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

  // SUBMIT A DIAGNOSIS RESULT TO THE SERVER
  Future<bool> addDiagnosisResult(VerbalDiagnosis result) async {
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
      _toastService
          .errorToast('Network error occurred. Please check your connection.');
      return false;
    } catch (e) {
      _toastService.errorToast('An unexpected error occurred.');
      return false;
    }
  }
}
