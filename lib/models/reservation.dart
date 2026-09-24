class Reservation {
  const Reservation({
    required this.spaceId,
    required this.zone,
    required this.location,
    required this.date,
    required this.time,
  });

  final String spaceId;
  final String zone;
  final String location;
  final String date;
  final String time;
}