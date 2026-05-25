import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medilink_app/pages/public/logout.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {

  void _modifymdp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Changer mot de passe"),
        content: const Text(
          "Cette fonctionnalité sera disponible prochainement.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _getProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    final res = await supabase
        .from('profiles')
        .select('first_name, last_name')
        .eq('id', user.id)
        .single();

    return res;
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    return Drawer(
      child: Container(
        color: Colors.blue,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _getProfile(),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            String name = "Utilisateur";
            String email = user?.email ?? "";

            if (snapshot.hasData && snapshot.data != null) {
              final data = snapshot.data!;
              name = "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}".trim();
            }

            return ListView(
              padding: EdgeInsets.zero,
              children: [

                /// HEADER
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Colors.blue),
                  accountName: Text(name),
                  accountEmail: Text(email),
                  currentAccountPicture: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),

                /// PROFILE
                drawerItem(
                  context: context,
                  icon: Icons.person,
                  title: "Profile",
                  page: const Placeholder(), // remplace par ta page
                ),

                /// CHANGE PASSWORD
                drawerItem(
                  context: context,
                  icon: Icons.lock,
                  title: "Change Password",
                  action: _modifymdp,
                ),

                /// LOGOUT
                drawerItem(
                  context: context,
                  icon: Icons.logout,
                  title: "Logout",
                  action: () async {
                    await supabase.auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LogoutPage()),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget drawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    Widget? page,
    VoidCallback? action,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (action != null) {
          action();
        } else if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        }
      },
    );
  }
}