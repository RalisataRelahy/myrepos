class Review {
  final String id;
  final String patientId;
  final String doctorId;

  final int rating;
  final String? comment;

  final DateTime createdAt;

  Review({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });
}
