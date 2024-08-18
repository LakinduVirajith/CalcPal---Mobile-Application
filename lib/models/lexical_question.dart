class LexicalQuestion {
  final int questionNumber;
  final String question;

  LexicalQuestion({
    required this.questionNumber,
    required this.question,
  });

  factory LexicalQuestion.fromJson(Map<String, dynamic> json) {
    return LexicalQuestion(
      questionNumber: json['questionNumber'] as int,
      question: json['question'] as String,
    );
  }
}
