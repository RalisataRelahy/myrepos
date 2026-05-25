
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/patient_model_ui.dart';

class UserService {

  // 🔹 récupérer utilisateur connecté
  static User? getCurrentUser() {
    final supabase = Supabase.instance.client;
    return supabase.auth.currentUser;
  }

  // 🔹 récupérer ID utilisateur
  static String? getUserId() {
    return getCurrentUser()?.id;
  }

  static Map<String, dynamic>?_cache;

  static Future<Map<String,dynamic>> getDoctorProfile(String uid) async {
    if(_cache != null)return _cache!;

    final supabase=Supabase.instance.client;

    final data=await supabase.from('users').select().eq('id',uid).single();
    _cache=data;
    return data;
  }
  // 🔹 récupérer rôle (version propre)
  static Future<String> getRole(String userId) async {
    final supabase = Supabase.instance.client;

    final res = await supabase
        .from('user_roles')
        .select('roles(name)')
        .eq('user_id', userId)
        .single();

    return res['roles']['name'];
  }

  static Future<Patient> getPatientProfile(String userId) async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('profiles')
        .select('''
        id,
        first_name,
        last_name,
        email,
        phone,
        address,
        avatar_url,
        created_at,
        updated_at,

        patient:patients (
          gender,
          date_of_birth,
          blood_type,
          height,
          weight,
          emergency_contact_name,
          emergency_contact_phone,
          account_status,
          consulting_number,
          created_at,
          updated_at,

          patient_allergies (
            allergies (name)
          ),
          
          patient_diseases (
            diseases (name)
          )
        )
      ''')
        .eq('id', userId)
        .single();

    return Patient.fromJson(data);
  }








}