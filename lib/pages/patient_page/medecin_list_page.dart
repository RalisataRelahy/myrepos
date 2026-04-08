import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medilink_app/pages/patient_page/profil_doctor_for_p.dart';

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  String _search = '';

  // ── Safe helpers ──────────────────────────────────────────────────────────

  String _str(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is List && v.isNotEmpty) return v.first.toString();
    return v.toString();
  }

  double _dbl(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    if (v is List && v.isNotEmpty) {
      final f = v.first;
      if (f is double) return f;
      if (f is int) return f.toDouble();
      if (f is String) return double.tryParse(f) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final bool isSmall = w < 360;
    final bool isTablet = w >= 600;
    final double hPad = isSmall
        ? 10
        : isTablet
        ? 28
        : 14;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: _buildAppBar(isSmall),
      body: Column(
        children: [
          _buildSearchBar(hPad, isSmall),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
                  );
                }

                if (snapshot.hasError) {
                  return _buildError(snapshot.error.toString());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmpty();
                }

                // Filter by search
                final docs = snapshot.data!.docs.where((doc) {
                  if (_search.isEmpty) return true;
                  final data = doc.data() as Map<String, dynamic>;
                  final name =
                      "${_str(data['firstName'])} ${_str(data['lastName'])}"
                          .toLowerCase();
                  final spec = _str(data['speciality']).toLowerCase();
                  final q = _search.toLowerCase();
                  return name.contains(q) || spec.contains(q);
                }).toList();

                if (docs.isEmpty) {
                  return _buildEmpty(message: 'Aucun résultat pour "$_search"');
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: hPad,
                    vertical: isSmall ? 10 : 14,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final firstName = _str(data['firstName']);
                    final lastName = _str(data['lastName']);
                    final speciality = _str(data['speciality']);
                    final rating = _dbl(data['rating']);
                    final clinic = _str(data['clinicName']);
                    final experience = _str(data['yearsOfExperience']);

                    return _DoctorCard(
                      id: doc.id,
                      firstName: firstName,
                      lastName: lastName,
                      speciality: speciality,
                      rating: rating,
                      clinic: clinic,
                      experience: experience,
                      isSmall: isSmall,
                      isTablet: isTablet,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isSmall) {
    return AppBar(
      backgroundColor: const Color(0xFF1A73E8),
      elevation: 0,
      centerTitle: true,
      title: Text(
        "Médecins",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isSmall ? 16 : 18,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(6),
        child: Container(
          height: 6,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A73E8), Color(0xFF0D9488)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(double hPad, bool isSmall) {
    return Container(
      color: const Color(0xFF1A73E8),
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A1A73E8),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: (v) => setState(() => _search = v),
          style: TextStyle(fontSize: isSmall ? 13 : 15),
          decoration: InputDecoration(
            hintText: "Rechercher un médecin ou une spécialité…",
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: isSmall ? 12 : 14,
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF1A73E8)),
            suffixIcon: _search.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                    onPressed: () => setState(() => _search = ''),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              vertical: isSmall ? 12 : 14,
              horizontal: 4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            "Erreur de chargement",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: const TextStyle(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty({String message = "Aucun médecin disponible"}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 56,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Doctor Card
// ─────────────────────────────────────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  final String id;
  final String firstName;
  final String lastName;
  final String speciality;
  final double rating;
  final String clinic;
  final String experience;
  final bool isSmall;
  final bool isTablet;

  const _DoctorCard({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.speciality,
    required this.rating,
    required this.clinic,
    required this.experience,
    required this.isSmall,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final double avatarRadius = isSmall
        ? 24
        : isTablet
        ? 34
        : 28;
    final double nameFontSize = isSmall
        ? 13
        : isTablet
        ? 17
        : 15;
    final double subFontSize = isSmall
        ? 11
        : isTablet
        ? 14
        : 12;
    final double chipFontSize = isSmall ? 10 : 11;

    final String fullName = firstName.isEmpty && lastName.isEmpty
        ? "Médecin"
        : "Dr $firstName $lastName";

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DoctorProfilePage(doctorId: id)),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: isSmall ? 10 : 14),
        padding: EdgeInsets.all(isSmall ? 10 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D1A73E8),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Avatar ──────────────────────────────────────────────
            Container(
              width: avatarRadius * 2,
              height: avatarRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF0D9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.person,
                size: avatarRadius,
                color: Colors.white,
              ),
            ),

            SizedBox(width: isSmall ? 10 : 14),

            // ── Info ─────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    fullName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: nameFontSize,
                      color: const Color(0xFF1A1A2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: isSmall ? 2 : 4),

                  // Speciality chip
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 6 : 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      speciality.isEmpty ? "Généraliste" : speciality,
                      style: TextStyle(
                        color: const Color(0xFF1A73E8),
                        fontSize: chipFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(height: isSmall ? 4 : 6),

                  // Rating + clinic + experience
                  Wrap(
                    spacing: isSmall ? 8 : 12,
                    runSpacing: 2,
                    children: [
                      _InfoChip(
                        icon: Icons.star_rounded,
                        iconColor: Colors.orange,
                        text: rating.toStringAsFixed(1),
                        fontSize: subFontSize,
                      ),
                      if (experience.isNotEmpty)
                        _InfoChip(
                          icon: Icons.work_outline,
                          iconColor: const Color(0xFF0D9488),
                          text: "$experience ans",
                          fontSize: subFontSize,
                        ),
                      if (clinic.isNotEmpty)
                        _InfoChip(
                          icon: Icons.local_hospital_outlined,
                          iconColor: const Color(0xFF1A73E8),
                          text: clinic,
                          fontSize: subFontSize,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Arrow ────────────────────────────────────────────────
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF1A73E8),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final double fontSize;

  const _InfoChip({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: fontSize + 2, color: iconColor),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(fontSize: fontSize, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
