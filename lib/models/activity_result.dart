class ActivityResult {
  final String userEmail;
  final String date;
  final String activityName;
  final int timeTaken;
  final int totalScore;
  final int retries;

  ActivityResult({
    required this.userEmail,
    required this.date,
    required this.activityName,
    required this.timeTaken,
    required this.totalScore,
    required this.retries,
  });

  // Convert the ActivityResult object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userEmail': userEmail,
      'date': date,
      'activityName': activityName,
      'timeTaken': timeTaken,
      'totalScore': totalScore,
      'retries': retries,
    };
  }
}
