// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:medilink_app/pages/public/main_screen.dart';

class PatientSignupPage extends StatefulWidget {
  const PatientSignupPage({super.key});

  @override
  State<PatientSignupPage> createState() => _PatientSignupPageState();
}

class _PatientSignupPageState extends State<PatientSignupPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _tensionCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();

  String? _gender;
  String? _bloodType;
  DateTime? _birthDate;

  final _bloodGroups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];

  bool _isLoading = false;
  int _currentStep = 0;
  final int _totalSteps = 4;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> _stepTitles = [
    "Identité & Compte",
    "Coordonnées",
    "Informations médicales",
    "Contact d'urgence",
  ];

  final List<String> _encouragements = [
    "Commençons par l'essentiel ! Vous êtes entre de bonnes mains ",
    "Super ! Passons à vos coordonnées, on avance bien ",
    "Vous gérez comme un pro ! Maintenant votre profil médical ",
    "Dernière ligne droite ! Un contact de confiance pour votre sécurité ",
  ];

  final List<IconData> _stepIcons = [
    Icons.person_outline_rounded,
    Icons.location_on_outlined,
    Icons.favorite_border_rounded,
    Icons.shield_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Première animation au démarrage
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _tensionCtrl.dispose();
    _allergiesCtrl.dispose();
    _conditionsCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  void _animateStep() {
    _slideController.reset();
    _fadeController.reset();
    _slideController.forward();
    _fadeController.forward();
  }

  // ====================== RESPONSIVE HELPERS ======================
  /// Breakpoints: phone < 600, tablet 600–900, desktop >= 900
  bool _isTablet(double w) => w >= 600;
  bool _isDesktop(double w) => w >= 900;

  double _hp(double w) {
    if (_isDesktop(w)) return 48.0;
    if (_isTablet(w)) return 32.0;
    return 20.0;
  }

  double _fontSize(
    double w, {
    double phone = 15,
    double tablet = 16.5,
    double desktop = 17,
  }) {
    if (_isDesktop(w)) return desktop;
    if (_isTablet(w)) return tablet;
    return phone;
  }

  double _maxContentWidth(double w) {
    if (_isDesktop(w)) return 720.0;
    if (_isTablet(w)) return 580.0;
    return double.infinity;
  }

  // ====================== VALIDATIONS ======================
  String? _validateRequired(String? value) =>
      value == null || value.trim().isEmpty ? 'Champ requis' : null;

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email requis';
    if (!RegExp(
      r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$',
    ).hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 6) return 'Au moins 6 caractères';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirmation requise';
    if (value != _passwordCtrl.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  // ====================== DATE PICKER ======================
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() => _birthDate = picked);
    }
  }

  // ====================== NAVIGATION ======================
  // ====================== NAVIGATION ======================
  void _onNext() {
    if (_currentStep == 0) {
      if (_birthDate == null) {
        _showSnack('Date de naissance requise');
        return;
      }
      if (_gender == null) {
        _showSnack('Veuillez sélectionner un genre');
        return;
      }
    }

  

    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _animateStep();
    } else {
      _submit();
    }
  }

  void _onPrevious() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _animateStep();
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ====================== SOUMISSION ======================
  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
          );
      final uid = credential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': 'patient',
      });
      await FirebaseFirestore.instance.collection('patients').doc(uid).set({
        'uid': uid,
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'gender': _gender,
        'dateOfBirth': Timestamp.fromDate(_birthDate!),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'address': _addressCtrl.text.trim().isEmpty
            ? null
            : _addressCtrl.text.trim(),
        'bloodType': _bloodType,
        'height': double.tryParse(_heightCtrl.text.trim()),
        'weight': double.tryParse(_weightCtrl.text.trim()),
        'tension': _tensionCtrl.text.trim().isEmpty
            ? null
            : _tensionCtrl.text.trim(),
        'allergies': _allergiesCtrl.text.trim().isEmpty
            ? []
            : _allergiesCtrl.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
        'chronicDiseases': _conditionsCtrl.text.trim().isEmpty
            ? []
            : _conditionsCtrl.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
        'currentMedications': [],
        'treatmentAntecedent': [],
        'emergencyContactName': _emergencyNameCtrl.text.trim().isEmpty
            ? null
            : _emergencyNameCtrl.text.trim(),
        'emergencyContactPhone': _emergencyPhoneCtrl.text.trim().isEmpty
            ? null
            : _emergencyPhoneCtrl.text.trim(),
        'consultingNumber': 0,
        'accountStatus': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigation(uid: uid)),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Erreur lors de la création du compte';
      if (e.code == 'email-already-in-use') msg = 'Cet email est déjà utilisé';
      if (e.code == 'weak-password') msg = 'Mot de passe trop faible';
      if (e.code == 'invalid-email') msg = 'Email invalide';
      if (mounted) _showSnack(msg);
    } catch (e) {
      if (mounted) _showSnack('Erreur inattendue : $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ====================== BUILD ======================
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF7AB5E6);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final hp = _hp(w);
            final maxW = _maxContentWidth(w);
            final isDesktop = _isDesktop(w);

            return Form(
              key: _formKey,
              child: Column(
                children: [
                  // ── Progress bar ──
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    height: 6,
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _totalSteps,
                      backgroundColor: Colors.grey[200],
                      color: primaryColor,
                      minHeight: 6,
                    ),
                  ),

                  // ── Step indicators (desktop/tablet: horizontal pills) ──
                  if (_isTablet(w)) _buildStepIndicator(primaryColor, w),

                  // ── Header ──
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      hp,
                      isDesktop ? 28 : 20,
                      hp,
                      12,
                    ),
                    child: _buildHeader(w, primaryColor),
                  ),

                  // ── Content ──
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxW),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                horizontal: hp,
                                vertical: 4,
                              ),
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Desktop: two-column layout for steps 1 & 3
                                  if (isDesktop &&
                                      (_currentStep == 0 || _currentStep == 2))
                                    _buildDesktopTwoColumn(w)
                                  else ...[
                                    Visibility(
                                      visible: _currentStep == 0,
                                      maintainState: true,
                                      child: _buildStep1(w),
                                    ),
                                    Visibility(
                                      visible: _currentStep == 1,
                                      maintainState: true,
                                      child: _buildStep2(w),
                                    ),
                                    Visibility(
                                      visible: _currentStep == 2,
                                      maintainState: true,
                                      child: _buildStep3(w),
                                    ),
                                    Visibility(
                                      visible: _currentStep == 3,
                                      maintainState: true,
                                      child: _buildStep4(w),
                                    ),
                                  ],
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Navigation buttons ──
                  _buildNavButtons(w, primaryColor),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ====================== STEP INDICATOR (tablet/desktop) ======================
  Widget _buildStepIndicator(Color primaryColor, double w) {
    return Container(
      color: primaryColor.withOpacity(0.06),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: _hp(w)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalSteps, (i) {
          final done = i < _currentStep;
          final active = i == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? primaryColor
                          : done
                          ? primaryColor.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: active || done
                            ? primaryColor
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          done ? Icons.check_circle_rounded : _stepIcons[i],
                          size: 16,
                          color: active
                              ? Colors.white
                              : done
                              ? primaryColor
                              : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _stepTitles[i],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: _isDesktop(w) ? 13 : 11.5,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: active
                                  ? Colors.white
                                  : done
                                  ? primaryColor
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (i < _totalSteps - 1)
                  Container(
                    width: 12,
                    height: 1.5,
                    color: i < _currentStep
                        ? primaryColor.withOpacity(0.5)
                        : Colors.grey.shade300,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ====================== HEADER ======================
  Widget _buildHeader(double w, Color primaryColor) {
    final isTab = _isTablet(w);
    final isDsk = _isDesktop(w);

    return Column(
      children: [
        if (!isTab)
          Text(
            "Étape ${_currentStep + 1}/$_totalSteps",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        if (!isTab) const SizedBox(height: 6),
        Text(
          _stepTitles[_currentStep],
          style: TextStyle(
            fontSize: isDsk
                ? 30
                : isTab
                ? 26
                : 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A2B3C),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _encouragements[_currentStep],
          style: TextStyle(
            fontSize: _fontSize(w, phone: 13.5, tablet: 15, desktop: 15.5),
            color: Colors.grey[600],
            height: 1.45,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ====================== DESKTOP TWO-COLUMN LAYOUT ======================
  Widget _buildDesktopTwoColumn(double w) {
    if (_currentStep == 0) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildStep1Left(w)),
          const SizedBox(width: 28),
          Expanded(child: _buildStep1Right(w)),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildStep3Left(w)),
          const SizedBox(width: 28),
          Expanded(child: _buildStep3Right(w)),
        ],
      );
    }
  }

  // ====================== STEP 1 ======================
  Widget _buildStep1(double w) => Column(
    children: [..._buildStep1Left(w).children, ..._buildStep1Right(w).children],
  );

  Column _buildStep1Left(double w) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _sectionLabel("Informations personnelles", w),
      _rowFields(
        _textField(
          "Prénom *",
          Icons.person_outline,
          _firstNameCtrl,
          validator: _validateRequired,
          w: w,
        ),
        _textField(
          "Nom *",
          Icons.person_outline,
          _lastNameCtrl,
          validator: _validateRequired,
          w: w,
        ),
        w,
      ),
      _genderSelector(w),
      _datePicker(w),
    ],
  );

  Column _buildStep1Right(double w) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _sectionLabel("Identifiants de connexion", w),
      _textField(
        "Email *",
        Icons.email_outlined,
        _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        validator: _validateEmail,
        w: w,
      ),
      _textField(
        "Mot de passe *",
        Icons.lock_outline,
        _passwordCtrl,
        obscureText: true,
        validator: _validatePassword,
        w: w,
      ),
      _textField(
        "Confirmer le mot de passe *",
        Icons.lock_outline,
        _confirmPasswordCtrl,
        obscureText: true,
        validator: _validateConfirmPassword,
        w: w,
      ),
    ],
  );

  // ====================== STEP 2 ======================
  Widget _buildStep2(double w) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _sectionLabel("Coordonnées", w),
      _textField(
        "Téléphone *",
        Icons.phone_outlined,
        _phoneCtrl,
        keyboardType: TextInputType.phone,
        validator: _validateRequired,
        w: w,
      ),
      _textField("Adresse", Icons.home_outlined, _addressCtrl, w: w),
    ],
  );

  // ====================== STEP 3 ======================
  Widget _buildStep3(double w) => Column(
    children: [..._buildStep3Left(w).children, ..._buildStep3Right(w).children],
  );

  Column _buildStep3Left(double w) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _sectionLabel("Données biométriques", w),
      _bloodTypeDropdown(w),
      _rowFields(
        _textField(
          "Poids (kg)",
          Icons.monitor_weight_outlined,
          _weightCtrl,
          keyboardType: TextInputType.number,
          w: w,
        ),
        _textField(
          "Taille (cm)",
          Icons.straighten,
          _heightCtrl,
          keyboardType: TextInputType.number,
          w: w,
        ),
        w,
      ),
      _textField(
        "Tension (ex: 120/80)",
        Icons.monitor_heart_outlined,
        _tensionCtrl,
        w: w,
      ),
    ],
  );

  Column _buildStep3Right(double w) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _sectionLabel("Antécédents médicaux", w),
      _multiLineField(
        "Allergies (séparées par virgule)",
        Icons.medication_outlined,
        _allergiesCtrl,
        w,
      ),
      _multiLineField(
        "Maladies chroniques (séparées par virgule)",
        Icons.health_and_safety_outlined,
        _conditionsCtrl,
        w,
      ),
    ],
  );

  // ====================== STEP 4 ======================
  Widget _buildStep4(double w) {
    final isTab = _isTablet(w);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel("Contact d'urgence", w),
        if (isTab)
          _rowFields(
            _textField(
              "Nom du contact",
              Icons.person_pin_outlined,
              _emergencyNameCtrl,
              w: w,
            ),
            _textField(
              "Téléphone du contact",
              Icons.phone_forwarded_outlined,
              _emergencyPhoneCtrl,
              keyboardType: TextInputType.phone,
              w: w,
            ),
            w,
          )
        else ...[
          _textField(
            "Nom du contact",
            Icons.person_pin_outlined,
            _emergencyNameCtrl,
            w: w,
          ),
          _textField(
            "Téléphone du contact",
            Icons.phone_forwarded_outlined,
            _emergencyPhoneCtrl,
            keyboardType: TextInputType.phone,
            w: w,
          ),
        ],
      ],
    );
  }

  // ====================== NAVIGATION BUTTONS ======================
  Widget _buildNavButtons(double w, Color primaryColor) {
    final hp = _hp(w);
    final isTab = _isTablet(w);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(hp, 12, hp, 20),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _maxContentWidth(w)),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  flex: isTab ? 0 : 1,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: isTab ? 140 : 0),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                      label: const Text("Précédent"),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isTab ? 16 : 14,
                          horizontal: isTab ? 20 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: primaryColor, width: 1.5),
                        foregroundColor: primaryColor,
                      ),
                      onPressed: _onPrevious,
                    ),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _currentStep == 3
                              ? Icons.check_circle_outline_rounded
                              : Icons.arrow_forward_ios_rounded,
                          size: 18,
                        ),
                  label: Text(
                    _isLoading
                        ? "Inscription en cours..."
                        : (_currentStep == 3 ? "Créer mon compte" : "Suivant"),
                    style: TextStyle(
                      fontSize: _fontSize(w, phone: 15, tablet: 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isTab ? 16 : 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                    shadowColor: primaryColor.withOpacity(0.4),
                  ),
                  onPressed: _isLoading ? null : _onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================== WIDGETS ======================

  /// Lay two fields side by side on tablet/desktop, stacked on phone
  Widget _rowFields(Widget left, Widget right, double w) {
    if (!_isTablet(w)) return Column(children: [left, right]);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Widget _sectionLabel(String label, double w) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, top: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: _fontSize(w, phone: 13, tablet: 13.5, desktop: 14),
          fontWeight: FontWeight.w700,
          color: const Color(0xFF7AB5E6),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _textField(
    String label,
    IconData icon,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    required double w,
  }) {
    final isTab = _isTablet(w);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(fontSize: _fontSize(w)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: _fontSize(w, phone: 14, tablet: 14.5),
          ),
          prefixIcon: Icon(icon, size: isTab ? 22 : 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7AB5E6), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: isTab ? 16 : 14,
            horizontal: 14,
          ),
          errorMaxLines: 2,
        ),
      ),
    );
  }

  Widget _multiLineField(
    String label,
    IconData icon,
    TextEditingController ctrl,
    double w,
  ) {
    final isTab = _isTablet(w);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        maxLines: 3,
        minLines: 2,
        style: TextStyle(fontSize: _fontSize(w)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: _fontSize(w, phone: 14, tablet: 14.5),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Icon(icon, size: isTab ? 22 : 20),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7AB5E6), width: 2),
          ),
          hintText: "Séparez par des virgules si plusieurs",
          hintStyle: const TextStyle(fontSize: 12.5, color: Colors.grey),
          alignLabelWithHint: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: isTab ? 16 : 14,
            horizontal: 14,
          ),
        ),
      ),
    );
  }

  Widget _bloodTypeDropdown(double w) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Groupe sanguin",
          prefixIcon: const Icon(Icons.bloodtype_outlined, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7AB5E6), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: _isTablet(w) ? 16 : 14,
            horizontal: 14,
          ),
        ),
        value: _bloodType,
        items: _bloodGroups
            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
            .toList(),
        onChanged: (v) => setState(() => _bloodType = v),
      ),
    );
  }

  Widget _datePicker(double w) {
    final isTab = _isTablet(w);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isTab ? 14 : 12,
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: isTab ? 22 : 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _birthDate == null
                      ? "Date de naissance *"
                      : "Né(e) le ${DateFormat('dd/MM/yyyy').format(_birthDate!)}",
                  style: TextStyle(
                    fontSize: _fontSize(w, phone: 14, tablet: 15),
                    color: _birthDate == null
                        ? Colors.grey[600]
                        : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.edit_calendar_outlined,
                size: 18,
                color: Colors.grey[500],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderSelector(double w) {
    const primaryColor = Color(0xFF7AB5E6);
    final screenW = MediaQuery.of(context).size.width;
    final verySmall = screenW < 360;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Genre *",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: _fontSize(w, phone: 13.5, tablet: 14.5),
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          verySmall
              ? Column(
                  children: [
                    _genderOption("Homme", "Male", w, primaryColor),
                    const SizedBox(height: 8),
                    _genderOption("Femme", "Female", w, primaryColor),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _genderOption("Homme", "Male", w, primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _genderOption("Femme", "Female", w, primaryColor),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _genderOption(
    String label,
    String value,
    double w,
    Color primaryColor,
  ) {
    final isSelected = _gender == value;
    final icon = value == "Male" ? Icons.male_rounded : Icons.female_rounded;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: _isTablet(w) ? 14 : 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.12) : Colors.white,
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? primaryColor : Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: _fontSize(w, phone: 14.5, tablet: 15.5),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? primaryColor : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
