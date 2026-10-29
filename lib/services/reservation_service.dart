import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/reservation.dart';

class ReservationService {
  static const String _baseUrl = 'http://192.168.1.72:8080/api';

  Map<String, String> _headers(
    String? token, {
    bool includeContentType = false,
  }) {
    if (token == null || token.trim().isEmpty) {
      throw StateError(
        'Se requiere una sesión autenticada para realizar esta operación.',
      );
    }

    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token.trim()}',
      if (includeContentType) 'Content-Type': 'application/json',
    };
  }

  Future<void> createReservation({
    required int userId,
    required int parkingSpaceId,
    required String reservationDate,
    required String reservationTime,
    String? token,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/reservas'),
          headers: _headers(token, includeContentType: true),
          body: jsonEncode({
            'userId': userId,
            'parkingSpaceId': parkingSpaceId,
            'reservationDate': reservationDate,
            'reservationTime': reservationTime,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 201) {
      throw Exception(
        'No se pudo crear la reserva. '
        'Código HTTP: ${response.statusCode}',
      );
    }
  }

  Future<List<Reservation>> getReservationsByUserId(
    int userId, {
    String? token,
  }) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/reservas/usuario/$userId'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron consultar las reservas. '
        'Código HTTP: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => Reservation.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelReservation(int reservationId, {String? token}) async {
    final response = await http
        .patch(
          Uri.parse('$_baseUrl/reservas/$reservationId/cancelar'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo cancelar la reserva. '
        'Código HTTP: ${response.statusCode}',
      );
    }
  }
}
