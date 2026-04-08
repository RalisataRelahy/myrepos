import 'package:cloud_firestore/cloud_firestore.dart';
import 'prescription_model.dart';

class Patient {
  final String uid;

  final String firstName;
  final String lastName;
  final String? gender;
  final Timestamp dateOfBirth;
  final String phone;
  final String email;
  final String? address;

  final String? bloodType; // "A+", "A-", etc.
  final double? height;
  final double? weight;
  final String? tension; // systolic/diastolic si besoin

  final List<String>? allergies;
  final List<String>? chronicDiseases;
  final List<String>? currentMedications;
  final List<Prescription> treatmentAntecedent;

  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final int consultingNumber;

  final String accountStatus; // "active" ou "suspended"
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Patient({
    required this.uid,
    required this.firstName,
    required this.lastName,
    this.gender,
    required this.dateOfBirth,
    required this.phone,
    required this.email,
    this.address,
    this.bloodType,
    this.height,
    this.weight,
    this.tension,
    this.allergies,
    this.chronicDiseases,
    this.currentMedications,
    required this.treatmentAntecedent,
    this.emergencyContactName,
    this.emergencyContactPhone,
    required this.consultingNumber,
    required this.accountStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  // Méthode pour convertir depuis Firestore
  factory Patient.fromMap(Map<String, dynamic> data) {
    String toStringSafe(dynamic value) {
      if (value == null) return "";
      if (value is String) return value;
      if (value is int || value is double) return value.toString();
      if (value is List && value.isNotEmpty) return value.first.toString();
      return value.toString();
    }

    List<String>? toStringListSafe(dynamic value) {
      if (value == null) return null;
      if (value is List) return value.map((e) => e.toString()).toList();
      return [value.toString()];
    }

    Timestamp toTimestamp(dynamic value) {
      if (value is Timestamp) return value;
      if (value is DateTime) return Timestamp.fromDate(value);
      throw Exception("Invalid timestamp value");
    }

    double? toDoubleSafe(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return Patient(
      uid: toStringSafe(data['uid']),
      firstName: toStringSafe(data['firstName']),
      lastName: toStringSafe(data['lastName']),
      gender: toStringSafe(data['gender']).isEmpty
          ? null
          : toStringSafe(data['gender']),
      dateOfBirth: toTimestamp(data['dateOfBirth']),
      phone: toStringSafe(data['phone']),
      email: toStringSafe(data['email']),
      address: toStringSafe(data['address']).isEmpty
          ? null
          : toStringSafe(data['address']),
      bloodType: toStringSafe(data['bloodType']).isEmpty
          ? null
          : toStringSafe(data['bloodType']),
      height: toDoubleSafe(data['height']),
      weight: toDoubleSafe(data['weight']),
      tension: toStringSafe(data['tension']).isEmpty
          ? null
          : toStringSafe(data['tension']),
      allergies: toStringListSafe(data['allergies']),
      chronicDiseases: toStringListSafe(data['chronicDiseases']),
      currentMedications: toStringListSafe(data['currentMedications']),
      treatmentAntecedent: data['treatmentAntecedent'] != null
          ? (data['treatmentAntecedent'] as List)
                .map((e) => Prescription.fromMap(e))
                .toList()
          : [],
      emergencyContactName: toStringSafe(data['emergencyContactName']).isEmpty
          ? null
          : toStringSafe(data['emergencyContactName']),
      emergencyContactPhone: toStringSafe(data['emergencyContactPhone']).isEmpty
          ? null
          : toStringSafe(data['emergencyContactPhone']),
      consultingNumber: data['consultingNumber'] is int
          ? data['consultingNumber']
          : int.tryParse(toStringSafe(data['consultingNumber'])) ?? 0,
      accountStatus: toStringSafe(data['accountStatus']),
      createdAt: toTimestamp(data['createdAt']),
      updatedAt: toTimestamp(data['updatedAt']),
    );
  }

  // Méthode pour convertir vers Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'phone': phone,
      'email': email,
      'address': address,
      'bloodType': bloodType,
      'height': height,
      'weight': weight,
      'tension': tension,
      'allergies': allergies,
      'chronicDiseases': chronicDiseases,
      'currentMedications': currentMedications,
      'treatmentAntecedent': treatmentAntecedent.map((e) => e.toMap()).toList(),
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'consultingNumber': consultingNumber,
      'accountStatus': accountStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
