class AuthSession {
  const AuthSession({
    required this.token,
    required this.userId,
    required this.email,
    this.tokenType = 'Bearer',
  });

  final String token;
  final int userId;
  final String email;
  final String tokenType;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      userId: (json['userId'] as num).toInt(),
      email: json['email'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }

  Map<String, String> get authorizationHeaders => {
    'Authorization': '$tokenType $token',
    'Accept': 'application/json',
  };
}
