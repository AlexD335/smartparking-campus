class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.institutionalCode,
    required this.phone,
    required this.email,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.vehicleColor,
  });

  final int id;
  final String? fullName;
  final String? institutionalCode;
  final String? phone;
  final String email;
  final String? vehicleType;
  final String? vehiclePlate;
  final String? vehicleColor;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['id'] as num).toInt(),
      fullName: json['fullName'] as String?,
      institutionalCode: json['institutionalCode'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String,
      vehicleType: json['vehicleType'] as String?,
      vehiclePlate: json['vehiclePlate'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
    );
  }
}
