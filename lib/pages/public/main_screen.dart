// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medilink_app/pages/doctor_page/appointement.dart';
import 'package:medilink_app/pages/doctor_page/dashboard.dart';
import 'package:medilink_app/pages/doctor_page/patient_list_page.dart';

import 'package:medilink_app/pages/patient_page/self_patient_profil.dart'; // ← à renommer plus tard ?
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medilink_app/pages/doctor_page/self_doctor_profil.dart';
import 'package:medilink_app/pages/patient_page/home_page.dart';
import 'package:medilink_app/pages/patient_page/medecin_list_page.dart';
import 'package:medilink_app/pages/patient_page/medical_page.dart';
import 'package:medilink_app/pages/public/login_page.dart';
import 'package:medilink_app/widgets/drawer.dart';

class MainNavigation extends StatefulWidget {
  final String uid;
  const MainNavigation({super.key, required this.uid});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String? _role; // 'patient' | 'doctor' | null
  bool _isLoading = true;
  late String uid = widget.uid;
  late AnimationController _animController;

  static const Color _bg = Color(0xFFF4F6FB);

  // ─── Pages & Items par rôle ───────────────────────────────────────────────
  List<Widget> _pages = [];
  List<_NavItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadUserRole();
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = supabase.auth.currentUser;

    final data = await supabase
        .from('users')
        .select()
        .eq('id', user!.id)
        .single();

    return data;
  }

  Future<void> _loadUserRole() async {
    try {
      if (patientSnap.exists) {
        _initForPatient();
        return;
      }

      // Vérification médecin
      final doctorSnap = await FirebaseFirestore.instance
          .collection('doctors') // ou 'medecins' selon ta base
          .doc(uid)
          .get();

      if (doctorSnap.exists) {
        _initForDoctor();
        return;
      }

      // Aucun rôle trouvé → déconnexion
      await FirebaseAuth.instance.signOut();
      _redirectToLogin();
    } catch (e) {
      debugPrint("Erreur chargement rôle : $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement du profil")),
        );
      }
      _redirectToLogin();
    }
  }

  void _initForPatient() {
    setState(() {
      _role = 'patient';
      _pages = const [
        HomePage(),
        DoctorsPage(),
        PrescriptionPage(),
        PatientProfilePage(),
      ];
      _navItems = const [
        _NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: "Accueil",
          activeColor: Color(0xFF1A73E8),
        ),
        _NavItem(
          icon: Icons.medical_services_outlined,
          activeIcon: Icons.medical_services_rounded,
          label: "Médecins",
          activeColor: Color(0xFF0D9488),
        ),
        _NavItem(
          icon: Icons.folder_special_outlined,
          activeIcon: Icons.folder_special_rounded,
          label: "Dossier",
          activeColor: Color(0xFF7C3AED),
        ),
        _NavItem(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: "Profil",
          activeColor: Color(0xFFDB2777),
        ),
      ];
      _isLoading = false;
    });
  }

  void _initForDoctor() {
    setState(() {
      _role = 'doctor';
      _pages = [
        const DoctorDashboard(), // ou DashboardDoctor()
        const PatientListScreen(), // ou CalendarDoctor()
        TodaysAppointmentsScreen(), // ou MyPatientsPage()
        DoctorSelfProfile(),
      ];
      _navItems = const [
        _NavItem(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard_rounded,
          label: "Accueil",
          activeColor: Color(0xFF1A73E8),
        ),
        _NavItem(
          icon: Icons.medical_services_outlined,
          activeIcon: Icons.medical_services_rounded,
          label: "Mes patients",
          activeColor: Color(0xFF0D9488),
        ),
        _NavItem(
          icon: Icons.calendar_today_outlined,
          activeIcon: Icons.calendar_today_rounded,
          label: "Mes rendez-vous",
          activeColor: Color(0xFF7C3AED),
        ),
        _NavItem(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: "Profil",
          activeColor: Color(0xFFDB2777),
        ),
      ];
      _isLoading = false;
    });
  }

  void _redirectToLogin() {
    // À adapter selon ton flux (IntroPage, LoginPage, etc.)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Login()),
      );
    });
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
    _animController.forward(from: 0);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_role == null || _pages.isEmpty) {
      return const Scaffold(body: Center(child: Text("Rôle non reconnu")));
    }

    return Scaffold(
      drawer: CustomDrawer(),
      backgroundColor: _bg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (i) => _buildNavBarItem(i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem(int index) {
    final item = _navItems[index];
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? item.activeColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                color: isActive ? item.activeColor : const Color(0xFFB0B8C9),
                size: 24,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isActive
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: item.activeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.1,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Modèle item nav ────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color activeColor;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.activeColor,
  });
}
