class Appointment {
  final String id;
  final String patientId;
  final String doctorId;

  final DateTime dateTime;
  final String status; // pending | confirmed | cancelled

  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    required this.status,
    required this.createdAt,
  });
}
