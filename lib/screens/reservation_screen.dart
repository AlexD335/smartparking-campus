import 'package:flutter/material.dart';

class ReservationScreen extends StatelessWidget {
  const ReservationScreen({
    super.key,
    required this.spaceId,
    required this.zone,
    required this.location,
  });

  final String spaceId;
  final String zone;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar reserva'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.local_parking,
              size: 64,
            ),
            const SizedBox(height: 20),
            const Text(
              'Espacio seleccionado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              spaceId,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _ReservationDetail(
                      icon: Icons.location_on_outlined,
                      label: 'Zona',
                      value: zone,
                    ),
                    const Divider(height: 28),
                    _ReservationDetail(
                      icon: Icons.place_outlined,
                      label: 'Ubicación',
                      value: location,
                    ),
                    const Divider(height: 28),
                    const _ReservationDetail(
                      icon: Icons.calendar_today_outlined,
                      label: 'Fecha',
                      value: 'Hoy',
                    ),
                    const Divider(height: 28),
                    const _ReservationDetail(
                      icon: Icons.access_time,
                      label: 'Hora',
                      value: '8:00 AM',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reserva confirmada'),
                    ),
                  );
                },
                child: const Text(
                  'CONFIRMAR RESERVA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationDetail extends StatelessWidget {
  const _ReservationDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}