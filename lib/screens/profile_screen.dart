import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.session});

  final AuthSession? session;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfileService _service = UserProfileService();

  final _fullNameController = TextEditingController();
  final _institutionalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _vehicleColorController = TextEditingController();

  UserProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _institutionalCodeController.dispose();
    _phoneController.dispose();
    _vehicleTypeController.dispose();
    _vehiclePlateController.dispose();
    _vehicleColorController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final session = widget.session;

    if (session == null) {
      setState(() {
        _isLoading = false;
        _error = 'No hay una sesión autenticada.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await _service.getProfile(session);

      if (!mounted) return;

      _profile = profile;
      _fullNameController.text = profile.fullName ?? '';
      _institutionalCodeController.text = profile.institutionalCode ?? '';
      _phoneController.text = profile.phone ?? '';
      _vehicleTypeController.text = profile.vehicleType ?? '';
      _vehiclePlateController.text = profile.vehiclePlate ?? '';
      _vehicleColorController.text = profile.vehicleColor ?? '';

      setState(() => _isLoading = false);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    final session = widget.session;

    if (session == null || _profile == null) return;

    if (_fullNameController.text.trim().isEmpty) {
      _showMessage('El nombre completo es obligatorio.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedProfile = await _service.updateProfile(
        session: session,
        data: {
          'fullName': _fullNameController.text.trim(),
          'institutionalCode': _institutionalCodeController.text.trim(),
          'phone': _phoneController.text.trim(),
          'vehicleType': _vehicleTypeController.text.trim(),
          'vehiclePlate': _vehiclePlateController.text.trim(),
          'vehicleColor': _vehicleColorController.text.trim(),
        },
      );

      if (!mounted) return;

      _profile = updatedProfile;

      setState(() => _isSaving = false);

      _showMessage('Perfil actualizado correctamente.');
    } catch (error) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    final profile = _profile!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 48)),
        const SizedBox(height: 12),
        Text(
          profile.fullName?.isNotEmpty == true
              ? profile.fullName!
              : 'Completa tu perfil',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 28),

        const Text(
          'Información personal',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        _buildField(
          label: 'Nombre completo',
          controller: _fullNameController,
          icon: Icons.person_outline,
        ),
        _buildField(
          label: 'Código institucional',
          controller: _institutionalCodeController,
          icon: Icons.badge_outlined,
        ),
        _buildField(
          label: 'Teléfono',
          controller: _phoneController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),

        TextField(
          readOnly: true,
          controller: TextEditingController(text: profile.email),
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          readOnly: true,
          controller: TextEditingController(
            text: widget.session?.role == 'ADMIN'
                ? 'Administrador'
                : 'Estudiante',
          ),
          decoration: const InputDecoration(
            labelText: 'Rol de usuario',
            prefixIcon: Icon(Icons.admin_panel_settings_outlined),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 28),

        const Text(
          'Información del vehículo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        _buildField(
          label: 'Tipo de vehículo',
          controller: _vehicleTypeController,
          icon: Icons.directions_car_outlined,
        ),
        _buildField(
          label: 'Placa',
          controller: _vehiclePlateController,
          icon: Icons.confirmation_number_outlined,
        ),
        _buildField(
          label: 'Color',
          controller: _vehicleColorController,
          icon: Icons.palette_outlined,
        ),

        const SizedBox(height: 8),

        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveProfile,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isSaving ? 'Guardando...' : 'Guardar cambios'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            tooltip: 'Actualizar perfil',
            onPressed: _isLoading ? null : _loadProfile,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProfile,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : _buildProfileForm(),
    );
  }
}
