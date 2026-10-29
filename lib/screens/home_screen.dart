import 'package:flutter/material.dart';

import '../models/parking_space.dart';
import '../services/parking_space_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onSearchSpace});

  final VoidCallback? onSearchSpace;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ParkingSpaceService _parkingSpaceService = ParkingSpaceService();
  late Future<List<ParkingSpace>> _parkingSpacesFuture;

  @override
  void initState() {
    super.initState();
    _loadParkingSpaces();
  }

  void _loadParkingSpaces() {
    _parkingSpacesFuture = _parkingSpaceService.getParkingSpaces();
  }

  void _retryLoading() {
    setState(_loadParkingSpaces);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartParking Campus'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Actualizar disponibilidad',
            onPressed: _retryLoading,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Hola, estudiante!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Encuentra y reserva tu espacio de parqueadero.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.local_parking, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Espacios disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<List<ParkingSpace>>(
                            future: _parkingSpacesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'No disponible',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'No se pudo conectar con la API.',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    TextButton(
                                      onPressed: _retryLoading,
                                      child: const Text('Reintentar'),
                                    ),
                                  ],
                                );
                              }

                              final spaces =
                                  snapshot.data ?? const <ParkingSpace>[];
                              final availableCount = spaces
                                  .where((space) => space.available)
                                  .length;

                              return Text(
                                '$availableCount de ${spaces.length} espacios',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Acciones rápidas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: widget.onSearchSpace,
                icon: Icon(Icons.search),
                label: Text(
                  'Buscar un espacio',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Próxima reserva',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Card(
              child: ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Consulta la sección Mis reservas'),
                subtitle: Text(
                  'Allí encontrarás las reservas activas de tu cuenta.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
