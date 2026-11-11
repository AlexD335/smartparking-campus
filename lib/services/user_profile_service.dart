import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_session.dart';
import '../models/user_profile.dart';

class UserProfileService {
  static const String _baseUrl =
      'https://smartparking-campus-production.up.railway.app/api';

  Future<UserProfile> getProfile(AuthSession session) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/profile'),
          headers: session.authorizationHeaders,
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo consultar el perfil. HTTP ${response.statusCode}',
      );
    }

    return UserProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<UserProfile> updateProfile({
    required AuthSession session,
    required Map<String, dynamic> data,
  }) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/profile'),
          headers: {
            ...session.authorizationHeaders,
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo actualizar el perfil. HTTP ${response.statusCode}',
      );
    }

    return UserProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
