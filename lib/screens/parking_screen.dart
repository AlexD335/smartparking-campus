import 'package:flutter/material.dart';

import 'reservation_screen.dart';

import '../models/reservation.dart';

class ParkingScreen extends StatelessWidget {
  const ParkingScreen({
    super.key,
    required this.onReservationCreated,
  });

  final ValueChanged<Reservation> onReservationCreated;

  final List<Map<String, dynamic>> parkingSpaces = const [
    {
      'id': 'A-25',
      'zone': 'Zona A',
      'location': 'Cerca del Bloque 2',
      'available': true,
    },
    {
      'id': 'A-26',
      'zone': 'Zona A',
      'location': 'Cerca del Bloque 2',
      'available': false,
    },
    {
      'id': 'A-27',
      'zone': 'Zona A',
      'location': 'Cerca del Bloque 2',
      'available': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parqueadero'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Espacios disponibles',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona un espacio para continuar con tu reserva.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),

          ...parkingSpaces.map(
            (space) => _ParkingSpaceCard(
              id: space['id'] as String,
              zone: space['zone'] as String,
              location: space['location'] as String,
              available: space['available'] as bool,
              onReservationCreated: onReservationCreated,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParkingSpaceCard extends StatelessWidget {
  const _ParkingSpaceCard({
    required this.id,
    required this.zone,
    required this.location,
    required this.available,
    required this.onReservationCreated,
  });

  final String id;
  final String zone;
  final String location;
  final bool available;
  final ValueChanged<Reservation> onReservationCreated;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              id,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text('$zone · $location'),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: available ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  available ? 'Disponible' : 'Ocupado',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: available ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),

            if (available) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationScreen(
                          spaceId: id,
                          zone: zone,
                          location: location,
                          onReservationCreated: onReservationCreated,
                        ),
                      ),
                    );
                  },
                  child: Text('SELECCIONAR $id'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}