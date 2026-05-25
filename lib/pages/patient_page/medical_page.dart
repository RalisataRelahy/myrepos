// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medilink_app/models/medicale_model/prescription_model.dart';
import 'package:medilink_app/models/medicale_model/treatments_model.dart';

class PrescriptionPage extends StatefulWidget {
  const PrescriptionPage({super.key});

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  final _auth = FirebaseAuth.instance;

  // Cache pour les noms des médecins
  final Map<String, String> _doctorNamesCache = {};

  // Formatage manuel des dates en français

  String _formatFrenchDateShort(DateTime date) {
    const frenchMonthsShort = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    return '${date.day} ${frenchMonthsShort[date.month - 1]} ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Future<String?> getDoctorName(String doctorUid) async {
    if (_doctorNamesCache.containsKey(doctorUid)) {
      return _doctorNamesCache[doctorUid];
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorUid)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data()!;

      String getStringValue(dynamic value) {
        if (value == null) return "";
        if (value is String) return value.trim();
        if (value is List && value.isNotEmpty) {
          return value.first.toString().trim();
        }
        return value.toString();
      }

      final firstName = getStringValue(data['firstName']);
      final lastName = getStringValue(data['lastName']);

      if (firstName.isEmpty && lastName.isEmpty) {
        return null;
      }

      final doctorName = 'Dr. $firstName $lastName'.trim();
      _doctorNamesCache[doctorUid] = doctorName;

      return doctorName;
    } catch (e) {
      debugPrint('Erreur récupération nom médecin $doctorUid : $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Vous devez être connecté")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Ordonnances"),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prescriptions')
            .where('patientId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Erreur : ${snapshot.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text("Réessayer"),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final prescription = Prescription.fromMap({
                ...data,
                'id': doc.id,
              });

              return FutureBuilder<String?>(
                future: getDoctorName(prescription.doctorId),
                builder: (context, doctorSnapshot) {
                  final doctorName = doctorSnapshot.data ?? "Médecin";
                  return _buildPrescriptionCard(prescription, doctorName);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            "Aucune ordonnance pour le moment",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            "Vos ordonnances apparaîtront ici une fois\nqu'un médecin vous en aura prescrit une.",
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("Actualiser"),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(Prescription prescription, String doctorName) {
    Color statusColor;
    String statusText;

    switch (prescription.status) {
      case "active":
        statusColor = Colors.green;
        statusText = "Active";
        break;
      case "completed":
        statusColor = Colors.blue;
        statusText = "Terminée";
        break;
      case "cancelled":
        statusColor = Colors.red;
        statusText = "Annulée";
        break;
      default:
        statusColor = Colors.grey;
        statusText = prescription.status;
    }

    // Formatage des dates sans utiliser intl
    String formattedDate = "Date inconnue";
    String formattedCreatedAt = "Date inconnue";
    String formattedUpdatedAt = "Date inconnue";

    try {
      formattedDate = _formatFrenchDateShort(prescription.issuedAt.toDate());
      formattedCreatedAt = _formatDateTime(prescription.createdAt.toDate());
      formattedUpdatedAt = _formatDateTime(prescription.updatedAt.toDate());
    } catch (e) {
      debugPrint('Erreur formatage date: $e');
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.15),
          radius: 28,
          child: Icon(Icons.receipt_long_rounded, color: statusColor, size: 28),
        ),
        title: Text(
          "Ordonnance du $formattedDate",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Par $doctorName",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          const Divider(),

          if (prescription.diagnosis?.isNotEmpty ?? false) ...[
            _detailRow(
              icon: Icons.medical_information_outlined,
              label: "Diagnostic",
              value: prescription.diagnosis!,
            ),
            const SizedBox(height: 12),
          ],

          if (prescription.notePrescription?.isNotEmpty ?? false) ...[
            _detailRow(
              icon: Icons.note_alt_outlined,
              label: "Note du médecin",
              value: prescription.notePrescription!,
            ),
            const SizedBox(height: 16),
          ],

          if (prescription.treatments.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                "Médicaments prescrits",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            ...prescription.treatments.map(
              (treatment) => _buildTreatmentItem(treatment),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                "Aucun médicament listé dans cette ordonnance",
                style: TextStyle(color: Colors.grey),
              ),
            ),

          const SizedBox(height: 12),
          const Divider(),

          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _smallInfo("Créée le", formattedCreatedAt),
                _smallInfo("Dernière mise à jour", formattedUpdatedAt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTreatmentItem(Treatment treatment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              treatment.medicationName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _pillInfo("Posologie", treatment.dosage),
                _pillInfo("Fréquence", treatment.frequency),
                if (treatment.durationInDays != 0)
                  _pillInfo("Durée", "${treatment.durationInDays} jours"),
              ],
            ),
            if (treatment.instructions?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(
                "Instructions : ${treatment.instructions}",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pillInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _smallInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
