class PractognosticActivity {
  final int activityNumber;
  final String language;
  final String activityLevelType;
  final String question;
  final String? questionText;
  final String? imageType;
  final List<String> answers;
  final String correctAnswer;

  PractognosticActivity(
    this.questionText,
    this.imageType, {
    required this.activityNumber,
    required this.language,
    required this.activityLevelType,
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });

  factory PractognosticActivity.fromJson(Map<String, dynamic> json) {
    return PractognosticActivity(
      activityNumber: json['activityNumber'] as int,
      language: json['language'] as String,
      activityLevelType: json['activityLevelType'] as String,
      question: json['question'] as String,
      json['questionText'] != null ? json['questionText'] as String : null,
      json['imageType'] != null ? json['imageType'] as String : null,
      answers: List<String>.from(json['answers']),
      correctAnswer: json['correctAnswer'] as String,
    );
  }
}
