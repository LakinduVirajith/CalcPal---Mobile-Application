class LexicalActivity {
  final int activityNumber;
  final String language;
  final String question;
  final List<String>? answers;
  final String correctAnswer;

  LexicalActivity(
    this.answers, {
    required this.activityNumber,
    required this.language,
    required this.question,
    required this.correctAnswer,
  });

  factory LexicalActivity.fromJson(Map<String, dynamic> json) {
    return LexicalActivity(
      activityNumber: json['activityNumber'] as int,
      language: json['language'] as String,
      question: json['question'] as String,
      json['answers'] != null ? List<String>.from(json['answers']) : <String>[],
      correctAnswer: json['correctAnswer'] as String,
    );
  }
}
