class DiagnosisResult {
  final String userEmail;
  final int timeSeconds;
  final bool q1;
  final bool q2;
  final bool q3;
  final bool q4;
  final bool q5;
  final String totalScore;
  final bool label;

  DiagnosisResult({
    required this.userEmail,
    required this.timeSeconds,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.q4,
    required this.q5,
    required this.totalScore,
    required this.label,
  });

  // CONVERT THE DiagnosisResult OBJECT TO JSON
  Map<String, dynamic> toJson() {
    return {
      'userEmail': userEmail,
      'timeSeconds': timeSeconds,
      'q1': q1,
      'q2': q2,
      'q3': q3,
      'q4': q4,
      'q5': q5,
      'totalScore': totalScore,
      'label': label,
    };
  }
}
