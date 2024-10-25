class IdeognosticQuestion {
  final int questionNumber;
  final String language;
  final String question;
  final String correctAnswer;
  final List<String> allAnswers;
  final String base64image;

  IdeognosticQuestion(
      {required this.questionNumber,
      required this.language,
      required this.question,
      required this.correctAnswer,
      required this.allAnswers,
      required this.base64image});

  factory IdeognosticQuestion.fromJson(Map<String, dynamic> json) {
    return IdeognosticQuestion(
        questionNumber: json['questionNumber'],
        language: json['language'],
        question: json['question'],
        correctAnswer: json['correctAnswer'],
        allAnswers: List<String>.from(json['allAnswers']),
        base64image: json['base64image']);
  }
}
