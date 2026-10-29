import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';
import '../widgets/bottom_navigation.dart';
import 'home_screen.dart';
import 'parking_screen.dart';
import 'reservations_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.session});

  final AuthSession? session;

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

    if (widget.session == null) {
      _isLoadingReservations = false;
      _reservationsError = 'Inicia sesión para consultar tus reservas.';
    } else {
      _loadReservations();
    }
  }

  Future<void> _loadReservations({bool showLoading = false}) async {
    final session = widget.session;

    if (session == null) {
      if (!mounted) return;

      setState(() {
        _isLoadingReservations = false;
        _reservationsError = 'Inicia sesión para consultar tus reservas.';
      });
      return;
    }

    if (showLoading && mounted) {
      setState(() {
        _isLoadingReservations = true;
        _reservationsError = null;
      });
    }

    try {
      final reservations = await _reservationService.getReservationsByUserId(
        session.userId,
        token: session.token,
      );

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
    final session = widget.session;
    final reservationId = reservation.reservationId;

    if (session == null || reservationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo identificar la sesión o la reserva.'),
        ),
      );
      return;
    }

    try {
      await _reservationService.cancelReservation(
        reservationId,
        token: session.token,
      );

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                Text(_reservationsError!, textAlign: TextAlign.center),
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
      HomeScreen(onSearchSpace: () => _onDestinationSelected(1)),
      widget.session == null
          ? Scaffold(
              appBar: AppBar(title: const Text('Parqueadero')),
              body: const Center(child: Text('Inicia sesión para reservar.')),
            )
          : ParkingScreen(
              onReservationCreated: _addReservation,
              reservedSpaceIds: _reservations
                  .map((reservation) => reservation.spaceId)
                  .toSet(),
              userId: widget.session!.userId,
              token: widget.session!.token,
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
