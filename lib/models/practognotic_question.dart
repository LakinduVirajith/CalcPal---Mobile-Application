class PractognosticQuestion {
  final int questionNumber;
  final String language;
  final String question;
  final String? questionText;
  final String? imageType;
  final List<String> answers;
  final String correctAnswer;

  PractognosticQuestion(
    this.questionText,
    this.imageType, {
    required this.questionNumber,
    required this.language,
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });

  factory PractognosticQuestion.fromJson(Map<String, dynamic> json) {
    return PractognosticQuestion(
      questionNumber: json['questionNumber'] as int,
      language: json['language'] as String,
      question: json['question'] as String,
      json['questionText'] != null ? json['questionText'] as String : null,
      json['imageType'] != null ? json['imageType'] as String : null,
      answers: List<String>.from(json['answers']),
      correctAnswer: json['correctAnswer'] as String,
    );
  }
}
