class Consultation {
  final String id;
  final String patientId;
  final String doctorId;

  final DateTime date;
  final String type; // presencial | urgent
  final String status; // planned | done | cancelled

  final String? notes;
  final String reason;

  final DateTime createdAt;
  final DateTime updatedAt;

  Consultation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.date,
    required this.type,
    required this.status,
    this.notes,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
  });
}
