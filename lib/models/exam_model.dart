import 'package:cloud_firestore/cloud_firestore.dart';

class Exam {
  final String id; // identifiant unique
  final String name; // nom de l'examen
  final String? description; // détails optionnels
  final DateTime? recommendedDate; // date recommandée
  final String? results; // résultats si déjà fait
  final String? status; // "recommandé", "en cours", "réalisé"

  Exam({
    required this.id,
    required this.name,
    this.description,
    this.recommendedDate,
    this.results,
    this.status,
  });

  // Conversion depuis Firestore / Map
  factory Exam.fromMap(Map<String, dynamic> data) {
    return Exam(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      recommendedDate: data['recommendedDate'] != null
          ? (data['recommendedDate'] as Timestamp).toDate()
          : null,
      results: data['results'],
      status: data['status'],
    );
  }

  // Conversion vers Firestore / Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'recommendedDate': recommendedDate != null
          ? Timestamp.fromDate(recommendedDate!)
          : null,
      'results': results,
      'status': status,
    };
  }
}
