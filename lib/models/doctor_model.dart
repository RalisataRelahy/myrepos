import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  // Référence
  final String uid;

  // Infos personnelles
  final String firstName;
  final String lastName;
  final Timestamp dateOfBirth;
  final String address;
  final String phone;
  final String email;

  // Infos professionnelles
  final String licenseNumber;
  final List<String> diplomaLevel;
  final int yearsOfExperience;
  final List<String> speciality;

  // Général
  final List<String> languages;
  final String? bio;
  final double rating;

  // Cabinet
  final String clinicName;
  final double? consultationFee;

  // Statut compte
  final String accountStatus; // "pending", "verified", "suspended"

  // Dates
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Doctor({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.address,
    required this.phone,
    required this.email,
    required this.licenseNumber,
    required this.diplomaLevel,
    required this.yearsOfExperience,
    required this.speciality,
    required this.languages,
    this.bio,
    required this.rating,
    required this.clinicName,
    this.consultationFee,
    required this.accountStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  // Conversion depuis Firestore
  factory Doctor.fromMap(Map<String, dynamic> data) {
    return Doctor(
      uid: data['uid'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      dateOfBirth: data['dateOfBirth'],
      address: data['address'],
      phone: data['phone'],
      email: data['email'],
      licenseNumber: data['licenseNumber'],
      diplomaLevel: List<String>.from(data['diplomaLevel']),
      yearsOfExperience: data['yearsOfExperience'],
      speciality: List<String>.from(data['speciality']),
      languages: List<String>.from(data['languages']),
      bio: data['bio'],
      rating: (data['rating'] as num).toDouble(),
      clinicName: data['clinicName'],
      consultationFee: data['consultationFee'] != null
          ? (data['consultationFee'] as num).toDouble()
          : null,
      accountStatus: data['accountStatus'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  // Conversion vers Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'phone': phone,
      'email': email,
      'licenseNumber': licenseNumber,
      'diplomaLevel': diplomaLevel,
      'yearsOfExperience': yearsOfExperience,
      'speciality': speciality,
      'languages': languages,
      'bio': bio,
      'rating': rating,
      'clinicName': clinicName,
      'consultationFee': consultationFee,
      'accountStatus': accountStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
