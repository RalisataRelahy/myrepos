// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medilink_app/pages/doctor_page/dashboard.dart';

class Formulaire extends StatefulWidget {
  const Formulaire({super.key});

  @override
  State<Formulaire> createState() => _FormulaireState();
}

class _FormulaireState extends State<Formulaire> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController yearsOfExperienceController =
      TextEditingController();
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController consultationFeeController =
      TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController specialityController = TextEditingController();
  final TextEditingController diplomaController = TextEditingController();
  final TextEditingController languagesController = TextEditingController();

  final List<String> _specialities = [];
  final List<String> _diplomas = [];
  final List<String> _languages = [];

  String? gender;
  DateTime? _birthDate;
  bool isLoading = false;
  int _currentStep = 0;
  final int _totalSteps = 4;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> _stepTitles = [
    "Basic Information & Account",
    "Contact Details",
    "Professional Information",
    "Profile Description",
  ];

  final List<String> _encouragements = [
    "Commençons par vos informations personnelles ! Vous êtes entre de bonnes mains 🌟",
    "Excellent ! Passons maintenant à vos coordonnées 🚀",
    "Vous gérez ça comme un champion ! Mettons en avant votre expertise médicale 💪",
    "Dernière ligne droite ! Aidez les patients à mieux vous connaître 🛡️",
  ];

  final List<IconData> _stepIcons = [
    Icons.person_outline_rounded,
    Icons.location_on_outlined,
    Icons.medical_services_outlined,
    Icons.description_outlined,
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
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    dateOfBirthController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();
    yearsOfExperienceController.dispose();
    clinicNameController.dispose();
    licenseNumberController.dispose();
    consultationFeeController.dispose();
    bioController.dispose();
    specialityController.dispose();
    diplomaController.dispose();
    languagesController.dispose();
    super.dispose();
  }

  void _animateStep() {
    _slideController.reset();
    _fadeController.reset();
    _slideController.forward();
    _fadeController.forward();
  }

  // ====================== RESPONSIVE HELPERS ======================
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
    if (_isDesktop(w)) return 760.0;
    if (_isTablet(w)) return 600.0;
    return double.infinity;
  }

  // ====================== VALIDATIONS ======================
  String? _validateRequired(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!RegExp(
      r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$',
    ).hasMatch(value)) {
      return 'Invalid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  // ====================== DATE PICKER ======================
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
        dateOfBirthController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  // ====================== CHIPS ======================
  void _addChip(TextEditingController controller, List<String> list) {
    final text = controller.text.trim();
    if (text.isNotEmpty && !list.contains(text)) {
      setState(() {
        list.add(text);
        controller.clear();
      });
    }
  }

  void _removeChip(List<String> list, String item) {
    setState(() => list.remove(item));
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

  // ====================== INSCRIPTION ======================
  Future<void> registerDoctor() async {
    // if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null || gender == null) {
      _showSnack("Please select date of birth and gender");
      return;
    }
    setState(() => isLoading = true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      final uid = credential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': 'doctor',
      });
      await FirebaseFirestore.instance.collection('doctors').doc(uid).set({
        'uid': uid,
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'dateOfBirth': Timestamp.fromDate(_birthDate!),
        'address': addressController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'speciality': _specialities,
        'diplomaLevel': _diplomas,
        'languages': _languages,
        'yearsOfExperience':
            int.tryParse(yearsOfExperienceController.text.trim()) ?? 0,
        'licenseNumber': licenseNumberController.text.trim(),
        'clinicName': clinicNameController.text.trim(),
        'consultationFee': double.tryParse(
          consultationFeeController.text.trim(),
        ),
        'bio': bioController.text.trim().isEmpty
            ? null
            : bioController.text.trim(),
        'rating': 0,
        'accountStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      _showSnack("Doctor registered successfully!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DoctorDashboard()),
      );
    } catch (e) {
      if (mounted) _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ====================== NAVIGATION ======================
  void _onNext() {
    // if (!_formKey.currentState!.validate()) return;
    if (_currentStep == 0) {
      if (_birthDate == null) {
        _showSnack("Please select your date of birth");
        return;
      }
      if (gender == null) {
        _showSnack("Please select your gender");
        return;
      }
    }
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _animateStep();
    } else {
      registerDoctor();
    }
  }

  void _onPrevious() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _animateStep();
    }
  }

  // ====================== BUILD ======================
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF7AB5E6);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Doctor Registration"),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                        // ── Progress ──
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

                        // ── Step indicator pills (tablet+) ──
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
                                        ScrollViewKeyboardDismissBehavior
                                            .onDrag,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        if (isDesktop &&
                                            (_currentStep == 0 ||
                                                _currentStep == 2))
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

                        // ── Nav buttons ──
                        _buildNavButtons(w, primaryColor),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  // ====================== STEP INDICATOR ======================
  Widget _buildStepIndicator(Color primaryColor, double w) {
    return Container(
      color: primaryColor.withOpacity(0.06),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: _hp(w)),
      child: Row(
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
            "Step ${_currentStep + 1}/$_totalSteps",
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

  // ====================== DESKTOP TWO-COLUMN ======================
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
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [..._buildStep1Left(w).children, ..._buildStep1Right(w).children],
  );

  Column _buildStep1Left(double w) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _sectionLabel("Personal Information", w),
      _rowFields(
        _textField(
          "First Name *",
          Icons.person_outline,
          firstNameController,
          validator: _validateRequired,
          w: w,
        ),
        _textField(
          "Last Name *",
          Icons.person_outline,
          lastNameController,
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
      _sectionLabel("Login Credentials", w),
      _textField(
        "Email Address *",
        Icons.email_outlined,
        emailController,
        keyboardType: TextInputType.emailAddress,
        validator: _validateEmail,
        w: w,
      ),
      _textField(
        "Password *",
        Icons.lock_outline,
        passwordController,
        obscureText: true,
        validator: _validatePassword,
        w: w,
      ),
      _textField(
        "Confirm Password *",
        Icons.lock_outline,
        confirmPasswordController,
        obscureText: true,
        validator: _validateConfirmPassword,
        w: w,
      ),
    ],
  );

  // ====================== STEP 2 ======================
  Widget _buildStep2(double w) {
    final isTab = _isTablet(w);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel("Contact Details", w),
        if (isTab)
          _rowFields(
            _textField(
              "Phone Number *",
              Icons.phone_outlined,
              phoneController,
              keyboardType: TextInputType.phone,
              validator: _validateRequired,
              w: w,
            ),
            _textField("Address", Icons.home_outlined, addressController, w: w),
            w,
          )
        else ...[
          _textField(
            "Phone Number *",
            Icons.phone_outlined,
            phoneController,
            keyboardType: TextInputType.phone,
            validator: _validateRequired,
            w: w,
          ),
          _textField("Address", Icons.home_outlined, addressController, w: w),
        ],
      ],
    );
  }

  // ====================== STEP 3 ======================
  Widget _buildStep3(double w) => Column(
    children: [..._buildStep3Left(w).children, ..._buildStep3Right(w).children],
  );

  Column _buildStep3Left(double w) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _sectionLabel("Practice Details", w),
      _multiInputField(
        "Speciality",
        "e.g. Cardiologist, Pediatrician",
        Icons.local_hospital_outlined,
        specialityController,
        _specialities,
        w,
      ),
      _rowFields(
        _textField(
          "Years of Experience",
          Icons.work_outline,
          yearsOfExperienceController,
          keyboardType: TextInputType.number,
          w: w,
        ),
        _textField(
          "Consultation Fee",
          Icons.payments_outlined,
          consultationFeeController,
          keyboardType: TextInputType.number,
          w: w,
        ),
        w,
      ),
      _textField(
        "Clinic Name",
        Icons.business_outlined,
        clinicNameController,
        w: w,
      ),
      _textField(
        "License Number",
        Icons.badge_outlined,
        licenseNumberController,
        w: w,
      ),
    ],
  );

  Column _buildStep3Right(double w) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _sectionLabel("Qualifications", w),
      _multiInputField(
        "Diploma Level",
        "e.g. MD, PhD, Specialist",
        Icons.school_outlined,
        diplomaController,
        _diplomas,
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
        _sectionLabel("About You", w),
        if (isTab)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _bioField(w)),
              const SizedBox(width: 24),
              Expanded(
                child: _multiInputField(
                  "Languages Spoken",
                  "e.g. English, French, Arabic",
                  Icons.language_outlined,
                  languagesController,
                  _languages,
                  w,
                ),
              ),
            ],
          )
        else ...[
          _bioField(w),
          _multiInputField(
            "Languages Spoken",
            "e.g. English, French, Arabic",
            Icons.language_outlined,
            languagesController,
            _languages,
            w,
          ),
        ],
      ],
    );
  }

  // ====================== NAV BUTTONS ======================
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
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: isTab ? 140 : 0),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                    label: const Text("Previous"),
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
              if (_currentStep > 0) const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  icon: isLoading
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
                    isLoading
                        ? "Registering..."
                        : (_currentStep == 3 ? "Save" : "Next"),
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
                  onPressed: isLoading ? null : _onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================== WIDGETS ======================
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
        label.toUpperCase(),
        style: TextStyle(
          fontSize: _fontSize(w, phone: 11.5, tablet: 12, desktop: 12.5),
          fontWeight: FontWeight.w700,
          color: const Color(0xFF7AB5E6),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, double w) {
    final isTab = _isTablet(w);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: _fontSize(w, phone: 14, tablet: 14.5)),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(fontSize: _fontSize(w)),
        decoration: _inputDecoration(label, icon, w),
      ),
    );
  }

  Widget _bioField(double w) {
    final isTab = _isTablet(w);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: bioController,
        maxLines: 5,
        minLines: 3,
        style: TextStyle(fontSize: _fontSize(w)),
        decoration: InputDecoration(
          labelText: "Bio",
          labelStyle: TextStyle(
            fontSize: _fontSize(w, phone: 14, tablet: 14.5),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 48),
            child: Icon(Icons.info_outline_rounded, size: isTab ? 22 : 20),
          ),
          hintText: "Brief description about yourself",
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          alignLabelWithHint: true,
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
        ),
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
                      ? "Date of Birth *"
                      : "Born on ${dateOfBirthController.text}",
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
    final verySmall = MediaQuery.of(context).size.width < 360;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gender *",
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
                    _genderOption("Male", "Male", w, primaryColor),
                    const SizedBox(height: 8),
                    _genderOption("Female", "Female", w, primaryColor),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _genderOption("Male", "Male", w, primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _genderOption("Female", "Female", w, primaryColor),
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
    final isSelected = gender == value;
    final icon = value == "Male" ? Icons.male_rounded : Icons.female_rounded;
    return GestureDetector(
      onTap: () => setState(() => gender = value),
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

  Widget _multiInputField(
    String label,
    String hint,
    IconData icon,
    TextEditingController ctrl,
    List<String> items,
    double w,
  ) {
    final isTab = _isTablet(w);
    const primaryColor = Color(0xFF7AB5E6);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: _fontSize(w, phone: 13.5, tablet: 14.5),
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  style: TextStyle(fontSize: _fontSize(w)),
                  onSubmitted: (_) => _addChip(ctrl, items),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: _fontSize(w, phone: 13, tablet: 13.5),
                      color: Colors.grey,
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
                      borderSide: const BorderSide(
                        color: primaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: isTab ? 14 : 12,
                      horizontal: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: isTab ? 52 : 48,
                child: ElevatedButton(
                  onPressed: () => _addChip(ctrl, items),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: isTab ? 18 : 14),
                    elevation: 1,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_rounded, size: 18),
                      if (isTab) ...[
                        const SizedBox(width: 4),
                        const Text(
                          "Add",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: items
                  .map(
                    (item) => AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: Chip(
                        label: Text(
                          item,
                          style: TextStyle(
                            fontSize: _fontSize(w, phone: 13, tablet: 13.5),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A4A72),
                          ),
                        ),
                        deleteIcon: const Icon(Icons.close_rounded, size: 16),
                        deleteIconColor: const Color(0xFF7AB5E6),
                        onDeleted: () => _removeChip(items, item),
                        backgroundColor: const Color(
                          0xFF7AB5E6,
                        ).withOpacity(0.12),
                        side: BorderSide(
                          color: const Color(0xFF7AB5E6).withOpacity(0.4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
