import 'package:flutter/material.dart';

import '../models/parking_space.dart';
import '../models/reservation.dart';
import '../services/parking_space_service.dart';
import 'reservation_screen.dart';

class ParkingScreen extends StatefulWidget {
  const ParkingScreen({
    super.key,
    required this.onReservationCreated,
    this.reservedSpaceIds = const <String>{},
  });

  final ValueChanged<Reservation> onReservationCreated;
  final Set<String> reservedSpaceIds;

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  late Future<List<ParkingSpace>> _parkingSpacesFuture;

  @override
  void initState() {
    super.initState();
    _loadParkingSpaces();
  }

  void _loadParkingSpaces() {
    _parkingSpacesFuture = ParkingSpaceService().getParkingSpaces();
  }

  void _retryLoading() {
    setState(() {
      _loadParkingSpaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parqueadero')),
      body: FutureBuilder<List<ParkingSpace>>(
        future: _parkingSpacesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'No se pudieron cargar las plazas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Comprueba la conexión con el servidor.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retryLoading,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final parkingSpaces = snapshot.data ?? const <ParkingSpace>[];

          if (parkingSpaces.isEmpty) {
            return const Center(
              child: Text('No hay plazas de parqueadero registradas.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Espacios disponibles',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona un espacio para continuar con tu reserva.',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ...parkingSpaces.map(
                (space) => _ParkingSpaceCard(
                  parkingSpaceId: space.id,
                  id: space.code,
                  zone: space.zone,
                  location: space.location,
                  available:
                      space.available &&
                      !widget.reservedSpaceIds.contains(space.code),
                  onReservationCreated: widget.onReservationCreated,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ParkingSpaceCard extends StatelessWidget {
  const _ParkingSpaceCard({
    required this.id,
    required this.parkingSpaceId,
    required this.zone,
    required this.location,
    required this.available,
    required this.onReservationCreated,
  });

  final String id;
  final int parkingSpaceId;
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
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                          parkingSpaceId: parkingSpaceId,
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
