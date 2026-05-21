// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:medilink_app/pages/doctor_page/signin_doctor.dart';
import 'package:medilink_app/pages/patient_page/signin_page_patient.dart';
import 'package:medilink_app/pages/public/main_screen.dart';
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  final String? role;
  const Login({super.key, this.role});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final TextEditingController number = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isLoading = false;
  bool _obscure = true;

  late AnimationController _controller;
  late Animation<Offset> _iconSlide;
  late Animation<double> _iconFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _iconSlide = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );
    _iconFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  void navigate() {
    if (widget.role == "patient") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PatientSignupPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Formulaire()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    number.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> loginPatient() async {
    final email = number.text.trim();
    final pwd = password.text.trim();

    if (email.isEmpty || pwd.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    setState(() => isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: pwd,
      );

      final user = res.user ?? res.session?.user;

      if (user == null) {
        throw Exception('Utilisateur non récupéré');
      }

// récupérer rôle
      final data = await supabase
          .from('user_roles')
          .select('roles(name)')
          .eq('user_id', user.id)
          .single();

      final role = data['roles']['name'];

      if (role == 'patient') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainNavigation(uid: user.id),
          ),
        );
      }
      else if (role == 'doctor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainNavigation(uid: user.id),
          ),
        );
      }
    } on AuthException catch (e) {
      String message;

      switch (e.message) {
        case 'Invalid login credentials':
          message = 'Email ou mot de passe incorrect.';
          break;

        case 'Email not confirmed':
          message = 'Veuillez confirmer votre email avant de vous connecter.';
          break;

        default:
          message = 'Erreur d\'authentification : ${e.message}';
      }

      _showError(message);

    } on PostgrestException catch (e) {
      _showError('Erreur base de données : ${e.message}');

    } catch (e) {
      _showError('Erreur inattendue. Veuillez réessayer.');
      log('Login error: $e', name: 'auth');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double w = screen.width;
    final double h = screen.height;

    final bool isSmall = w < 360;
    final bool isMedium = w >= 360 && w < 600;
    final bool isTablet = w >= 600 && w < 900;

    // Responsive values
    final double hPad = isSmall
        ? 16
        : isMedium
        ? 25
        : isTablet
        ? 60
        : 140;
    final double cardPad = isSmall
        ? 18
        : isMedium
        ? 25
        : isTablet
        ? 32
        : 36;
    final double iconSize = isSmall
        ? 56
        : isMedium
        ? 72
        : isTablet
        ? 90
        : 100;
    final double welcomeSize = isSmall
        ? 22
        : isMedium
        ? 28
        : isTablet
        ? 32
        : 36;
    final double titleSize = isSmall
        ? 18
        : isMedium
        ? 22
        : isTablet
        ? 25
        : 27;
    final double bodySize = isSmall
        ? 13
        : isMedium
        ? 14
        : 15;
    final double fieldSpacing = h * 0.02;
    final double topSpacing = h * 0.07;

    return Scaffold(
      backgroundColor: const Color(0xFF7AB5E6),
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
                      SizedBox(height: topSpacing),

                      // ── Icon + Welcome ─────────────────────────────────
                      FadeTransition(
                        opacity: _iconFade,
                        child: SlideTransition(
                          position: _iconSlide,
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                width: iconSize,
                              ),
                              SizedBox(height: h * 0.012),
                              Text(
                                "Bienvenue!",
                                style: TextStyle(
                                  fontSize: welcomeSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.04),

                      // ── Card ───────────────────────────────────────────
                      FadeTransition(
                        opacity: _cardFade,
                        child: SlideTransition(
                          position: _cardSlide,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(cardPad),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 20,
                                  color: Colors.black12,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    "Se connecter en tant que ${widget.role ?? "unknown"}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),

                                SizedBox(height: fieldSpacing * 1.2),

                                // Email field
                                TextField(
                                  controller: number,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(fontSize: bodySize),
                                  decoration: InputDecoration(
                                    hintText: "Entrer votre email",
                                    labelText: "Email",
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: isSmall ? 12 : 16,
                                      horizontal: 12,
                                    ),
                                  ),
                                ),

                                SizedBox(height: fieldSpacing),

                                // Password field
                                TextField(
                                  controller: password,
                                  obscureText: _obscure,
                                  style: TextStyle(fontSize: bodySize),
                                  decoration: InputDecoration(
                                    hintText: "Entrer votre mot de passe",
                                    labelText: "Mot de passe",
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: isSmall ? 12 : 16,
                                      horizontal: 12,
                                    ),
                                  ),
                                ),

                                SizedBox(height: fieldSpacing * 1.5),

                                // Button
                                SizedBox(
                                  width: double.infinity,
                                  height: isSmall ? 46 : 52,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed: isLoading ? null : loginPatient,
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            "Se connecter",
                                            style: TextStyle(
                                              fontSize: bodySize + 1,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),

                                SizedBox(height: fieldSpacing * 0.8),

                                // Sign up link
                                Center(
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        "Vous n'avez pas encore de compte ?",
                                        style: TextStyle(
                                          fontSize: bodySize,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => navigate(),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          "Créer un compte",
                                          style: TextStyle(
                                            color: Colors.teal,
                                            fontSize: bodySize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: topSpacing * 0.6),
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
