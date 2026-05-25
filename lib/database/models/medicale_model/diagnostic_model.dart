class Diagnostic {
  final String id;
  final String consultationId;

  final String description;
  final String severity;

  final DateTime createdAt;

  Diagnostic({
    required this.id,
    required this.consultationId,
    required this.description,
    required this.severity,
    required this.createdAt,
  });
}
