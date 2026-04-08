// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:medilink_app/pages/doctor_page/appointement.dart';
import 'package:medilink_app/pages/doctor_page/notif.dart';
import 'package:medilink_app/pages/doctor_page/profil_patient_for_d.dart';
import 'package:medilink_app/pages/public/logout.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  // ── Helpers ──────────────────────────────────────────────────────────────

  String _safe(dynamic v) {
    if (v == null) return '';
    if (v is String) return v.trim();
    if (v is List && v.isNotEmpty) return v.first.toString().trim();
    return v.toString().trim();
  }

  String _formatRating(dynamic rating) {
    if (rating == null) return '—';
    final val = double.tryParse(rating.toString()) ?? 0.0;
    return val.toStringAsFixed(1);
  }

  String _calculateAge(dynamic dob) {
    if (dob == null || dob is! Timestamp) return '—';
    final birth = dob.toDate();
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return '$age';
  }

  Timestamp get _todayStart => Timestamp.fromDate(
    DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0),
  );

  Timestamp get _tomorrowStart => Timestamp.fromDate(
    DateTime.now()
        .add(const Duration(days: 1))
        .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0),
  );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Non connecté')));
    }

    final Size screen = MediaQuery.of(context).size;
    final double w = screen.width;

    final bool isSmall = w < 360;
    final bool isTablet = w >= 600;

    final double hPad = isSmall
        ? 12
        : isTablet
        ? 28
        : 16;
    final double sectionGap = isSmall
        ? 20
        : isTablet
        ? 32
        : 24;
    final int gridCols = isTablet ? 4 : 2;
    final double gridChildRatio = isTablet ? 1.1 : 1.0;

    return Scaffold(
      drawer: _buildDrawer(context, uid),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('doctors')
              .doc(uid)
              .snapshots(),
          builder: (context, doctorSnap) {
            if (doctorSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final doctorData =
                doctorSnap.data?.data() as Map<String, dynamic>? ?? {};

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ───────────────────────────────────────────
                  _buildHeader(context, doctorData, isSmall),

                  SizedBox(height: sectionGap),

                  // ── Stats grid ───────────────────────────────────────
                  _buildStatsGrid(
                    uid,
                    doctorData,
                    gridCols,
                    gridChildRatio,
                    isSmall,
                  ),

                  SizedBox(height: sectionGap),

                  // ── Today's appointments ─────────────────────────────
                  _sectionHeader(
                    title: "Rendez-vous du jour",
                    isSmall: isSmall,
                    onMore: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TodaysAppointmentsScreen(),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmall ? 8 : 12),
                  _buildTodayAppointments(uid, isSmall),

                  SizedBox(height: sectionGap),

                  // ── Recent patients ──────────────────────────────────
                  _sectionHeader(title: "Patients récents", isSmall: isSmall),
                  SizedBox(height: isSmall ? 8 : 12),
                  _buildRecentPatients(uid, isSmall),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    Map<String, dynamic> data,
    bool isSmall,
  ) {
    final name = '${_safe(data['firstName'])} ${_safe(data['lastName'])}'
        .trim();
    final specialty = _safe(data['speciality']);

    final double avatarRadius = isSmall ? 20 : 24;
    final double nameFontSize = isSmall ? 16 : 20;
    final double subFontSize = isSmall ? 12 : 14;
    final double notifIconSize = isSmall ? 24 : 28;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar + name
        Expanded(
          child: Row(
            children: [
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      Icons.person,
                      size: avatarRadius,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isSmall ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour,',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: subFontSize,
                      ),
                    ),
                    Text(
                      name.isEmpty ? 'Docteur' : 'Dr. $name',
                      style: TextStyle(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      specialty.isEmpty
                          ? 'Spécialité non renseignée'
                          : specialty,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: subFontSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Notification bell
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationPageDoc()),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_none, size: notifIconSize),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Stats grid ────────────────────────────────────────────────────────────

  Widget _buildStatsGrid(
    String uid,
    Map<String, dynamic> doctorData,
    int cols,
    double childRatio,
    bool isSmall,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: _todayStart)
          .where('date', isLessThan: _tomorrowStart)
          .snapshots(),
      builder: (context, todaySnap) {
        final todayCount = todaySnap.data?.size ?? 0;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('consultations')
              .where('doctorId', isEqualTo: uid)
              .snapshots(),
          builder: (context, consultSnap) {
            final patientsCount =
                consultSnap.data?.docs
                    .map((d) => d['patientId'].toString())
                    .toSet()
                    .length ??
                0;

            final cards = [
              _StatCardData(
                icon: Icons.people,
                color: Colors.blue,
                value: '$patientsCount',
                label: 'Patients suivis',
              ),
              _StatCardData(
                icon: Icons.calendar_month,
                color: Colors.green,
                value: '$todayCount',
                label: "RDV aujourd'hui",
              ),
              _StatCardData(
                icon: Icons.description,
                color: Colors.purple,
                value: '—',
                label: 'Ordonnances',
              ),
              _StatCardData(
                icon: Icons.star_rounded,
                color: Colors.orange,
                value: _formatRating(doctorData['rating']),
                label: 'Note moyenne',
              ),
            ];

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: isSmall ? 10 : 16,
                mainAxisSpacing: isSmall ? 10 : 16,
                childAspectRatio: childRatio,
              ),
              itemCount: cards.length,
              itemBuilder: (_, i) => _buildStatCard(cards[i], isSmall),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(_StatCardData d, bool isSmall) {
    final double iconContPad = isSmall ? 9 : 12;
    final double iconSize = isSmall ? 22 : 28;
    final double valueFontSize = isSmall ? 18 : 24;
    final double labelFontSize = isSmall ? 11 : 13;

    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(iconContPad),
            decoration: BoxDecoration(
              color: d.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(d.icon, color: d.color, size: iconSize),
          ),
          SizedBox(height: isSmall ? 8 : 12),
          Text(
            d.value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            d.label,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: labelFontSize),
          ),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────

  Widget _sectionHeader({
    required String title,
    required bool isSmall,
    VoidCallback? onMore,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isSmall ? 15 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onMore != null)
          TextButton(
            onPressed: onMore,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Voir tous',
              style: TextStyle(fontSize: isSmall ? 12 : 14),
            ),
          ),
      ],
    );
  }

  // ── Today's appointments ──────────────────────────────────────────────────

  Widget _buildTodayAppointments(String uid, bool isSmall) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: _todayStart)
          .where('date', isLessThan: _tomorrowStart)
          .orderBy('date')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final appts = snapshot.data?.docs ?? [];

        if (appts.isEmpty) {
          return _emptyState("Aucun rendez-vous prévu aujourd'hui");
        }

        return Column(
          children: appts.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final time = (data['date'] as Timestamp?)?.toDate();
            final timeStr = time != null
                ? DateFormat('HH:mm').format(time)
                : '—';

            return Card(
              margin: EdgeInsets.only(bottom: isSmall ? 8 : 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 10 : 16,
                  vertical: isSmall ? 4 : 6,
                ),
                leading: CircleAvatar(
                  radius: isSmall ? 18 : 22,
                  backgroundImage: data['patientImage'] != null
                      ? NetworkImage(data['patientImage'])
                      : null,
                  child: data['patientImage'] == null
                      ? Icon(Icons.person, size: isSmall ? 16 : 20)
                      : null,
                ),
                title: Text(
                  data['patientName'] ?? 'Patient inconnu',
                  style: TextStyle(
                    fontSize: isSmall ? 13 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '$timeStr • ${data['type'] ?? '—'}',
                  style: TextStyle(fontSize: isSmall ? 11 : 13),
                ),
                trailing: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: isSmall ? 11 : 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ── Recent patients ───────────────────────────────────────────────────────

  Widget _buildRecentPatients(String uid, bool isSmall) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('consultations')
          .where('doctorId', isEqualTo: uid)
          .orderBy('date', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final consultations = snapshot.data?.docs ?? [];

        if (consultations.isEmpty) {
          return _emptyState('Aucun patient récent');
        }

        return Column(
          children: consultations.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final patientId = data['patientId'];

            return FutureBuilder<DocumentSnapshot>(
              future: patientId != null
                  ? FirebaseFirestore.instance
                        .collection('patients')
                        .doc(patientId)
                        .get()
                  : null,
              builder: (context, patientSnap) {
                if (!patientSnap.hasData || !patientSnap.data!.exists) {
                  return _patientTile(
                    name: 'Patient inconnu',
                    subtitle: '',
                    isSmall: isSmall,
                  );
                }

                final pData = patientSnap.data!.data() as Map<String, dynamic>;
                final name =
                    '${pData['firstName'] ?? ''} ${pData['lastName'] ?? ''}'
                        .trim();
                final gender = pData['gender'] == 'Male' ? 'Homme' : 'Femme';
                final age = _calculateAge(pData['dateOfBirth']);

                return _patientTile(
                  name: name.isEmpty ? 'Patient' : name,
                  subtitle: '$gender • $age ans',
                  isSmall: isSmall,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PatientProfilePage(patientUid: patientId!),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _patientTile({
    required String name,
    required String subtitle,
    required bool isSmall,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: isSmall ? 6 : 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmall ? 10 : 16,
          vertical: isSmall ? 2 : 4,
        ),
        leading: CircleAvatar(
          radius: isSmall ? 18 : 22,
          backgroundColor: Colors.blue.shade50,
          child: Icon(
            Icons.person,
            size: isSmall ? 16 : 20,
            color: Colors.blue,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: isSmall ? 13 : 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle, style: TextStyle(fontSize: isSmall ? 11 : 13))
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: isSmall ? 13 : 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }

  // ── Drawer ────────────────────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context, String uid) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('doctors')
                .doc(uid)
                .get(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final firstName = _safe(data['firstName']);
              final lastName = _safe(data['lastName']);
              final email = _safe(data['email']);

              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                accountName: Text(
                  'Dr. $firstName $lastName',
                  overflow: TextOverflow.ellipsis,
                ),
                accountEmail: Text(email, overflow: TextOverflow.ellipsis),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: data['profileImageUrl'] != null
                      ? NetworkImage(data['profileImageUrl'])
                      : const AssetImage('assets/images/user.png')
                            as ImageProvider,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LogoutPage()),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card data model ──────────────────────────────────────────────────────

class _StatCardData {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatCardData({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
}
