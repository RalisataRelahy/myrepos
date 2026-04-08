// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorProfile extends StatelessWidget {
  final String doctorId;

  const DoctorProfile({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('doctors')
            .doc(doctorId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Scaffold(
              appBar: AppBar(title: const Text("Profil du médecin")),
              body: const Center(child: Text("Médecin introuvable")),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return _DoctorProfileContent(data: data, doctorId: doctorId);
        },
      ),
    );
  }
}

class _DoctorProfileContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final String doctorId;

  const _DoctorProfileContent({required this.data, required this.doctorId});

  String _format(dynamic value) {
    if (value == null) return "Non renseigné";
    if (value is List) return value.join(" • ");
    if (value is String && value.trim().isEmpty) return "Non renseigné";
    return value.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 700;
    final avatarSize = isLargeScreen ? 90.0 : 65.0;

    return CustomScrollView(
      slivers: [
        // AppBar extensible avec photo + nom
        SliverAppBar(
          expandedHeight: isLargeScreen ? 340 : 260,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.12),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'doctor-$doctorId',
                      child: CircleAvatar(
                        radius: avatarSize,
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.15,
                        ),
                        backgroundImage:
                            _format(data['profileImageUrl']).startsWith('http')
                            ? NetworkImage(data['profileImageUrl'])
                            : null,
                        child:
                            _format(data['profileImageUrl']).startsWith('http')
                            ? null
                            : Icon(
                                Icons.medical_services_rounded,
                                size: avatarSize * 0.7,
                                color: theme.colorScheme.primary,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Dr. ${_format(data['firstName'])} ${_format(data['lastName'])}",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _format(data['speciality']),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (_format(data['clinicName']) != "Non renseigné") ...[
                      const SizedBox(height: 6),
                      Text(
                        _format(data['clinicName']),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 48 : 16,
            vertical: 16,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Statistiques
              _buildStats(context, isLargeScreen),

              const SizedBox(height: 32),

              // À propos
              _sectionTitle(context, "À propos"),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _format(data['bio']) != "Non renseigné"
                        ? _format(data['bio'])
                        : "Aucune description disponible pour le moment.",
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Infos clés
              _sectionTitle(context, "Informations professionnelles"),
              const SizedBox(height: 12),
              _infoCard(context, [
                _infoTile("Diplôme", _format(data['diplomaLevel']), context),
                _infoTile("Langues", _format(data['languages']), context),
                _infoTile(
                  "N° licence",
                  _format(data['licenseNumber']),
                  context,
                ),
                _infoTile("Cabinet", _format(data['address']), context),
                _infoTile("Statut", _format(data['accountStatus']), context),
              ]),

              const SizedBox(height: 32),

              // Contact
              _sectionTitle(context, "Contact"),
              const SizedBox(height: 12),
              _infoCard(context, [
                _infoTile("Téléphone", _format(data['phone']), context),
                _infoTile("Email", _format(data['email']), context),
              ]),

              const SizedBox(height: 80),
            ]),
          ),
        ),

        // Bouton fixe en bas
        SliverFillRemaining(
          hasScrollBody: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton.icon(
                icon: const Icon(Icons.calendar_today_rounded),
                label: const Text("Prendre rendez-vous"),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Votre rendez-vous a été confirmé !"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, bool isLarge) {
    final items = [
      _Stat(
        Icons.work_outline,
        "${_format(data['yearsOfExperience'])} ans",
        "Expérience",
      ),
      _Stat(Icons.star_outline, _format(data['rating']), "Note"),
      _Stat(
        Icons.attach_money,
        "${_format(data['consultationFee'])} Ar",
        "Consultation",
      ),
    ];

    if (isLarge) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((s) => _statCard(context, s)).toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map(
              (s) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _statCard(context, s),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _statCard(BuildContext context, _Stat stat) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(stat.icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              stat.value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              stat.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _infoCard(BuildContext context, List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }

  Widget _infoTile(String label, String value, context) {
    return ListTile(
      leading: Icon(
        Icons.info_outline,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(value),
      dense: true,
    );
  }
}

class _Stat {
  final IconData icon;
  final String value;
  final String label;

  _Stat(this.icon, this.value, this.label);
}
