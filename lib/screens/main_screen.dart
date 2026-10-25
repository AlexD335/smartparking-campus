import 'package:flutter/material.dart';

import '../models/reservation.dart';
import '../services/reservation_service.dart';
import '../widgets/bottom_navigation.dart';
import 'home_screen.dart';
import 'parking_screen.dart';
import 'reservations_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ReservationService _reservationService = ReservationService();

  int _currentIndex = 0;
  List<Reservation> _reservations = [];
  bool _isLoadingReservations = true;
  String? _reservationsError;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoadingReservations = true;
        _reservationsError = null;
      });
    }

    try {
      final reservations = await _reservationService.getReservationsByUserId(1);

      final activeReservations = reservations
          .where((reservation) => reservation.status == 'CONFIRMED')
          .toList();

      if (!mounted) return;

      setState(() {
        _reservations = activeReservations;
        _reservationsError = null;
        _isLoadingReservations = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _reservationsError = 'No se pudieron cargar las reservas.';
        _isLoadingReservations = false;
      });
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 2) {
      _loadReservations(showLoading: true);
    }
  }

  void _addReservation(Reservation reservation) {
    _loadReservations(showLoading: true);
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    final reservationId = reservation.reservationId;

    if (reservationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró el identificador de la reserva.'),
        ),
      );
      return;
    }

    try {
      await _reservationService.cancelReservation(reservationId);
      await _loadReservations();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva cancelada correctamente')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cancelar la reserva.')),
      );
    }
  }

  Widget _buildReservationsContent() {
    if (_isLoadingReservations) {
      return const Scaffold(
        appBar: null,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_reservationsError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis reservas')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'No se pudieron cargar tus reservas.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadReservations(showLoading: true),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ReservationsScreen(
      reservations: _reservations,
      onReservationCancelled: _cancelReservation,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      ParkingScreen(
        onReservationCreated: _addReservation,
        reservedSpaceIds: _reservations
            .map((reservation) => reservation.spaceId)
            .toSet(),
      ),
      _buildReservationsContent(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
