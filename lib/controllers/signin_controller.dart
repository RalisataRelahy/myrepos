import 'package:supabase_flutter/supabase_flutter.dart';

class SigninController {
  /// Inscription d'un médeci
  static Future<void> signUpDoctor({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime? dateOfBirth,
    required String phone,
    required String address,
    required int yearsOfExperience,
    required String gender,
    String? bio,
    required String licenseNumber,
  }) async {
    final supabase = Supabase.instance.client;
    
    // 1. Création du compte Auth
    final res = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user == null) throw Exception("L'inscription a échoué.");

    // 2. Insertion dans le profil de base
    await supabase.from('profiles').insert({
      'id': user.id,
      'first_name': firstName,
      'last_name': lastName,
    });

    // 3. Attribution du rôle Docteur (role_id: 2)
    await supabase.from('user_roles').insert({
      'user_id': user.id,
      'role_id': 2,
    });

    // 4. Insertion des détails spécifiques au docteur
    await supabase.from('doctors').insert({
      'uid': user.id,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'phone': phone,
      'email': email,
      'yearsOfExperience': yearsOfExperience,
      'licenseNumber': licenseNumber,
      'bio': bio,
      'accountStatus': 'pending',
    });
  }

  /// Inscription d'un patient
  static Future<void> signUpPatient({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String gender,
    required String phone,
    String? address,
    String? bloodType,
    double? height,
    double? weight,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    final supabase = Supabase.instance.client;

    // 1. Création du compte Auth
    final res = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user == null) throw Exception("L'inscription a échoué.");

    // 2. Insertion dans le profil de base
    await supabase.from('profiles').insert({
      'id': user.id,
      'first_name': firstName,
      'last_name': lastName,
    });

    // 3. Attribution du rôle Patient (role_id: 1)
    await supabase.from('user_roles').insert({
      'user_id': user.id,
      'role_id': 1,
    });

    // 4. Insertion des détails spécifiques au patient
    await supabase.from('patients').insert({
      'id': user.id,
      'gender': gender,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'phone': phone,
      'email': email,
      'address': address,
      'bloodType': bloodType,
      'height': height,
      'weight': weight,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'consultingNumber': 0,
      'accountStatus': 'active',
    });
  }
}
