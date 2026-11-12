import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../models/parking_space.dart';
import '../models/reservation.dart';
import '../services/admin_service.dart';
import '../widgets/admin_users_tab.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key, required this.session});

  final AuthSession session;

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AdminService _adminService = AdminService();

  late Future<List<ParkingSpace>> _spacesFuture;
  late Future<List<Reservation>> _reservationsFuture;

  final Set<int> _updatingSpaces = {};
  final Set<int> _deletingSpaces = {};
  final Set<int> _cancellingReservations = {};
  bool _creatingSpace = false;

  String _reservationFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _loadSpaces();
    _loadReservations();
  }

  void _loadSpaces() {
    _spacesFuture = _adminService.getParkingSpaces(widget.session);
  }

  void _loadReservations() {
    _reservationsFuture = _adminService.getAllReservations(widget.session);
  }

  Future<void> _refreshSpaces() async {
    setState(_loadSpaces);
    await _spacesFuture;
  }

  Future<void> _refreshReservations() async {
    setState(_loadReservations);
    await _reservationsFuture;
  }

  Future<void> _showCreateSpaceDialog() async {
    final data = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _CreateParkingSpaceDialog(),
    );

    if (data == null || !mounted) return;

    setState(() => _creatingSpace = true);

    try {
      final createdSpace = await _adminService.createParkingSpace(
        session: widget.session,
        code: data['code']!,
        zone: data['zone']!,
        location: data['location']!,
      );

      if (!mounted) return;

      setState(_loadSpaces);
      await _spacesFuture;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plaza ${createdSpace.code} creada correctamente.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _creatingSpace = false);
    }
  }

  Future<void> _changeAvailability(ParkingSpace space, bool available) async {
    setState(() {
      _updatingSpaces.add(space.id);
    });

    try {
      await _adminService.updateAvailability(
        session: widget.session,
        parkingSpaceId: space.id,
        available: available,
      );

      if (!mounted) return;

      setState(_loadSpaces);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${space.code} ${available ? 'habilitada' : 'deshabilitada'} correctamente.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar ${space.code}.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingSpaces.remove(space.id);
        });
      }
    }
  }

  Future<void> _deleteParkingSpace(ParkingSpace space) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar plaza'),
        content: Text(
          '¿Deseas eliminar la plaza ${space.code}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _deletingSpaces.add(space.id));
    try {
      await _adminService.deleteParkingSpace(
        session: widget.session,
        parkingSpaceId: space.id,
      );
      if (!mounted) return;
      setState(_loadSpaces);
      await _spacesFuture;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plaza ${space.code} eliminada correctamente.')),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _deletingSpaces.remove(space.id));
    }
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    final reservationId = reservation.reservationId;

    if (reservationId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar reserva'),
        content: Text(
          '¿Deseas cancelar la reserva #$reservationId de la plaza ${reservation.spaceId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancelar reserva'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _cancellingReservations.add(reservationId);
    });

    try {
      await _adminService.cancelReservation(
        session: widget.session,
        reservationId: reservationId,
      );

      if (!mounted) return;

      setState(_loadReservations);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reserva #$reservationId cancelada correctamente.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cancelar la reserva #$reservationId.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cancellingReservations.remove(reservationId);
        });
      }
    }
  }

  Widget _buildSummary(List<ParkingSpace> spaces) {
    final enabled = spaces.where((space) => space.available).length;
    final disabled = spaces.length - enabled;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Habilitadas',
            count: enabled,
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Deshabilitadas',
            count: disabled,
            icon: Icons.block_outlined,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSpaceCard(ParkingSpace space) {
    final isUpdating = _updatingSpaces.contains(space.id);
    final isDeleting = _deletingSpaces.contains(space.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: space.available
              ? Colors.green.withValues(alpha: 0.12)
              : Colors.red.withValues(alpha: 0.12),
          child: Icon(
            Icons.local_parking,
            color: space.available ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          space.code,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${space.zone} · ${space.location}'),
            const SizedBox(height: 4),
            Text(
              space.available ? 'Habilitada' : 'Deshabilitada',
              style: TextStyle(
                color: space.available ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: isUpdating || isDeleting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: space.available,
                    onChanged: (value) => _changeAvailability(space, value),
                  ),
                  IconButton(
                    tooltip: 'Eliminar plaza',
                    onPressed: () => _deleteParkingSpace(space),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSpacesTab() {
    return FutureBuilder<List<ParkingSpace>>(
      future: _spacesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildError(
            'No se pudieron cargar las plazas.',
            _refreshSpaces,
          );
        }

        final spaces = snapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: _refreshSpaces,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Panel de control',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Administra las plazas del estacionamiento.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              _buildSummary(spaces),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _creatingSpace ? null : _showCreateSpaceDialog,
                  icon: _creatingSpace
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(
                    _creatingSpace ? 'Creando plaza...' : 'Crear plaza',
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Gestión de plazas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (spaces.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No hay plazas registradas.')),
                )
              else
                ...spaces.map(_buildSpaceCard),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    final reservationId = reservation.reservationId;
    final isConfirmed = reservation.status == 'CONFIRMED';
    final isCancelling =
        reservationId != null &&
        _cancellingReservations.contains(reservationId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_parking),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reservation.spaceId,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusBadge(status: reservation.status),
              ],
            ),
            const Divider(height: 24),
            _ReservationInfo(
              icon: Icons.confirmation_number_outlined,
              label: 'Reserva',
              value: '#${reservationId ?? '-'}',
            ),
            _ReservationInfo(
              icon: Icons.person_outline,
              label: 'Usuario',
              value: reservation.userId?.toString() ?? 'No disponible',
            ),
            _ReservationInfo(
              icon: Icons.location_on_outlined,
              label: 'Ubicación',
              value: '${reservation.zone} · ${reservation.location}',
            ),
            _ReservationInfo(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha',
              value: reservation.date,
            ),
            _ReservationInfo(
              icon: Icons.access_time,
              label: 'Horario',
              value:
                  '${reservation.time} - ${reservation.endTime ?? 'No definido'}',
            ),
            if (isConfirmed) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isCancelling
                      ? null
                      : () => _cancelReservation(reservation),
                  icon: isCancelling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar reserva'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsTab() {
    return FutureBuilder<List<Reservation>>(
      future: _reservationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildError(
            'No se pudieron cargar las reservas.',
            _refreshReservations,
          );
        }

        final reservations = snapshot.data ?? [];

        final filteredReservations = reservations.where((reservation) {
          if (_reservationFilter == 'CONFIRMED') {
            return reservation.status == 'CONFIRMED';
          }

          if (_reservationFilter == 'CANCELLED') {
            return reservation.status == 'CANCELLED';
          }

          return true;
        }).toList();

        filteredReservations.sort((a, b) {
          return (b.reservationId ?? 0).compareTo(a.reservationId ?? 0);
        });

        final confirmedCount = reservations
            .where((reservation) => reservation.status == 'CONFIRMED')
            .length;

        final cancelledCount = reservations
            .where((reservation) => reservation.status == 'CANCELLED')
            .length;

        return RefreshIndicator(
          onRefresh: _refreshReservations,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Gestión de reservas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Consulta y administra las reservas del sistema.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Confirmadas',
                      count: confirmedCount,
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Canceladas',
                      count: cancelledCount,
                      icon: Icons.cancel_outlined,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _reservationFilter,
                decoration: const InputDecoration(
                  labelText: 'Filtrar reservas',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.filter_list),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'ALL',
                    child: Text('Todas las reservas'),
                  ),
                  DropdownMenuItem(
                    value: 'CONFIRMED',
                    child: Text('Confirmadas'),
                  ),
                  DropdownMenuItem(
                    value: 'CANCELLED',
                    child: Text('Canceladas'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _reservationFilter = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              if (filteredReservations.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('No hay reservas para este filtro.'),
                  ),
                )
              else
                ...filteredReservations.map(_buildReservationCard),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError(String message, Future<void> Function() retry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administración'),
          actions: [
            IconButton(
              tooltip: 'Actualizar información',
              onPressed: () {
                setState(_loadData);
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.local_parking), text: 'Plazas'),
              Tab(icon: Icon(Icons.calendar_month), text: 'Reservas'),
              Tab(icon: Icon(Icons.people_outline), text: 'Usuarios'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSpacesTab(),
            _buildReservationsTab(),
            AdminUsersTab(session: widget.session, adminService: _adminService),
          ],
        ),
      ),
    );
  }
}

class _ReservationInfo extends StatelessWidget {
  const _ReservationInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: Colors.grey),
          const SizedBox(width: 10),
          SizedBox(
            width: 85,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isConfirmed = status == 'CONFIRMED';
    final color = isConfirmed ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isConfirmed ? 'Confirmada' : 'Cancelada',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  final String title;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              '$count',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class _CreateParkingSpaceDialog extends StatefulWidget {
  const _CreateParkingSpaceDialog();

  @override
  State<_CreateParkingSpaceDialog> createState() =>
      _CreateParkingSpaceDialogState();
}

class _CreateParkingSpaceDialogState extends State<_CreateParkingSpaceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _zoneController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _zoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear plaza'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 20,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  hintText: 'Ej. A-28',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_parking),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el código de la plaza.';
                  }
                  if (value.trim().length > 20) {
                    return 'El código no puede superar 20 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _zoneController,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Zona',
                  hintText: 'Ej. Zona A',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa la zona.';
                  }
                  if (value.trim().length > 50) {
                    return 'La zona no puede superar 50 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                maxLength: 150,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  hintText: 'Ej. Cerca del Bloque 2',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa la ubicación.';
                  }
                  if (value.trim().length > 150) {
                    return 'La ubicación no puede superar 150 caracteres.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.add),
          label: const Text('Crear'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop({
      'code': _codeController.text.trim(),
      'zone': _zoneController.text.trim(),
      'location': _locationController.text.trim(),
    });
  }
}
