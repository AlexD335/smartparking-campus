import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/parking_space.dart';

class ParkingSpaceService {
  static const String _baseUrl = 'http://192.168.1.72:8080/api';

  // Consultar todas las plazas.
  Future<List<ParkingSpace>> getParkingSpaces() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/plazas'),
      headers: {'Accept': 'application/json'},
    );

    return _parseParkingSpaces(response);
  }

  // Consultar plazas disponibles según fecha y horario.
  Future<List<ParkingSpace>> getAvailableParkingSpaces({
    required DateTime date,
    required String startTime,
    required String endTime,
    required String token,
  }) async {
    final dateString =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse('$_baseUrl/plazas/disponibles').replace(
      queryParameters: {
        'fecha': dateString,
        'horaInicio': startTime,
        'horaFin': endTime,
      },
    );

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${token.trim()}',
          },
        )
        .timeout(const Duration(seconds: 15));

    return _parseParkingSpaces(response);
  }

  // Convertir la respuesta JSON a objetos ParkingSpace.
  List<ParkingSpace> _parseParkingSpaces(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception(
        'Error al consultar las plazas: ${response.statusCode} '
        '${response.body}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => ParkingSpace.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
