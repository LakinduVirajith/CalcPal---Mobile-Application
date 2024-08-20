class AuthResponse {
  final String message;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
