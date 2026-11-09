class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.documentType,
    required this.documentNumber,
    required this.phone,
    required this.email,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.vehicleColor,
  });

  final int id;
  final String? fullName;
  final String? documentType;
  final String? documentNumber;
  final String? phone;
  final String email;
  final String? vehicleType;
  final String? vehiclePlate;
  final String? vehicleColor;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['id'] as num).toInt(),
      fullName: json['fullName'] as String?,
      documentType: json['documentType'] as String?,
      documentNumber: json['documentNumber'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String,
      vehicleType: json['vehicleType'] as String?,
      vehiclePlate: json['vehiclePlate'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
    );
  }
}
