import 'package:cloud_firestore/cloud_firestore.dart';
import 'prescription_model.dart';
import 'exam_model.dart';
import 'diagnostic_model.dart';

class Consultation {
  final String id;
  final String patientId;
  final String doctorId;
  final Timestamp date;
  final String type; // "présentiel" | "urgente"
  final String status; // "prévue" | "terminée" | "annulée"
  final String? notes;
  final String motifs;

  final List<Diagnostic>? diagnostics;
  final List<Exam>? exams;
  final Prescription? prescriptions;

  final Timestamp createdAt;
  final Timestamp updatedAt;

  Consultation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.date,
    required this.type,
    required this.status,
    this.notes,
    required this.motifs,
    this.diagnostics,
    this.exams,
    this.prescriptions,
    required this.createdAt,
    required this.updatedAt,
  });

  // Conversion depuis Firestore / Map
  factory Consultation.fromMap(Map<String, dynamic> data) {
    return Consultation(
      id: data['id'],
      patientId: data['patientId'],
      doctorId: data['doctorId'],
      date: data['date'],
      type: data['type'],
      status: data['status'],
      notes: data['notes'],
      motifs: data['motifs'],
      diagnostics: data['diagnostics'] != null
          ? (data['diagnostics'] as List)
                .map((e) => Diagnostic.fromMap(e))
                .toList()
          : null,
      exams: data['exams'] != null
          ? (data['exams'] as List).map((e) => Exam.fromMap(e)).toList()
          : null,
      prescriptions: data['prescriptions'] != null
          ? Prescription.fromMap(data['prescriptions'])
          : null,
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  // Conversion vers Firestore / Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'date': date,
      'type': type,
      'status': status,
      'notes': notes,
      'motifs': motifs,
      'diagnostics': diagnostics?.map((e) => e.toMap()).toList(),
      'exams': exams?.map((e) => e.toMap()).toList(),
      'prescriptions': prescriptions?.toMap(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
