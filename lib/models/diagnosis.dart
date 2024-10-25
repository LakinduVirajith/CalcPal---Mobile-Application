class Diagnosis {
  final int age;
  final int iq;
  final int q1;
  final int q2;
  final int q3;
  final int q4;
  final int q5;
  final int seconds;

  Diagnosis({
    required this.age,
    required this.iq,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.q4,
    required this.q5,
    required this.seconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'Age': age,
      'IQ': iq,
      'Q1': q1,
      'Q2': q2,
      'Q3': q3,
      'Q4': q4,
      'Q5': q5,
      'Time Seconds': seconds,
    };
  }
}
