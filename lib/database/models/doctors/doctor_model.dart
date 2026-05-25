class Doctor {
  // Identity
  final String id; // = auth.users.id

  // Personal info
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  final DateTime dateOfBirth;

  // Professional info
  final String licenseNumber;
  final int yearsOfExperience;
  final String? bio;

  // Status
  final String accountStatus; // pending | verified | suspended

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.licenseNumber,
    required this.yearsOfExperience,
    this.bio,
    required this.accountStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Doctor.fromMap(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      licenseNumber: json['license_number'],
      yearsOfExperience: json['years_of_experience'],
      bio: json['bio'],
      accountStatus: json['account_status'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'license_number': licenseNumber,
      'years_of_experience': yearsOfExperience,
      'bio': bio,
      'account_status': accountStatus,
    };
  }
}
