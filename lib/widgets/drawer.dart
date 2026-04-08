import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medilink_app/pages/doctor_page/profil_patient_for_d.dart';
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
            onPressed: () => Scaffold.of(context).closeDrawer(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Container(
        color: Colors.blue,
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('patients')
              .doc(user!.uid)
              .get(),
          builder: (context, snapshot) {
            String name = "Utilisateur";
            String email = user.email ?? "";

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;

              name = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}"
                  .trim();
            }

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                /// HEADER PROFILE
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Colors.blue),
                  accountName: Text(name),
                  accountEmail: Text(email),
                  currentAccountPicture: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),

                /// MENU
                drawerItem(
                  context: context,
                  icon: Icons.person,
                  title: "Profile",
                  page: PatientProfilePage(patientUid: user.uid),
                ),

                drawerItem(
                  context: context,
                  icon: Icons.lock,
                  title: "Change Password",
                  action: _modifymdp, // référence de la fonction, sans ()
                ),

                drawerItem(
                  context: context,
                  icon: Icons.logout,
                  title: "Logout",
                  page: const LogoutPage(),
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
          action(); // exécute la fonction si action est fournie
        } else if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        }
      },
    );
  }
}
