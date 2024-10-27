class ActivityResult {
  final String? id;
  final String userEmail;
  final String date;
  final String activityName;
  final int timeTaken;
  final int totalScore;
  final int retries;

  ActivityResult({
    this.id,
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

  // Define the 'fromJson' factory method
  factory ActivityResult.fromJson(Map<String, dynamic> json) {
    return ActivityResult(
      id: json['id'] as String,
      userEmail: json['userEmail'] as String,
      date: json['date'] as String,
      activityName: json['activityName'] as String,
      timeTaken: json['timeTaken'] as int,
      totalScore: json['totalScore'] as int,
      retries: json['retries'] as int,
    );
  }
}
