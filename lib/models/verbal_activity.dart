class VerbalActivity {
  final int activityNumber;
  final String language;
  final String question;
  final String answer;
  final List<String> answers;
  final String correctAnswerAudioText;
  final String wrongAnswerAudioText;

  VerbalActivity({
    required this.activityNumber,
    required this.language,
    required this.question,
    required this.answer,
    required this.answers,
    required this.correctAnswerAudioText,
    required this.wrongAnswerAudioText,
  });

  factory VerbalActivity.fromJson(Map<String, dynamic> json) {
    return VerbalActivity(
      activityNumber: json['activityNumber'] as int,
      language: json['language'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      answers: List<String>.from(json['answers']),
      correctAnswerAudioText: json['correctAnswerAudioText'] as String,
      wrongAnswerAudioText: json['wrongAnswerAudioText'] as String,
    );
  }
}
