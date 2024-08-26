class User {
  final String name;
  final String email;
  final int age;
  final String birthDay;
  final List<String>? disorderTypes;
  final int? iqScore;

  User(
    this.disorderTypes,
    this.iqScore, {
    required this.name,
    required this.email,
    required this.age,
    required this.birthDay,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['disorderTypes'] != null
          ? List<String>.from(json['disorderTypes'])
          : null,
      json['iqScore'],
      name: json['name'],
      email: json['email'],
      age: json['age'],
      birthDay: json['birthDay'],
    );
  }
}
