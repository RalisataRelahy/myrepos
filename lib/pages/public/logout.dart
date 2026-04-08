import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medilink_app/pages/choose_ur_role.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  Future<String> _getDisplayName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 'Utilisateur';

    for (final collection in ['patients', 'doctors']) {
      final doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final name = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}"
              .trim();
          if (name.isNotEmpty) return name;
        }
      }
    }
    return 'Utilisateur';
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChooseUrRole()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double w = screen.width;

    final bool isSmall = w < 360;
    final bool isTablet = w >= 600;

    final double hPad = isSmall
        ? 20
        : isTablet
        ? 100
        : 28;
    final double avatarRadius = isSmall
        ? 38
        : isTablet
        ? 64
        : 50;
    final double nameFontSize = isSmall
        ? 18
        : isTablet
        ? 26
        : 22;
    final double subFontSize = isSmall
        ? 13
        : isTablet
        ? 17
        : 15;
    final double btnFontSize = isSmall
        ? 14
        : isTablet
        ? 17
        : 16;
    final double btnVPad = isSmall ? 12 : 15;
    final double gap = screen.height * 0.02;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: gap * 2),

                      // ── Avatar ─────────────────────────────────────
                      CircleAvatar(
                        radius: avatarRadius,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.person_3,
                          size: avatarRadius,
                          color: Colors.blue,
                        ),
                      ),

                      SizedBox(height: gap),

                      // ── Nom (real-time) ────────────────────────────
                      FutureBuilder<String>(
                        future: _getDisplayName(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              height: nameFontSize + 8,
                              width: 120,
                              child: const LinearProgressIndicator(
                                minHeight: 2,
                              ),
                            );
                          }
                          return Text(
                            snapshot.data ?? 'Utilisateur',
                            style: TextStyle(
                              fontSize: nameFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),

                      SizedBox(height: gap * 0.5),

                      Text(
                        "Êtes-vous sûr de vouloir vous déconnecter ?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: subFontSize,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: gap * 2.5),

                      // ── Bouton déconnexion ─────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _logout(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: btnVPad),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            "Se déconnecter",
                            style: TextStyle(
                              fontSize: btnFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: gap * 0.8),

                      // ── Bouton annuler ─────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: btnVPad),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Annuler",
                            style: TextStyle(fontSize: btnFontSize),
                          ),
                        ),
                      ),

                      SizedBox(height: gap * 2),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
