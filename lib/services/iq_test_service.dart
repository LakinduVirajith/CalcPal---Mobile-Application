import 'dart:convert';
import 'package:calcpal/models/iq_question.dart';
import 'package:calcpal/services/common_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class IqTestService {
  // RETRIEVE THE BASE URL FROM ENVIRONMENT VARIABLES
  final String _baseUrl = dotenv.env['IQ_BASE_URL'] ?? '';

  // COMMON SERVICE HANDLE HTTP RESPONSE
  final CommonService _commonService = CommonService();

  // FETCH A QUESTION BASED ON NUMBER AND LANGUAGE
  Future<IqQuestion?> fetchQuestion(
      int questionNumber, String language, BuildContext context) async {
    final url =
        Uri.parse('$_baseUrl/iq/question/$questionNumber?language=$language');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return IqQuestion.fromJson(data);
      } else {
        _commonService.handleHttpResponse(response, context, null,
            {404: AppLocalizations.of(context)!.commonMessageNoQuestionError});
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
}
