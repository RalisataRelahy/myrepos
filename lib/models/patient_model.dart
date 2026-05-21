class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  final String? gender;
  final DateTime dateOfBirth;
  final String? address;

  final String? bloodType;
  final double? height;
  final double? weight;

  final String? emergencyContactName;
  final String? emergencyContactPhone;

  final String accountStatus;

  final int consultationCount;

  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.gender,
    required this.dateOfBirth,
    this.address,
    this.bloodType,
    this.height,
    this.weight,
    this.emergencyContactName,
    this.emergencyContactPhone,
    required this.accountStatus,
    required this.consultationCount,
    required this.createdAt,
    required this.updatedAt,
  });
}
