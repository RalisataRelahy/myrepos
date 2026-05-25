class OrdonnanceModel {
  final String id;
  final String consultationId;
  final DateTime createdAt;
  final String doctorId;
  final String patientId;

  OrdonnanceModel({
    required this.id,
    required this.consultationId,
    required this.createdAt,
    required this.doctorId,
    required this.patientId,
  });
}