import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_session.dart';

class AuthService {
  static const String _baseUrl = 'http://192.168.1.66:8080/api';

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/auth/login'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'email': email.trim(), 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      var message =
          'No se pudo iniciar sesión. '
          'Código HTTP: ${response.statusCode}';

      try {
        final body = jsonDecode(response.body);

        if (body is Map<String, dynamic>) {
          final detail = body['detail'] ?? body['message'];

          if (detail is String && detail.isNotEmpty) {
            message = detail;
          }
        }
      } on FormatException {
        // Conserva el mensaje genérico si el servidor no devuelve JSON.
      }

      throw Exception(message);
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'El servidor devolvió una respuesta inesperada.',
      );
    }

    return AuthSession.fromJson(decoded);
  }
}
