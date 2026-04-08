import 'package:cloud_firestore/cloud_firestore.dart';
import 'treatments_model.dart';

class Prescription {
  final String id;

  // Relations
  final String patientId;
  final String doctorId;

  // Contexte
  final String? diagnosis;
  final String? notePrescription;

  // Liste des traitements
  final List<Treatment> treatments;

  // Statut
  final String status; // "active", "completed", "cancelled"

  // Dates
  final Timestamp issuedAt;
  // final Timestamp? expiresAt; // si tu veux gérer la date d'expiration
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Prescription({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.diagnosis,
    this.notePrescription,
    required this.treatments,
    required this.status,
    required this.issuedAt,
    // this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Méthode pour convertir depuis Firestore
  factory Prescription.fromMap(Map<String, dynamic> data) {
    return Prescription(
      id: data['id'],
      patientId: data['patientId'],
      doctorId: data['doctorId'],
      diagnosis: data['diagnosis'],
      notePrescription: data['notePrescription'],
      treatments: data['treatments'] != null
          ? (data['treatments'] as List)
                .map((e) => Treatment.fromMap(e))
                .toList()
          : [],
      status: data['status'],
      issuedAt: data['issuedAt'],
      // expiresAt: data['expiresAt'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  // Méthode pour convertir vers Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'diagnosis': diagnosis,
      'notePrescription': notePrescription,
      'treatments': treatments.map((e) => e.toMap()).toList(),
      'status': status,
      'issuedAt': issuedAt,
      // 'expiresAt': expiresAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
