// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:medilink_app/models/patient/patient_model.dart'; // ← ton modèle Patient
import 'package:medilink_app/pages/doctor_page/profil_patient_for_d.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    if (_searchQuery.isEmpty) return true;

    final first = (data['firstName'] ?? '').toString().toLowerCase();
    final last = (data['lastName'] ?? '').toString().toLowerCase();
    final phone = (data['phone'] ?? '').toString().toLowerCase();
    final email = (data['email'] ?? '').toString().toLowerCase();

    return first.contains(_searchQuery) ||
        last.contains(_searchQuery) ||
        phone.contains(_searchQuery) ||
        email.contains(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Vous devez être connecté")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Patients"),
        leading: Icon(Icons.person_2_outlined),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              controller: _searchController,
              leading: const Icon(Icons.search),
              hintText: "Rechercher par nom, prénom, téléphone ou email...",
              elevation: const MaterialStatePropertyAll(1),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('patients')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Erreur : ${snapshot.error}"));
                }

                final docs = snapshot.data?.docs ?? [];

                // Filtrer côté client (car on ne peut pas faire de recherche textuelle complexe directement dans Firestore sans index)
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _matchesSearch(data);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final patient = Patient.fromMap({...data, 'uid': doc.id});

                    return _buildPatientCard(context, patient);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, Patient patient) {
    final theme = Theme.of(context);
    final fullName = "${patient.firstName} ${patient.lastName}".trim();
    final displayName = fullName.isEmpty ? "Patient inconnu" : fullName;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : "?",
            style: TextStyle(
              fontSize: 24,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient.phone,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (patient.gender != null)
              Text(
                patient.gender == "Male" ? "Homme" : "Femme",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientProfilePage(patientUid: patient.uid),
            ),
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
            Icons.people_outline_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty
                ? "Aucun patient enregistré"
                : "Aucun patient ne correspond à \"$_searchQuery\"",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          if (_searchQuery.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text("Effacer la recherche"),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
    );
  }
}
