import 'dart:convert';
import 'package:calcpal/models/lexical_question.dart';
import 'package:calcpal/models/diagnosis_result.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LexicalService {
  // RETRIEVE THE BASE URL FROM ENVIRONMENT VARIABLES
  final String _baseUrl = dotenv.env['LEXICAL_BASE_URL'] ?? '';

  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

  // FETCH A QUESTION BASED ON NUMBER AND LANGUAGE
  Future<LexicalQuestion?> fetchQuestion(int questionNumber) async {
    final url = Uri.parse('$_baseUrl/lexical/question/$questionNumber');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LexicalQuestion.fromJson(data);
      } else {
        _toastService
            .errorToast('No questions found for the given question number');
        return null;
      }
    } on http.ClientException {
      _toastService
          .errorToast('Network error occurred. Please check your connection.');
      return null;
    } catch (e) {
      _toastService.errorToast('An unexpected error occurred');
      return null;
    }
  }

  // SUBMIT A DIAGNOSIS RESULT TO THE SERVER
  Future<bool> addDiagnosisResult(DiagnosisResult result) async {
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
      _toastService
          .errorToast('Network error occurred. Please check your connection.');
      return false;
    } catch (e) {
      _toastService.errorToast('An unexpected error occurred');
      return false;
    }
  }
}
