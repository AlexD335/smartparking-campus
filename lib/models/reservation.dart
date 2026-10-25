class Reservation {
  const Reservation({
    this.reservationId,
    this.parkingSpaceId,
    required this.spaceId,
    required this.zone,
    required this.location,
    required this.date,
    required this.time,
    this.status = 'CONFIRMED',
  });

  final int? reservationId;
  final int? parkingSpaceId;
  final String spaceId;
  final String zone;
  final String location;
  final String date;
  final String time;
  final String status;

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final parkingSpace = json['parkingSpace'] as Map<String, dynamic>;

    return Reservation(
      reservationId: (json['id'] as num).toInt(),
      parkingSpaceId: (parkingSpace['id'] as num).toInt(),
      spaceId: parkingSpace['code'] as String,
      zone: parkingSpace['zone'] as String,
      location: parkingSpace['location'] as String,
      date: _formatDate(json['reservationDate'] as String),
      time: _formatTime(json['reservationTime'] as String),
      status: json['status'] as String,
    );
  }

  static String _formatDate(String value) {
    final parts = value.split('-');

    if (parts.length != 3) return value;

    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  static String _formatTime(String value) {
    final parts = value.split(':');

    if (parts.length < 2) return value;

    final hour = int.tryParse(parts[0]);
    if (hour == null) return value;

    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:$minute $period';
  }
}
