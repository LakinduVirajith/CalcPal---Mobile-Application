class SignUp {
  final String name;
  final String email;
  final String birthDay;
  final String password;

  SignUp({
    required this.name,
    required this.email,
    required this.birthDay,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'birthDay': birthDay,
      'password': password,
    };
  }
}
