import 'package:flutter/material.dart';

import '../widgets/bottom_navigation.dart';
import 'home_screen.dart';
import 'parking_screen.dart';
import '../models/reservation.dart';
import 'reservations_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Reservation> _reservations = [];



  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _addReservation(Reservation reservation) {
  setState(() {
    _reservations.add(reservation);
  });
 }

  

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      ParkingScreen(
        onReservationCreated: _addReservation,
      ),
      ReservationsScreen(
        reservations: _reservations,
      ),
      const Center(
        child: Text('Perfil'),
      ),
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