class UpdateUser {
  final String name;
  final String birthday;

  UpdateUser({
    required this.name,
    required this.birthday,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthday': birthday,
    };
  }
}
