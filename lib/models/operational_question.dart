class OperationalQuestion {
  final int questionNumber;
  final String language;
  final String question;
  final int correctAnswer;
  final List<int> allAnswers;

  OperationalQuestion({
    required this.questionNumber,
    required this.language,
    required this.question,
    required this.correctAnswer,
    required this.allAnswers,
  });

  factory OperationalQuestion.fromJson(Map<String, dynamic> json) {
    return OperationalQuestion(
      questionNumber: json['questionNumber'],
      language: json['language'],
      question: json['question'],
      correctAnswer: json['correctAnswer'],
      allAnswers: List<int>.from(json['allAnswers']),
    );
  }
}
