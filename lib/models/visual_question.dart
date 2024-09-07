class VisualQuestion {
  final int questionNumber;
  final String language;
  final String question;
  final List<String> answers;
  final String correctAnswer;

  VisualQuestion({
    required this.questionNumber,
    required this.language,
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });

  factory VisualQuestion.fromJson(Map<String, dynamic> json) {
    return VisualQuestion(
      questionNumber: json['questionNumber'] as int,
      language: json['language'] as String,
      question: json['question'] as String,
      answers: List<String>.from(json['answers']),
      correctAnswer: json['correctAnswer'] as String,
    );
  }
}