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

  late DateTime _selectedDate;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5, 12, 31),
      helpText: 'Selecciona la fecha de la reserva',
      cancelText: 'CANCELAR',
      confirmText: 'ACEPTAR',
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Selecciona la hora de la reserva',
      cancelText: 'CANCELAR',
      confirmText: 'ACEPTAR',
    );

    if (pickedTime != null && mounted) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _confirmReservation() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final reservationDate =
        '${_selectedDate.year.toString().padLeft(4, '0')}-'
        '${_selectedDate.month.toString().padLeft(2, '0')}-'
        '${_selectedDate.day.toString().padLeft(2, '0')}';

    final reservationTime =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:'
        '${_selectedTime.minute.toString().padLeft(2, '0')}:00';

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await ReservationService().createReservation(
        userId: 1,
        parkingSpaceId: widget.parkingSpaceId,
        reservationDate: reservationDate,
        reservationTime: reservationTime,
      );

      if (!mounted) return;

      final reservation = Reservation(
        spaceId: widget.spaceId,
        parkingSpaceId: widget.parkingSpaceId,
        zone: widget.zone,
        location: widget.location,
        date: _formatDate(_selectedDate),
        time: _selectedTime.format(context),
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
                    _ReservationDetail(
                      icon: Icons.calendar_today_outlined,
                      label: 'Fecha',
                      value: _formatDate(_selectedDate),
                      onTap: _selectDate,
                    ),
                    const Divider(height: 28),
                    _ReservationDetail(
                      icon: Icons.access_time,
                      label: 'Hora',
                      value: _selectedTime.format(context),
                      onTap: _selectTime,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Toca la fecha o la hora para modificarlas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
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
            if (onTap != null)
              const Icon(Icons.edit_calendar_outlined, size: 20),
          ],
        ),
      ),
    );
  }
}
