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
      'email': email,
      'phone': phone,
    });

    // 3. Attribution du rôle Docteur (role_id: 2)
    await supabase.from('user_roles').insert({
      'user_id': user.id,
      'role_id': 2,
    });

    // 4. Insertion des détails spécifiques au docteur
    await supabase.from('doctors').insert({
      'uid': user.id,
      'years_of_experience': yearsOfExperience,
      'license_number': licenseNumber,
      'bio': bio,
      'accountStatus': 'pending',
    });
  }

  /// Inscription d'un patient
  static Future<void> insertAllergy(String patientId,String nameAllergie)async{
    final supabase=Supabase.instance.client;
    final existing=await supabase.from('allergies').select('id').eq('name',nameAllergie).maybeSingle();
    String allergyId;
    if(existing==null){
      final res=await supabase.from('allergies').insert({'name':nameAllergie}).select('id').single();
      allergyId=res['id'];
    }else{
      allergyId=existing['id'];
    }
    await supabase.from('patient_allergies').insert({
      'patient_id':patientId,
      'allergy_id':allergyId,
    });
  }
  static Future<void> insertDesease(String patientId,String nameDesease)async{
    final supabase=Supabase.instance.client;
    final existing=await supabase.from('deseases').select('id').eq('name',nameDesease).maybeSingle();
    String deseaseId;
    if(existing==null){
      final res=await supabase.from('deseases').insert({'name':nameDesease}).select('id').single();
      deseaseId=res['id'];
    }else{
      deseaseId=existing['id'];
    }
    await supabase.from('patient_allergies').insert({
      'patient_id':patientId,
      'desease_id':deseaseId,
    });
  }
  static Future<String> signUpPatient({
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
      'email': email,
      'phone': phone,
      'address': address,
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
      'bloodType': bloodType,
      'height': height,
      'weight': weight,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'consultingNumber': 0,
      'accountStatus': 'active',
    });
    return user.id;
  }
}
