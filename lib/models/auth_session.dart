import 'dart:convert';

class AuthSession {
  const AuthSession({
    required this.token,
    required this.userId,
    required this.email,
    required this.role,
    this.tokenType = 'Bearer',
  });

  final String token;
  final int userId;
  final String email;
  final String role;
  final String tokenType;

  bool get isAdmin => role == 'ADMIN';

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String;
    final parts = token.split('.');

    if (parts.length != 3) {
      throw const FormatException('Token JWT inválido.');
    }

    final normalizedPayload = base64Url.normalize(parts[1]);
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(normalizedPayload)),
    ) as Map<String, dynamic>;

    return AuthSession(
      token: token,
      userId: (json['userId'] as num).toInt(),
      email: json['email'] as String,
      role: payload['role'] as String? ?? 'USER',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }

  Map<String, String> get authorizationHeaders => {
    'Authorization': '$tokenType $token',
    'Accept': 'application/json',
  };
}
