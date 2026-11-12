import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_session.dart';
import '../models/parking_space.dart';
import '../models/reservation.dart';
import '../models/admin_user.dart';

class AdminService {
  static const String _baseUrl =
      'https://smartparking-campus-production.up.railway.app/api';

  Future<List<ParkingSpace>> getParkingSpaces(AuthSession session) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/plazas'),
          headers: session.authorizationHeaders,
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron consultar las plazas. HTTP ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => ParkingSpace.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ParkingSpace> updateAvailability({
    required AuthSession session,
    required int parkingSpaceId,
    required bool available,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/admin/plazas/$parkingSpaceId/disponibilidad',
    ).replace(queryParameters: {'available': available.toString()});

    final response = await http
        .patch(uri, headers: session.authorizationHeaders)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo actualizar la plaza. HTTP ${response.statusCode}',
      );
    }

    return ParkingSpace.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<Reservation>> getAllReservations(AuthSession session) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/admin/reservas'),
          headers: session.authorizationHeaders,
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron consultar las reservas. HTTP ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => Reservation.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Reservation> cancelReservation({
    required AuthSession session,
    required int reservationId,
  }) async {
    final response = await http
        .patch(
          Uri.parse('$_baseUrl/admin/reservas/$reservationId/cancelar'),
          headers: session.authorizationHeaders,
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo cancelar la reserva. HTTP ${response.statusCode}',
      );
    }

    return Reservation.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<AdminUser>> getAllUsers(AuthSession session) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/admin/usuarios'),
          headers: session.authorizationHeaders,
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron consultar los usuarios. HTTP ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => AdminUser.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AdminUser> updateUser({
    required AuthSession session,
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    final response = await http
        .patch(
          Uri.parse('$_baseUrl/admin/usuarios/$userId'),
          headers: {
            ...session.authorizationHeaders,
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo actualizar el usuario. HTTP ${response.statusCode}',
      );
    }

    return AdminUser.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AdminUser> updateUserRole({
    required AuthSession session,
    required int userId,
    required String role,
  }) async {
    final response = await http
        .patch(
          Uri.parse('$_baseUrl/admin/usuarios/$userId/rol'),
          headers: {
            ...session.authorizationHeaders,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'role': role}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo actualizar el rol. HTTP ${response.statusCode}',
      );
    }

    return AdminUser.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
