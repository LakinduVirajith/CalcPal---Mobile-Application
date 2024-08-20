class SignUp {
  final String name;
  final String email;
  final String birthday;
  final String password;

  SignUp({
    required this.name,
    required this.email,
    required this.birthday,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'birthday': birthday,
      'password': password,
    };
  }
}
