import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medilink_app/pages/public/notification.dart';
import 'package:medilink_app/pages/patient_page/medecin_list_page.dart';
import 'package:medilink_app/widgets/ai_banner.dart';
import 'package:medilink_app/widgets/profil_doctor_for_p.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomePage
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final bool isSmall = w < 360;
    final bool isTablet = w >= 600;
    final double hPad = isSmall
        ? 12
        : isTablet
        ? 28
        : 20;
    final double gap = isSmall
        ? 16
        : isTablet
        ? 28
        : 22;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: gap * 0.6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderSection(isSmall: isSmall, isTablet: isTablet),
            SizedBox(height: gap),
            AIBanner(isSmall: isSmall, isTablet: isTablet, currentUser: user),
            SizedBox(height: gap),
            CategoriesSection(isSmall: isSmall, isTablet: isTablet),
            SizedBox(height: gap * 0.85),
            TopDoctorsSection(isSmall: isSmall, isTablet: isTablet),
            SizedBox(height: gap),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HeaderSection  — real-time via StreamBuilder
// ─────────────────────────────────────────────────────────────────────────────

class HeaderSection extends StatelessWidget {
  final bool isSmall;
  final bool isTablet;
  const HeaderSection({
    super.key,
    required this.isSmall,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final double avatarRadius = isSmall
        ? 19
        : isTablet
        ? 26
        : 22;
    final double nameFontSize = isSmall
        ? 15
        : isTablet
        ? 20
        : 18;
    final double greetingFontSize = isSmall ? 12 : 14;

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
                    child: Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(width: isSmall ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: greetingFontSize,
                      ),
                    ),
                    // ── Real-time name ──────────────────────────────
                    if (uid != null)
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("patients")
                            .doc(uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              height: nameFontSize + 4,
                              width: 80,
                              child: const LinearProgressIndicator(
                                minHeight: 2,
                              ),
                            );
                          }
                          final data =
                              snapshot.data?.data() as Map<String, dynamic>? ??
                              {};
                          final name =
                              "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}"
                                  .trim();
                          return Text(
                            name.isEmpty ? 'Utilisateur' : name,
                            style: TextStyle(
                              fontSize: nameFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      )
                    else
                      Text(
                        'Utilisateur',
                        style: TextStyle(
                          fontSize: nameFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Notification bell — real-time unread count
        if (uid != null)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: uid)
                .where('read', isEqualTo: false)
                .snapshots(),
            builder: (context, snap) {
              final count = snap.data?.size ?? 0;
              return _NotifBell(
                count: count,
                iconSize: isSmall ? 24 : 28,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                ),
              );
            },
          )
        else
          _NotifBell(count: 0, iconSize: isSmall ? 24 : 28),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Bonjour 👋";
    if (hour < 18) return "Bon après-midi 👋";
    return "Bonsoir 👋";
  }
}

class _NotifBell extends StatelessWidget {
  final int count;
  final double iconSize;
  final VoidCallback? onTap;
  const _NotifBell({required this.count, required this.iconSize, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_none, size: iconSize),
          if (count > 0)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CategoriesSection  — real-time from Firestore (fallback to static)
// ─────────────────────────────────────────────────────────────────────────────

class CategoriesSection extends StatelessWidget {
  final bool isSmall;
  final bool isTablet;
  const CategoriesSection({
    super.key,
    required this.isSmall,
    required this.isTablet,
  });

  static const List<_CatData> _fallback = [
    _CatData(
      icon: Icons.medical_services,
      color: Color(0xffC4B5FD),
      title: "Radiologie",
    ),
    _CatData(
      icon: Icons.psychology,
      color: Color(0xffFCD34D),
      title: "Neurologie",
    ),
    _CatData(
      icon: Icons.favorite,
      color: Color(0xffFCA5A5),
      title: "Cardiologie",
    ),
    _CatData(
      icon: Icons.visibility,
      color: Color(0xFF47CEE6),
      title: "Dentaire",
    ),
    _CatData(icon: Icons.healing, color: Color(0xFF49DE76), title: "Thérapie"),
  ];

  @override
  Widget build(BuildContext context) {
    final double itemSize = isSmall
        ? 58
        : isTablet
        ? 84
        : 70;
    final double fontSize = isSmall
        ? 11
        : isTablet
        ? 13
        : 12;
    final double listHeight = itemSize + 28;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Catégories",
          style: TextStyle(
            fontSize: isSmall
                ? 15
                : isTablet
                ? 20
                : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isSmall ? 12 : 16),
        SizedBox(
          height: listHeight,
          // ── Real-time categories from Firestore ─────────────────────
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('categories')
                .orderBy('order')
                .snapshots(),
            builder: (context, snap) {
              // If Firestore has categories, use them; otherwise show static
              if (snap.hasData && snap.data!.docs.isNotEmpty) {
                final docs = snap.data!.docs;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  separatorBuilder: (_, _) =>
                      SizedBox(width: isSmall ? 10 : 14),
                  itemBuilder: (_, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final color = Color(
                      int.tryParse(d['color']?.toString() ?? '') ?? 0xFFC4B5FD,
                    );
                    return _CategoryItem(
                      icon: _iconFromName(d['icon']?.toString()),
                      color: color,
                      title: d['title']?.toString() ?? '',
                      itemSize: itemSize,
                      fontSize: fontSize,
                    );
                  },
                );
              }
              // Fallback static list
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _fallback.length,
                separatorBuilder: (_, _) => SizedBox(width: isSmall ? 10 : 14),
                itemBuilder: (_, i) => _CategoryItem(
                  icon: _fallback[i].icon,
                  color: _fallback[i].color,
                  title: _fallback[i].title,
                  itemSize: itemSize,
                  fontSize: fontSize,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _iconFromName(String? name) {
    switch (name) {
      case 'psychology':
        return Icons.psychology;
      case 'favorite':
        return Icons.favorite;
      case 'visibility':
        return Icons.visibility;
      case 'healing':
        return Icons.healing;
      default:
        return Icons.medical_services;
    }
  }
}

class _CatData {
  final IconData icon;
  final Color color;
  final String title;
  const _CatData({
    required this.icon,
    required this.color,
    required this.title,
  });
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final double itemSize;
  final double fontSize;

  const _CategoryItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.itemSize,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: itemSize,
          width: itemSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(itemSize * 0.28),
          ),
          child: Icon(icon, color: Colors.white, size: itemSize * 0.44),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(fontSize: fontSize),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TopDoctorsSection  — real-time
// ─────────────────────────────────────────────────────────────────────────────

class TopDoctorsSection extends StatelessWidget {
  final bool isSmall;
  final bool isTablet;
  const TopDoctorsSection({
    super.key,
    required this.isSmall,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final double cardWidth = isSmall
        ? 150
        : isTablet
        ? 210
        : 180;
    final double listHeight = isSmall
        ? 260
        : isTablet
        ? 330
        : 295;

    return Column(
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Meilleurs Médecins",
              style: TextStyle(
                fontSize: isSmall
                    ? 15
                    : isTablet
                    ? 20
                    : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DoctorsPage()),
              ),
              child: Text(
                "Voir tout",
                style: TextStyle(
                  fontSize: isSmall ? 13 : 15,
                  color: const Color(0xFF266DE8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isSmall ? 10 : 14),

        // ── Real-time doctor list ─────────────────────────────────────
        SizedBox(
          height: listHeight,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('doctors')
                .orderBy('rating', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Aucun médecin disponible'));
              }

              final doctors = snapshot.data!.docs;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: doctors.length,
                separatorBuilder: (_, _) => SizedBox(width: isSmall ? 10 : 14),
                itemBuilder: (context, index) {
                  final doc = doctors[index];
                  final data = doc.data() as Map<String, dynamic>? ?? {};
                  return SizedBox(
                    width: cardWidth,
                    child: DoctorCard(
                      id: doc.id,
                      name:
                          "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}"
                              .trim(),
                      speciality: data['speciality']?.toString() ?? '',
                      rating: data['rating']?.toString() ?? '0',

                      year:
                          "${data['yearsOfExperience']?.toString() ?? '0'} ans",
                      hospital: data['clinicName']?.toString() ?? '',
                      isSmall: isSmall,
                      isTablet: isTablet,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DoctorCard  — real-time like state
// ─────────────────────────────────────────────────────────────────────────────

class DoctorCard extends StatelessWidget {
  final String id;
  final String name;
  final String speciality;
  final String rating;
  final String year;
  final String hospital;
  final bool isSmall;
  final bool isTablet;

  const DoctorCard({
    super.key,
    required this.id,
    required this.name,
    required this.speciality,
    required this.rating,
    required this.year,
    required this.hospital,
    this.isSmall = false,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    final double nameFontSize = isSmall
        ? 12
        : isTablet
        ? 15
        : 13;
    final double subFontSize = isSmall
        ? 10
        : isTablet
        ? 13
        : 11;
    final double iconSize = isSmall ? 12 : 14;
    final double pad = isSmall ? 8 : 10;

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // ── Image + real-time like button ───────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Icon(Icons.person, size: 100),
              ),
              if (currentUid != null)
                Positioned(
                  top: 5,
                  right: 5,
                  // ── Real-time like status ────────────────────────
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('doctors')
                        .doc(id)
                        .snapshots(),
                    builder: (context, snap) {
                      final data =
                          snap.data?.data() as Map<String, dynamic>? ?? {};
                      final likedBy = List<String>.from(data['likedBy'] ?? []);
                      final isLiked = likedBy.contains(currentUid);

                      return GestureDetector(
                        onTap: () async {
                          final ref = FirebaseFirestore.instance
                              .collection('doctors')
                              .doc(id);
                          if (isLiked) {
                            await ref.update({
                              'likedBy': FieldValue.arrayRemove([currentUid]),
                            });
                          } else {
                            await ref.update({
                              'likedBy': FieldValue.arrayUnion([currentUid]),
                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: isSmall ? 12 : 14,
                          backgroundColor: Colors.white,
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                            size: isSmall ? 13 : 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),

          SizedBox(height: isSmall ? 6 : 8),

          // Name
          Text(
            name.isEmpty ? 'Dr. —' : 'Dr. $name',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: nameFontSize,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isSmall ? 2 : 4),

          // Speciality
          Text(
            speciality,
            style: TextStyle(color: Colors.grey, fontSize: subFontSize),
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: isSmall ? 2 : 4),

          // Rating + years
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, color: Colors.orange, size: iconSize),
              const SizedBox(width: 2),
              Text(rating, style: TextStyle(fontSize: subFontSize)),
              const SizedBox(width: 8),
              Icon(Icons.work_outline, color: Colors.grey, size: iconSize),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  year,
                  style: TextStyle(fontSize: subFontSize),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: isSmall ? 2 : 4),

          // Hospital
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: Colors.blue, size: iconSize),
              Flexible(
                child: Text(
                  hospital,
                  style: TextStyle(fontSize: subFontSize),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Button
          SizedBox(
            width: double.infinity,
            height: isSmall ? 30 : 36,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DoctorProfile(doctorId: id)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                "Voir profil",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmall ? 11 : 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
