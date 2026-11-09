import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '../models/auth_session.dart';
import '../services/admin_service.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({
    super.key,
    required this.session,
    required this.adminService,
  });

  final AuthSession session;
  final AdminService adminService;

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  late Future<List<AdminUser>> _usersFuture;
  final TextEditingController _searchController = TextEditingController();

  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    _usersFuture = widget.adminService.getAllUsers(widget.session);
  }

  Future<void> _refreshUsers() async {
    setState(_loadUsers);
    await _usersFuture;
  }

  Future<void> _showUserDetails(AdminUser user) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => _UserDetailsDialog(
        user: user,
        session: widget.session,
        adminService: widget.adminService,
      ),
    );

    if (updated == true && mounted) {
      setState(_loadUsers);
    }
  }

  Widget _buildUserCard(AdminUser user) {
    final isAdmin = user.role == 'ADMIN';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          child: Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person_outline,
          ),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.badge_outlined,
                  size: 15,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 5),
                Text('ID: ${user.id}'),
                const SizedBox(width: 10),
                _RoleBadge(role: user.role),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showUserDetails(user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdminUser>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildError();
        }

        final users = snapshot.data ?? [];

        final filteredUsers = users.where((user) {
          final query = _search.toLowerCase();

          return user.fullName.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              user.id.toString().contains(query);
        }).toList();

        return RefreshIndicator(
          onRefresh: _refreshUsers,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Gestión de usuarios',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Consulta y administra los usuarios registrados.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar usuario',
                  hintText: 'Nombre, correo o ID',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _search = '');
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() => _search = value);
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _UserCountCard(
                      title: 'Usuarios',
                      count: users.length,
                      icon: Icons.people_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _UserCountCard(
                      title: 'Administradores',
                      count: users.where((u) => u.role == 'ADMIN').length,
                      icon: Icons.admin_panel_settings_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Usuarios registrados (${filteredUsers.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (filteredUsers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No se encontraron usuarios.')),
                )
              else
                ...filteredUsers.map(_buildUserCard),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            const Text(
              'No se pudieron cargar los usuarios.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => setState(_loadUsers),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserDetailsDialog extends StatelessWidget {
  const _UserDetailsDialog({
    required this.user,
    required this.session,
    required this.adminService,
  });

  final AdminUser user;
  final AuthSession session;
  final AdminService adminService;

  String _value(String? value) {
    return value == null || value.isEmpty ? 'No registrado' : value;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Información del usuario'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailField(label: 'Nombre', value: user.fullName),
            _DetailField(label: 'Correo', value: user.email),
            _DetailField(
              label: 'Documento',
              value:
                  '${_value(user.documentType)} · ${_value(user.documentNumber)}',
            ),
            _DetailField(label: 'Teléfono', value: _value(user.phone)),
            const Divider(height: 24),
            const Text(
              'Información del vehículo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _DetailField(label: 'Tipo', value: _value(user.vehicleType)),
            _DetailField(label: 'Placa', value: _value(user.vehiclePlate)),
            _DetailField(label: 'Color', value: _value(user.vehicleColor)),
            const Divider(height: 24),
            Row(
              children: [
                const Text(
                  'Rol: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _RoleBadge(role: user.role),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Identificador: ${user.id}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cerrar'),
        ),
        FilledButton.icon(
          onPressed: () async {
            final updated = await showDialog<bool>(
              context: context,
              builder: (_) => _EditUserDialog(
                user: user,
                session: session,
                adminService: adminService,
              ),
            );

            if (updated == true && context.mounted) {
              Navigator.pop(context, true);
            }
          },
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar'),
        ),
      ],
    );
  }
}

class _EditUserDialog extends StatefulWidget {
  const _EditUserDialog({
    required this.user,
    required this.session,
    required this.adminService,
  });

  final AdminUser user;
  final AuthSession session;
  final AdminService adminService;

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _documentNumberController;
  late final TextEditingController _phoneController;
  late final TextEditingController _vehicleTypeController;
  late final TextEditingController _plateController;
  late final TextEditingController _colorController;

  String? _documentType;
  bool _saving = false;

  static const _documentTypes = ['CC', 'TI', 'CE', 'PA', 'PPT'];

  @override
  void initState() {
    super.initState();

    final user = widget.user;

    _nameController = TextEditingController(text: user.fullName);
    _emailController = TextEditingController(text: user.email);
    _documentNumberController = TextEditingController(
      text: user.documentNumber ?? '',
    );
    _phoneController = TextEditingController(text: user.phone ?? '');
    _vehicleTypeController = TextEditingController(
      text: user.vehicleType ?? '',
    );
    _plateController = TextEditingController(text: user.vehiclePlate ?? '');
    _colorController = TextEditingController(text: user.vehicleColor ?? '');

    _documentType = user.documentType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _documentNumberController.dispose();
    _phoneController.dispose();
    _vehicleTypeController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if ((_documentType == null || _documentType!.isEmpty) !=
        _documentNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indica el tipo y número de documento.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await widget.adminService.updateUser(
        session: widget.session,
        userId: widget.user.id,
        data: {
          'fullName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'documentType': _documentType,
          'documentNumber': _documentNumberController.text.trim(),
          'phone': _phoneController.text.trim(),
          'vehicleType': _vehicleTypeController.text.trim(),
          'vehiclePlate': _plateController.text.trim(),
          'vehicleColor': _colorController.text.trim(),
        },
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el usuario: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: label == 'Nombre' || label == 'Correo'
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }

                if (label == 'Correo' && !value.contains('@')) {
                  return 'Introduce un correo válido';
                }

                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar usuario'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field('Nombre', _nameController),
                _field(
                  'Correo',
                  _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _documentType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de documento',
                    border: OutlineInputBorder(),
                  ),
                  items: _documentTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _documentType = value);
                  },
                ),
                const SizedBox(height: 14),
                _field('Número de documento', _documentNumberController),
                _field(
                  'Teléfono',
                  _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const Divider(height: 28),
                _field('Tipo de vehículo', _vehicleTypeController),
                _field('Placa', _plateController),
                _field('Color', _colorController),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar cambios'),
        ),
      ],
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'ADMIN';
    final color = isAdmin ? Colors.deepPurple : Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAdmin ? 'ADMIN' : 'USER',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _UserCountCard extends StatelessWidget {
  const _UserCountCard({
    required this.title,
    required this.count,
    required this.icon,
  });

  final String title;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 26),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}
