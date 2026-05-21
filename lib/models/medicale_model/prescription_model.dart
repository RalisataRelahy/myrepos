class Prescription {
  final String id;
  final String consultationId;
  final String patientId;

  final String? description;
  final String fileUrl;

  final DateTime createdAt;

  Prescription({
    required this.id,
    required this.consultationId,
    required this.patientId,
    this.description,
    required this.fileUrl,
    required this.createdAt,
  });
}
