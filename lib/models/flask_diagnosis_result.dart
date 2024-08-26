class FlaskDiagnosisResult {
  final bool? prediction;
  final String? message;
  final String? error;

  FlaskDiagnosisResult(
    this.error,
    this.prediction,
    this.message,
  );

  factory FlaskDiagnosisResult.fromJson(Map<String, dynamic> json) {
    return FlaskDiagnosisResult(
      json['error'],
      json['prediction'],
      json['message'],
    );
  }
}
