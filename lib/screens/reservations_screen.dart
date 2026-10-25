import 'package:flutter/material.dart';

import '../models/reservation.dart';

class ReservationsScreen extends StatelessWidget {
  const ReservationsScreen({
    super.key,
    required this.reservations,
    required this.onReservationCancelled,
  });

  final List<Reservation> reservations;
  final Future<void> Function(Reservation) onReservationCancelled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis reservas')),
      body: reservations.isEmpty
          ? const Center(
              child: Text(
                'No tienes reservas todavía.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_parking, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              reservation.spaceId,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          reservation.zone,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reservation.location,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const Divider(height: 28),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text(reservation.date),
                            const SizedBox(width: 20),
                            const Icon(Icons.access_time, size: 20),
                            const SizedBox(width: 8),
                            Text(reservation.time),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancelar reserva'),
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Cancelar reserva'),
                                  content: Text(
                                    '¿Deseas cancelar la reserva del espacio '
                                    '${reservation.spaceId}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                      },
                                      child: const Text('Volver'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.of(dialogContext).pop();

                                        await onReservationCancelled(
                                          reservation,
                                        );
                                      },
                                      child: const Text('Confirmar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
