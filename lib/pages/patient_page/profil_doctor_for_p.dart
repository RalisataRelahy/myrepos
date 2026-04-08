// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorProfilePage extends StatefulWidget {
  final String doctorId;

  const DoctorProfilePage({super.key, required this.doctorId});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage>
    with SingleTickerProviderStateMixin {
  // ── Design tokens ───────────────────────────────────────────────────────────
  static const _primaryMale = Color(0xFF1A73E8);
  static const _primaryFemale = Color(0xFFD44F8E);

  static const _gradientMale = [Color(0xFF1A73E8), Color(0xFF0D47A1)];
  static const _gradientFemale = [Color(0xFFD44F8E), Color(0xFF7B1FA2)];

  static const _surface = Color(0xFFF8FAFC);
  static const _cardBg = Colors.white;
  static const _textDark = Color(0xFF1C2B4B);
  static const _textMuted = Color(0xFF8A94A6);
  static const _divider = Color(0xFFEEF2F7);

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Safe value helpers ──────────────────────────────────────────────────────
  String _str(dynamic v) {
    if (v == null) return "";
    if (v is String) return v.trim();
    if (v is List && v.isNotEmpty) return v.first.toString().trim();
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

  int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is List && v.isNotEmpty) {
      final f = v.first;
      if (f is int) return f;
      if (f is String) return int.tryParse(f) ?? 0;
    }
    return 0;
  }

  bool _bool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    if (v is List && v.isNotEmpty) {
      final f = v.first;
      if (f is bool) return f;
      if (f is String) return f.toLowerCase() == 'true';
    }
    return false;
  }

  String _formatWorkingHours(Map<String, dynamic> wh) {
    if (wh.isEmpty) return "Non spécifié";
    const weekdays = {
      'monday': 'Lun',
      'tuesday': 'Mar',
      'wednesday': 'Mer',
      'thursday': 'Jeu',
      'friday': 'Ven',
      'saturday': 'Sam',
      'sunday': 'Dim',
    };
    final buf = StringBuffer();
    weekdays.forEach((key, name) {
      if (wh.containsKey(key)) {
        final h = wh[key];
        if (h != null && h['open'] != null && h['close'] != null) {
          buf.write("$name: ${h['open']}–${h['close']}   ");
        }
      }
    });
    return buf.toString().trim();
  }

  // ── Build helpers ───────────────────────────────────────────────────────────

  Color _primaryColor(bool isFemale) =>
      isFemale ? _primaryFemale : _primaryMale;

  List<Color> _gradientColors(bool isFemale) =>
      isFemale ? _gradientFemale : _gradientMale;

  Widget _statChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        Text(label, style: const TextStyle(color: _textMuted, fontSize: 11)),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 17),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                    decorationThickness: 1,
                    color: _textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: _divider, height: 1),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  void _takeAppointment() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Prendre rendez-vous"),
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

  void _sendMessage() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Envoyer un message"),
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

  // ── Main build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isTablet = screen.width >= 600;
    final hPad = isTablet ? screen.width * 0.1 : 16.0;
    // Expanded header height scales with screen size
    final expandedHeight = isTablet ? 340.0 : 300.0;
    final avatarRadius = isTablet ? 72.0 : 58.0;

    return Scaffold(
      backgroundColor: _surface,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .doc(widget.doctorId)
            .snapshots(),
        builder: (context, snapshot) {
          // ── Loading ──────────────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryMale),
            );
          }

          // ── Error ────────────────────────────────────────────────────────
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Erreur: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Retour"),
                  ),
                ],
              ),
            );
          }

          // ── Not found ────────────────────────────────────────────────────
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Médecin non trouvé"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Extract data
          final firstName = _str(data['firstName']);
          final lastName = _str(data['lastName']);
          final email = _str(data['email']);
          final phone = _str(data['phone']);
          final speciality = _str(data['speciality']);
          final address = _str(data['address']);
          final bio = _str(data['bio']);
          final rating = _dbl(data['rating']);
          final experience = _int(
            data['yearsOfExperience'] ?? data['experience'],
          );
          final fee = _dbl(data['consultationFee']);
          final isAvailable = _bool(data['isAvailable']);
          final profileImageUrl = _str(data['profileImageUrl']);
          final gender = _str(data['gender']).toLowerCase();
          final totalReviews = _int(data['totalReviews']);
          final license = _str(data['licenseNumber']);
          final diplome = _str(data['diplomeLevel']);
          final languages = _str(data['languages']);
          final clinicName = _str(data['clinicName']);
          final workingHours =
              data['workingHours'] as Map<String, dynamic>? ?? {};

          final isFemale = gender == 'female';
          final primary = _primaryColor(isFemale);
          final gradColors = _gradientColors(isFemale);

          final fullName = "$firstName $lastName".trim();
          final displayName = fullName.isEmpty ? "Docteur" : "Dr. $fullName";

          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: CustomScrollView(
                slivers: [
                  // ── SliverAppBar ────────────────────────────────────────
                  SliverAppBar(
                    expandedHeight: expandedHeight,
                    pinned: true,
                    backgroundColor: gradColors.first,
                    elevation: 0,
                    leading: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Material(
                        color: Colors.white.withOpacity(0.2),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Material(
                          color: Colors.white.withOpacity(0.2),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.share_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // ── Gradient background ──────────────────────
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: gradColors,
                              ),
                            ),
                          ),
                          // ── Decorative circles ───────────────────────
                          Positioned(
                            top: -40,
                            right: -40,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.07),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 60,
                            left: -30,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                          ),
                          // ── Female extra: soft wave accent ───────────
                          if (isFemale)
                            Positioned(
                              top: 30,
                              left: 20,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(
                                    0xFFFF80AB,
                                  ).withOpacity(0.18),
                                ),
                              ),
                            ),
                          if (isFemale)
                            Positioned(
                              bottom: 90,
                              right: 30,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(
                                    0xFFCE93D8,
                                  ).withOpacity(0.22),
                                ),
                              ),
                            ),
                          // ── Avatar ───────────────────────────────────
                          Positioned(
                            bottom: 30,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Hero(
                                tag: 'doctor_${widget.doctorId}',
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: gradColors.last.withOpacity(0.4),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: avatarRadius,
                                    backgroundImage: profileImageUrl.isNotEmpty
                                        ? NetworkImage(profileImageUrl)
                                        : null,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.3,
                                    ),
                                    child: profileImageUrl.isEmpty
                                        ? Icon(
                                            isFemale
                                                ? Icons.face_3
                                                : Icons.person,
                                            size: avatarRadius * 0.8,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // ── Availability badge on avatar ─────────────
                          if (isAvailable)
                            Positioned(
                              bottom: 28,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Transform.translate(
                                  offset: Offset(avatarRadius * 0.65, 0),
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF34A853),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ── Content ────────────────────────────────────────────
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ── Name / specialty / meta ────────────────────
                        Center(
                          child: Column(
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  color: _textDark,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  speciality.isEmpty
                                      ? "Médecin généraliste"
                                      : speciality,
                                  style: TextStyle(
                                    color: primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Rating + availability
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: _textDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "($totalReviews avis)",
                                    style: const TextStyle(
                                      color: _textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (isAvailable) ...[
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF34A853,
                                        ).withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: Color(0xFF34A853),
                                            size: 8,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "Disponible",
                                            style: TextStyle(
                                              color: Color(0xFF34A853),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Stats row ─────────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _cardBg,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _statChip(
                                icon: Icons.workspace_premium_outlined,
                                value: "${experience}ans",
                                label: "Expérience",
                                color: primary,
                              ),
                              _vDivider(),
                              _statChip(
                                icon: Icons.payments_outlined,
                                value: "${fee.toStringAsFixed(0)}Ar",
                                label: "Consultation",
                                color: primary,
                              ),
                              _vDivider(),
                              _statChip(
                                icon: Icons.star_outline_rounded,
                                value: rating.toStringAsFixed(1),
                                label: "Note",
                                color: Colors.amber,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Responsive layout: side-by-side on tablet ──
                        if (isTablet)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column
                              Expanded(
                                child: Column(
                                  children: [
                                    _sectionCard(
                                      title: "Contact",
                                      icon: Icons.contact_phone_outlined,
                                      color: primary,
                                      children: [
                                        _infoRow(
                                          icon: Icons.mail_outline_rounded,
                                          label: "Email",
                                          value: email,
                                          color: primary,
                                        ),
                                        _infoRow(
                                          icon: Icons.phone_outlined,
                                          label: "Téléphone",
                                          value: phone,
                                          color: primary,
                                        ),
                                        _infoRow(
                                          icon: Icons.location_on_outlined,
                                          label: "Adresse",
                                          value: address,
                                          color: primary,
                                        ),
                                        _infoRow(
                                          icon: Icons.business_outlined,
                                          label: "Clinique",
                                          value: clinicName,
                                          color: primary,
                                        ),
                                      ],
                                    ),
                                    if (bio.isNotEmpty)
                                      _sectionCard(
                                        title: "Biographie",
                                        icon: Icons.notes_rounded,
                                        color: primary,
                                        children: [
                                          Text(
                                            bio,
                                            style: const TextStyle(
                                              color: _textDark,
                                              fontSize: 14,
                                              height: 1.7,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Right column
                              Expanded(
                                child: Column(
                                  children: [
                                    _sectionCard(
                                      title: "Info professionnelles",
                                      icon: Icons.medical_services_outlined,
                                      color: primary,
                                      children: [
                                        _infoRow(
                                          icon: Icons.verified_outlined,
                                          label: "Licence",
                                          value: license,
                                          color: primary,
                                        ),
                                        _infoRow(
                                          icon: Icons.school_outlined,
                                          label: "Diplôme",
                                          value: diplome,
                                          color: primary,
                                        ),
                                        _infoRow(
                                          icon: Icons.language_outlined,
                                          label: "Langues",
                                          value: languages,
                                          color: primary,
                                        ),
                                        if (workingHours.isNotEmpty)
                                          _infoRow(
                                            icon: Icons.access_time_rounded,
                                            label: "Horaires",
                                            value: _formatWorkingHours(
                                              workingHours,
                                            ),
                                            color: primary,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else ...[
                          // ── Mobile: single column ────────────────────
                          _sectionCard(
                            title: "Informations de contact",
                            icon: Icons.contact_phone_outlined,
                            color: primary,
                            children: [
                              _infoRow(
                                icon: Icons.mail_outline_rounded,
                                label: "Email",
                                value: email,
                                color: primary,
                              ),
                              _infoRow(
                                icon: Icons.phone_outlined,
                                label: "Téléphone",
                                value: phone,
                                color: primary,
                              ),
                              _infoRow(
                                icon: Icons.location_on_outlined,
                                label: "Adresse",
                                value: address,
                                color: primary,
                              ),
                              _infoRow(
                                icon: Icons.business_outlined,
                                label: "Clinique",
                                value: clinicName,
                                color: primary,
                              ),
                            ],
                          ),
                          _sectionCard(
                            title: "Info professionnelles",
                            icon: Icons.medical_services_outlined,
                            color: primary,
                            children: [
                              _infoRow(
                                icon: Icons.verified_outlined,
                                label: "Licence",
                                value: license,
                                color: primary,
                              ),
                              _infoRow(
                                icon: Icons.school_outlined,
                                label: "Diplôme",
                                value: diplome,
                                color: primary,
                              ),
                              _infoRow(
                                icon: Icons.language_outlined,
                                label: "Langues",
                                value: languages,
                                color: primary,
                              ),
                              if (workingHours.isNotEmpty)
                                _infoRow(
                                  icon: Icons.access_time_rounded,
                                  label: "Horaires",
                                  value: _formatWorkingHours(workingHours),
                                  color: primary,
                                ),
                            ],
                          ),
                          if (bio.isNotEmpty)
                            _sectionCard(
                              title: "Biographie",
                              icon: Icons.notes_rounded,
                              color: primary,
                              children: [
                                Text(
                                  bio,
                                  style: const TextStyle(
                                    color: _textDark,
                                    fontSize: 14,
                                    height: 1.7,
                                  ),
                                ),
                              ],
                            ),
                        ],

                        const SizedBox(height: 8),

                        // ── Action buttons ───────────────────────────
                        if (isTablet)
                          Row(
                            children: [
                              Expanded(
                                child: _actionButton(
                                  label: "Prendre rendez-vous",
                                  icon: Icons.calendar_month_rounded,
                                  backgroundColor: primary,
                                  foreground: Colors.white,
                                  onTap: _takeAppointment,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _actionButton(
                                  label: "Envoyer un message",
                                  icon: Icons.chat_bubble_outline_rounded,
                                  backgroundColor: primary.withOpacity(0.10),
                                  foreground: primary,
                                  onTap: _sendMessage,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _actionButton(
                                label: "Prendre rendez-vous",
                                icon: Icons.calendar_month_rounded,
                                backgroundColor: primary,
                                foreground: Colors.white,
                                onTap: _takeAppointment,
                              ),
                            ],
                          ),

                        const SizedBox(height: 16),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _vDivider() => Container(width: 1, height: 50, color: _divider);

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: foreground, size: 18),
        label: Text(
          label,
          style: TextStyle(
            color: foreground,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
