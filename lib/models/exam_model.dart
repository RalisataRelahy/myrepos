class Exam {
  final String id;
  final String consultationId;

  final String name;
  final String? result;
  final String? fileUrl;

  final DateTime createdAt;

  Exam({
    required this.id,
    required this.consultationId,
    required this.name,
    this.result,
    this.fileUrl,
    required this.createdAt,
  });
}
