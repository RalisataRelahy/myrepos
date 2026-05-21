import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static Future<String> getRole(String userId) async {
    final supabase = Supabase.instance.client;

    final res = await supabase
        .from('user_roles')
        .select('role_id')
        .eq('user_id', userId)
        .single();

    final roleId = res['role_id'];

    if (roleId == 2) {
      return 'doctor';
    } else {
      return 'patient';
    }
  }
}