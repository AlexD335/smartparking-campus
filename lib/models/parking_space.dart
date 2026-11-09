class ParkingSpace {
  const ParkingSpace({
    required this.id,
    required this.code,
    required this.zone,
    required this.location,
    required this.available,
  });

  final int id;
  final String code;
  final String zone;
  final String location;
  final bool available;

  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      zone: json['zone'] as String,
      location: json['location'] as String,
      available: json['available'] as bool,
    );
  }
}
