import 'package:flutter/material.dart';

import '../models/reservation.dart';
import '../services/reservation_service.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({
    super.key,
    required this.spaceId,
    required this.parkingSpaceId,
    required this.zone,
    required this.location,
    required this.onReservationCreated,
  });

  final String spaceId;
  final int parkingSpaceId;
  final String zone;
  final String location;
  final ValueChanged<Reservation> onReservationCreated;

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  bool _isSubmitting = false;

  Future<void> _confirmReservation() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final now = DateTime.now();
    final reservationDate =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await ReservationService().createReservation(
        userId: 1,
        parkingSpaceId: widget.parkingSpaceId,
        reservationDate: reservationDate,
        reservationTime: '08:00:00',
      );

      if (!mounted) return;

      final reservation = Reservation(
        spaceId: widget.spaceId,
        zone: widget.zone,
        location: widget.location,
        date: 'Hoy',
        time: '8:00 AM',
      );

      widget.onReservationCreated(reservation);

      navigator.pop();

      messenger.showSnackBar(
        const SnackBar(content: Text('Reserva guardada correctamente')),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo guardar la reserva. $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar reserva')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.local_parking, size: 64),
            const SizedBox(height: 20),
            const Text(
              'Espacio seleccionado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              widget.spaceId,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
                      value: widget.zone,
                    ),
                    const Divider(height: 28),
                    _ReservationDetail(
                      icon: Icons.place_outlined,
                      label: 'Ubicación',
                      value: widget.location,
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
                onPressed: _isSubmitting ? null : _confirmReservation,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
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
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
