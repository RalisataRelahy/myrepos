import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:medilink_app/pages/doctor_page/add_rapel.dart';

class PatientProfilePage extends StatelessWidget {
  final String patientUid;

  const PatientProfilePage({super.key, required this.patientUid});

  Future<void> _openUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'ouvrir le lien")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil du patient"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert),
            tooltip: "Ajouter un rappel",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddAppointmentReminderPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('patients')
            .doc(patientUid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Patient introuvable"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Calcul de l'âge
          String age = "Âge non renseigné";
          if (data['dateOfBirth'] is Timestamp) {
            final dob = (data['dateOfBirth'] as Timestamp).toDate();
            final now = DateTime.now();
            int years = now.year - dob.year;
            if (now.month < dob.month ||
                (now.month == dob.month && now.day < dob.day)) {
              years--;
            }
            age = "$years ans";
          }

          final String fullName =
              "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
          final String displayName = fullName.isEmpty
              ? "Patient inconnu"
              : fullName;

          final List<String> allergies =
              (data['allergies'] as List<dynamic>?)?.cast<String>() ?? [];
          final List<String> chronic =
              (data['chronicDiseases'] as List<dynamic>?)?.cast<String>() ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Photo + Nom + Âge
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : "?",
                    style: const TextStyle(fontSize: 48, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  age,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 4),
                Text(
                  data['gender'] == "Male" ? "Homme" : "Femme",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 32),

                // Carte médicale
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.blue.shade700,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _rowInfo("Groupe sanguin", data['bloodType'] ?? "—"),
                        const Divider(color: Colors.white30, height: 24),
                        _rowInfo(
                          "Taille",
                          "${data['height']?.toString() ?? "—"} cm",
                        ),
                        const Divider(color: Colors.white30, height: 24),
                        _rowInfo(
                          "Poids",
                          "${data['weight']?.toString() ?? "—"} kg",
                        ),
                        const Divider(color: Colors.white30, height: 24),
                        _rowInfo("Tension", data['tension']?.toString() ?? "—"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Autres informations
                _infoSection(
                  title: "Informations médicales",
                  items: [
                    _infoItem(
                      Icons.warning_amber_rounded,
                      "Allergies",
                      allergies.isEmpty ? "Aucune" : allergies.join(", "),
                    ),
                    _infoItem(
                      Icons.local_hospital_outlined,
                      "Maladies chroniques",
                      chronic.isEmpty ? "Aucune" : chronic.join(", "),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _infoSection(
                  title: "Contact d'urgence",
                  items: [
                    _infoItem(
                      Icons.person,
                      "Nom",
                      data['emergencyContactName'] ?? "Non renseigné",
                    ),
                    _infoItem(
                      Icons.phone,
                      "Téléphone",
                      data['emergencyContactPhone'] ?? "Non renseigné",
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _infoSection(
                  title: "Autres",
                  items: [
                    _infoItem(
                      Icons.home,
                      "Adresse",
                      data['address'] ?? "Non renseignée",
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Bouton envoyer ordonnance (exemple)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.medical_information),
                    label: const Text("Envoyer une ordonnance"),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      // Logique pour envoyer ordonnance
                      // Exemple:
                      _openUrl(
                        "https://projet-l3-web-fw4r.vercel.app",
                        context,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Fonctionnalité en cours de développement",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _infoSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(label),
      subtitle: Text(value),
      dense: true,
    );
  }
}
