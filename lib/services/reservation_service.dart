import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/reservation.dart';

class ReservationService {
  static const String _baseUrl = 'http://192.168.1.66:8080/api';

  Future<void> createReservation({
    required int userId,
    required int parkingSpaceId,
    required String reservationDate,
    required String reservationTime,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/reservas'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'parkingSpaceId': parkingSpaceId,
        'reservationDate': reservationDate,
        'reservationTime': reservationTime,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'No se pudo crear la reserva. '
        'Código HTTP: ${response.statusCode}',
      );
    }
  }

  Future<List<Reservation>> getReservationsByUserId(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/reservas/usuario/$userId'),
      headers: {'Accept': 'application/json'},
    );

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

  Future<void> cancelReservation(int reservationId) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/reservas/$reservationId/cancelar'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo cancelar la reserva. '
        'Código HTTP: ${response.statusCode}',
      );
    }
  }
}
