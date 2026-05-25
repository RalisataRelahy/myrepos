class Patient {
  final String id;

  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;

  final String? bloodType;
  final double? height;
  final double? weight;
  final String? tension;

  final List<String> allergies;
  final List<String> chronicDiseases;

  final String? emergencyContactName;
  final String? emergencyContactPhone;

  final int consultingNumber;

  final String accountStatus;

  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.bloodType,
    this.height,
    this.weight,
    this.tension,
    required this.allergies,
    required this.chronicDiseases,
    this.emergencyContactName,
    this.emergencyContactPhone,
    required this.consultingNumber,
    required this.accountStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    final patient = json['patient']; // alias depuis ta requête

    return Patient(
      id: json['id'],

      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],

      dateOfBirth: patient?['date_of_birth'] != null
          ? DateTime.parse(patient['date_of_birth'])
          : null,

      gender: patient?['gender'],
      address: json['address'],

      bloodType: patient?['blood_type'],
      height: patient?['height'] != null
          ? (patient['height'] as num).toDouble()
          : null,
      weight: patient?['weight'] != null
          ? (patient['weight'] as num).toDouble()
          : null,

      tension: patient?['tension'],

      allergies: (patient?['patient_allergies'] as List?)
          ?.map((e) => e['allergies']?['name'] as String?)
          .whereType<String>()
          .toList() ??
          [],

      chronicDiseases: (patient?['patient_diseases'] as List?)
          ?.map((e) => e['diseases']?['name'] as String?)
          .whereType<String>()
          .toList() ??
          [],

      emergencyContactName: patient?['emergency_contact_name'],
      emergencyContactPhone: patient?['emergency_contact_phone'],

      consultingNumber: patient?['consulting_number'] ?? 0,

      accountStatus: patient?['account_status'] ?? 'active',

      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}