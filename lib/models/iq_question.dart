class IqQuestion {
  final int questionNumber;
  final String language;
  final String question;
  final List<String> answers;
  final String correctAnswer;

  IqQuestion({
    required this.questionNumber,
    required this.language,
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });

  factory IqQuestion.fromJson(Map<String, dynamic> json) {
    return IqQuestion(
      questionNumber: json['questionNumber'] as int,
      language: json['language'] as String,
      question: json['question'] as String,
      answers: List<String>.from(json['answers']),
      correctAnswer: json['correctAnswer'] as String,
    );
  }
}
