// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medilink_app/models/medicale_model/prescription_model.dart';

class PrescriptionDetailPage extends StatelessWidget {
  final String prescriptionId;

  const PrescriptionDetailPage({super.key, required this.prescriptionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de l'ordonnance"),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('prescriptions')
            .doc(prescriptionId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Ordonnance non trouvée"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final prescription = Prescription.fromMap({
            ...data,
            'id': prescriptionId,
          });

          return _buildPrescriptionView(context, prescription);
        },
      ),
    );
  }

  Widget _buildPrescriptionView(BuildContext context, Prescription p) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat("dd MMMM yyyy", "fr_FR");
    final fullDateFormat = DateFormat("dd/MM/yyyy à HH:mm", "fr_FR");

    Color statusColor;
    String statusText;

    switch (p.status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green.shade700;
        statusText = "Active";
        break;
      case 'completed':
        statusColor = Colors.blue.shade700;
        statusText = "Terminée";
        break;
      case 'cancelled':
        statusColor = Colors.red.shade700;
        statusText = "Annulée";
        break;
      default:
        statusColor = Colors.grey.shade700;
        statusText = p.status;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête principal + statut
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ordonnance du ${dateFormat.format(p.issuedAt.toDate())}",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Prescripteur : Dr. (ID ${p.doctorId.substring(0, 8)}…)",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Diagnostic + Note
                  if (p.diagnosis?.isNotEmpty ?? false) ...[
                    _infoRow(
                      icon: Icons.medical_information_outlined,
                      label: "Diagnostic",
                      value: p.diagnosis!,
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (p.notePrescription?.isNotEmpty ?? false) ...[
                    _infoRow(
                      icon: Icons.note_alt_outlined,
                      label: "Note du médecin",
                      value: p.notePrescription!,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Dates
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _smallDateInfo(
                        "Émise le",
                        fullDateFormat.format(p.issuedAt.toDate()),
                      ),
                      _smallDateInfo(
                        "Créée le",
                        fullDateFormat.format(p.createdAt.toDate()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Liste des traitements
          Text(
            "Médicaments prescrits",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          if (p.treatments.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    "Aucun médicament listé dans cette ordonnance",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ),
            )
          else
            ...p.treatments.asMap().entries.map((entry) {
              final index = entry.key;
              final t = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.15),
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.medicationName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        children: [
                          _pillDetail("Posologie", t.dosage),
                          _pillDetail("Fréquence", t.frequency),
                          _pillDetail("Durée", "${t.durationInDays} jours"),
                        ],
                      ),

                      if (t.instructions?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 12),
                        Text(
                          "Instructions :",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.instructions!,
                          style: const TextStyle(height: 1.45),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 40),

          // Mention légale / rappel
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Respectez scrupuleusement les posologies et durées prescrites.\n"
                "En cas d'effets indésirables ou de doute, contactez immédiatement votre médecin ou pharmacien.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.grey.shade700),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pillDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ],
    );
  }

  Widget _smallDateInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
