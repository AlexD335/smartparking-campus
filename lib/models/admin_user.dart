class AdminUser {
  const AdminUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.documentType,
    this.documentNumber,
    this.phone,
    this.vehicleType,
    this.vehiclePlate,
    this.vehicleColor,
    required this.role,
  });

  final int id;
  final String fullName;
  final String email;
  final String? documentType;
  final String? documentNumber;
  final String? phone;
  final String? vehicleType;
  final String? vehiclePlate;
  final String? vehicleColor;
  final String role;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: (json['id'] as num).toInt(),
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      documentType: json['documentType'] as String?,
      documentNumber: json['documentNumber'] as String?,
      phone: json['phone'] as String?,
      vehicleType: json['vehicleType'] as String?,
      vehiclePlate: json['vehiclePlate'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      role: json['role'] as String? ?? 'USER',
    );
  }
}
