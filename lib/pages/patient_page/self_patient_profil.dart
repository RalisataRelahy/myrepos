// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Supprimer l'import de intl
// import 'package:intl/intl.dart';

import 'package:medilink_app/pages/patient_page/edit_profile_patient.dart';
import 'package:medilink_app/pages/public/logout.dart';

class PatientProfilePage extends StatelessWidget {
  const PatientProfilePage({super.key});

  // Méthode pour formater la date en français sans intl
  String _formatFrenchDate(DateTime date) {
    const frenchMonths = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${frenchMonths[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Non authentifié")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogoutPage()),
              ),
            },
            icon: Icon(Icons.logout),
          ),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Profil introuvable"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return _buildProfileContent(context, data);
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Map<String, dynamic> data) {
    final theme = Theme.of(context);

    // Gestion sécurisée des strings
    String getStringValue(dynamic value) {
      if (value == null) return "";
      if (value is String) return value.trim();
      if (value is List && value.isNotEmpty) {
        return value.first.toString().trim();
      }
      return value.toString();
    }

    final String firstName = getStringValue(data['firstName']);
    final String lastName = getStringValue(data['lastName']);
    final String fullName = "$firstName $lastName".trim();
    final String displayName = fullName.isEmpty ? "Patient" : fullName;

    // Calcul de l'âge et formatage de la date sans intl
    String ageText = "Âge non renseigné";
    String formattedDob = "Non renseignée";

    if (data['dateOfBirth'] is Timestamp) {
      final dob = (data['dateOfBirth'] as Timestamp).toDate();
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      ageText = "$age ans";
      formattedDob = _formatFrenchDate(dob);
    }

    final email = getStringValue(data['email']);
    final bloodType = getStringValue(data['bloodType']);
    final height = data['height'] != null ? data['height'].toString() : "—";
    final weight = data['weight'] != null ? data['weight'].toString() : "—";
    final tension = getStringValue(data['tension']);

    final emergencyName = getStringValue(data['emergencyContactName']);
    final emergencyPhone = getStringValue(data['emergencyContactPhone']);
    final address = getStringValue(data['address']);

    final List<String> allergies = _safeList(data['allergies']);
    final List<String> chronic = _safeList(data['chronicDiseases']);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 400));
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  // Photo de profil + nom
                  Hero(
                    tag: "profile-avatar",
                    child: CircleAvatar(
                      radius: 62,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.15,
                      ),
                      child: CircleAvatar(
                        radius: 58,
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : "?",
                          style: TextStyle(
                            fontSize: 42,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    displayName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$ageText • $formattedDob",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email.isNotEmpty ? email : "—",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // Carte médicale principale
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _buildMedicalCard(
                context,
                bloodType: bloodType.isEmpty ? "—" : bloodType,
                height: height,
                weight: weight,
                tension: tension.isEmpty ? "—" : tension,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Sections d'information
          SliverList(
            delegate: SliverChildListDelegate([
              _buildInfoTile(
                context,
                icon: Icons.warning_amber_rounded,
                title: "Allergies",
                value: allergies.isEmpty ? "Aucune" : allergies.join(" • "),
              ),
              _buildInfoTile(
                context,
                icon: Icons.medical_information_outlined,
                title: "Maladies chroniques",
                value: chronic.isEmpty ? "Aucune" : chronic.join(" • "),
              ),
              _buildInfoTile(
                context,
                icon: Icons.phone_in_talk_outlined,
                title: "Contact d'urgence",
                value: emergencyName.isNotEmpty
                    ? "$emergencyName${emergencyPhone.isNotEmpty ? ' ($emergencyPhone)' : ''}"
                    : "Non renseigné",
              ),
              _buildInfoTile(
                context,
                icon: Icons.location_on_outlined,
                title: "Adresse",
                value: address.isNotEmpty ? address : "Non renseignée",
              ),
              const SizedBox(height: 32),
            ]),
          ),

          // Bouton modifier
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: SafeArea(
                top: false,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text("Modifier le profil"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 1,
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalCard(
    BuildContext context, {
    required String bloodType,
    required String height,
    required String weight,
    required String tension,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informations médicales",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _rowInfo("Groupe sanguin", bloodType),
            const Divider(height: 28),
            _rowInfo("Taille", "$height cm"),
            const Divider(height: 28),
            _rowInfo("Poids", "$weight kg"),
            const Divider(height: 28),
            _rowInfo("Tension", tension),
          ],
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: Icon(icon, color: theme.colorScheme.primary, size: 28),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            value,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          minLeadingWidth: 40,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
        ),
      ),
    );
  }

  List<String> _safeList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String && value.isNotEmpty) return [value];
    return [];
  }
}
