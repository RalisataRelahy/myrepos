// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medilink_app/pages/doctor_page/patient_list_page.dart';

class DoctorSelfProfile extends StatefulWidget {
  const DoctorSelfProfile({super.key});

  @override
  State<DoctorSelfProfile> createState() => _DoctorSelfProfileState();
}

class _DoctorSelfProfileState extends State<DoctorSelfProfile> {
  bool _isLoading = true;
  Map<String, dynamic>? _doctorData;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _doctorData = doc.data();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur chargement profil : $e")),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  String _format(dynamic value) {
    if (value == null) return "Non renseigné";
    if (value is List) return value.join(" • ");
    if (value is String && value.trim().isEmpty) return "Non renseigné";
    return value.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_doctorData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mon profil")),
        body: const Center(
          child: Text("Impossible de charger vos informations"),
        ),
      );
    }

    final data = _doctorData!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        leading: Icon(Icons.person_2_sharp),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: "Modifier le profil",
            onPressed: () {
              // Navigator.push(context, MaterialPageRoute(builder: (_) => EditDoctorProfile()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDoctorData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, data)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatsCards(context, data),
                  const SizedBox(height: 24),

                  _sectionTitle("Informations professionnelles"),
                  const SizedBox(height: 8),
                  _infoCard([
                    _infoRow(
                      Icons.school,
                      "Diplôme",
                      _format(data['diplomaLevel']),
                    ),
                    _infoRow(
                      Icons.language,
                      "Langues",
                      _format(data['languages']),
                    ),
                    _infoRow(
                      Icons.badge,
                      "N° licence",
                      _format(data['licenseNumber']),
                    ),
                    _infoRow(
                      Icons.location_on,
                      "Cabinet",
                      _format(data['address']),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  _sectionTitle("Compte & Sécurité"),
                  const SizedBox(height: 8),
                  _infoCard([
                    _infoRow(
                      Icons.verified_user,
                      "Statut compte",
                      _format(data['accountStatus']),
                    ),
                    _infoRow(Icons.email, "Email", _format(data['email'])),
                    _infoRow(Icons.phone, "Téléphone", _format(data['phone'])),
                  ]),

                  const SizedBox(height: 32),

                  // Actions rapides
                  _actionButton(
                    icon: Icons.calendar_month,
                    label: "Gérer mes disponibilités",
                    onPressed: () {
                      // → page agenda / disponibilités
                    },
                  ),
                  const SizedBox(height: 12),
                  _actionButton(
                    icon: Icons.people,
                    label: "Voir mes patients",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientListScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> data) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.08),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
            child: Icon(
                    Icons.medical_services_rounded,
                    size: 60,
                    color: theme.colorScheme.primary,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            "Dr. ${_format(data['firstName'])} ${_format(data['lastName'])}",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _format(data['speciality']),
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          if (_format(data['clinicName']) != "Non renseigné") ...[
            const SizedBox(height: 6),
            Text(
              _format(data['clinicName']),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, Map<String, dynamic> data) {
    final items = [
      _StatItem(
        Icons.people_alt,
        _format(data['patientsCount'] ?? "0"),
        "Patients suivis",
      ),
      _StatItem(
        Icons.calendar_month,
        _format(data['consultationsThisMonth'] ?? "0"),
        "Consultations ce mois",
      ),
      _StatItem(
        Icons.trending_up,
        "${_format(data['rating'] ?? "—")} ★",
        "Note moyenne",
      ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: items.map((item) => _smallStatCard(context, item)).toList(),
    );
  }

  Widget _smallStatCard(BuildContext context, _StatItem item) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 28, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              item.value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              item.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      subtitle: Text(value),
      dense: true,
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String value;
  final String label;

  _StatItem(this.icon, this.value, this.label);
}
