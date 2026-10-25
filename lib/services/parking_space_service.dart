import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/parking_space.dart';

class ParkingSpaceService {
  static const String _baseUrl = 'http://192.168.1.66:8080/api';

  Future<List<ParkingSpace>> getParkingSpaces() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/plazas'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al consultar las plazas: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => ParkingSpace.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
