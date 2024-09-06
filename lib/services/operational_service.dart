import 'dart:convert';
import 'package:calcpal/models/operational_diagnosis.dart';
import 'package:calcpal/models/operational_question.dart';
import 'package:calcpal/services/toast_service.dart';
import 'package:http/http.dart' as http;

class OperationalService {
  // TOAST SERVICE TO SHOW MESSAGES
  final ToastService _toastService = ToastService();

  // FETCH A QUESTION BASED ON NUMBER
  Future<OperationalQuestion?> fetchOperationalQuestion(
      int questionNumber) async {
    final url = Uri.parse(
        'http://20.244.32.223:8084/api/v1/operational/questionbank/$questionNumber');

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

  // SUBMIT A DIAGNOSIS RESULT TO THE SERVER
  Future<bool> addDiagnosisResult(OperationalDiagnosis result) async {
    final url =
        Uri.parse('http://20.244.32.223:8084/api/v1/operational/diagnosis/');

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
