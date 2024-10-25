class LexicalQuestion {
  final int questionNumber;
  final String question;
  final List<String> answers;

  LexicalQuestion({
    required this.questionNumber,
    required this.question,
    required this.answers,
  });

  factory LexicalQuestion.fromJson(Map<String, dynamic> json) {
    return LexicalQuestion(
      questionNumber: json['questionNumber'] as int,
      question: json['question'] as String,
      answers: List<String>.from(json['answers']),
    );
  }
}
