// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileDoc extends StatefulWidget {
  const EditProfileDoc({super.key});

  @override
  State<EditProfileDoc> createState() => _EditProfileDocState();
}

class _EditProfileDocState extends State<EditProfileDoc>
    with SingleTickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────────
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController clinicController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  final TextEditingController diplomeLevelController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController languagesController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();

  String gender = "Male";
  bool isLoading = true;
  bool isSaving = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // ── Design tokens ─────────────────────────────────────────────────────────
  static const _primary = Color(0xFF1A73E8);
  static const _primaryLight = Color(0xFFE8F0FE);
  static const _surface = Color(0xFFF8FAFC);
  static const _cardBg = Colors.white;
  static const _textDark = Color(0xFF1C2B4B);
  static const _textMuted = Color(0xFF8A94A6);
  static const _divider = Color(0xFFEEF2F7);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    fetchDoctorData();
  }

  @override
  void dispose() {
    _animController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    dateOfBirthController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    specialtyController.dispose();
    experienceController.dispose();
    clinicController.dispose();
    licenseController.dispose();
    feeController.dispose();
    diplomeLevelController.dispose();
    bioController.dispose();
    languagesController.dispose();
    ratingController.dispose();
    super.dispose();
  }

  Future<void> fetchDoctorData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docSnapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(uid)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      firstNameController.text = data['firstName'] ?? '';
      lastNameController.text = data['lastName'] ?? '';
      dateOfBirthController.text = data['dateOfBirth'] ?? '';
      phoneController.text = data['phone'] ?? '';
      emailController.text = data['email'] ?? '';
      addressController.text = data['address'] ?? '';
      specialtyController.text = data['speciality'] ?? '';
      experienceController.text = data['yearsOfExperience'] ?? '';
      clinicController.text = data['clinicName'] ?? '';
      licenseController.text = data['licenseNumber'] ?? '';
      feeController.text = data['consultationFee'] ?? '';
      diplomeLevelController.text = data['diplomeLevel'] ?? '';
      bioController.text = data['bio'] ?? '';
      languagesController.text = data['languages'] ?? '';
      ratingController.text = data['rating'] ?? '';
      gender = data['gender'] ?? 'Male';
    }

    if (mounted) {
      setState(() => isLoading = false);
      _animController.forward();
    }
  }

  Future<void> saveProfile() async {
    setState(() => isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('doctors').doc(uid).update({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'dateOfBirth': dateOfBirthController.text.trim(),
        'gender': gender,
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'address': addressController.text.trim(),
        'speciality': specialtyController.text.trim(),
        'yearsOfExperience': experienceController.text.trim(),
        'clinicName': clinicController.text.trim(),
        'licenseNumber': licenseController.text.trim(),
        'consultationFee': feeController.text.trim(),
        'diplomeLevel': diplomeLevelController.text.trim(),
        'bio': bioController.text.trim(),
        'languages': languagesController.text.trim(),
        'rating': ratingController.text.trim(),
      });

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text("Profile updated successfully"),
            ],
          ),
          backgroundColor: const Color(0xFF34A853),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _buildField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: _textDark,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: _textMuted, fontSize: 13),
        labelStyle: const TextStyle(color: _textMuted, fontSize: 13),
        prefixIcon: icon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(icon, color: _primary, size: 20),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _divider, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: _primary, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(color: _divider, height: 1),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: ['Male', 'Female'].map((g) {
        final selected = gender == g;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => gender = g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: g == 'Male' ? 8 : 0,
                left: g == 'Female' ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: selected ? _primary : _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? _primary : _divider,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    g == 'Male' ? Icons.male : Icons.female,
                    color: selected ? Colors.white : _textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    g,
                    style: TextStyle(
                      color: selected ? Colors.white : _textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _fieldGap() => const SizedBox(height: 14);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: _surface,
        body: const Center(child: CircularProgressIndicator(color: _primary)),
      );
    }

    // Responsive: tablet vs mobile
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final horizontalPadding = isTablet ? screenWidth * 0.1 : 16.0;

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: _cardBg,
            shape: const CircleBorder(),
            elevation: 2,
            shadowColor: Colors.black12,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _textDark,
                size: 18,
              ),
            ),
          ),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: isSaving ? null : saveProfile,
              style: TextButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Save",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16,
          ),
          child: Column(
            children: [
              // ── Avatar ──────────────────────────────────────────────────
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 52,
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/300",
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: _primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Full name below avatar
              Text(
                "${firstNameController.text} ${lastNameController.text}",
                style: const TextStyle(
                  color: _textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                specialtyController.text.isEmpty
                    ? "Doctor"
                    : specialtyController.text,
                style: const TextStyle(color: _textMuted, fontSize: 13),
              ),
              const SizedBox(height: 28),

              // ── Basic Details ────────────────────────────────────────────
              _buildSectionCard(
                title: "Basic Details",
                icon: Icons.person_outline_rounded,
                children: [
                  // Responsive two-column on tablet
                  if (isTablet)
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            "First Name",
                            firstNameController,
                            icon: Icons.badge_outlined,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildField("Last Name", lastNameController),
                        ),
                      ],
                    )
                  else ...[
                    _buildField(
                      "First Name",
                      firstNameController,
                      icon: Icons.badge_outlined,
                    ),
                    _fieldGap(),
                    _buildField("Last Name", lastNameController),
                  ],
                  _fieldGap(),
                  _buildField(
                    "Date of Birth",
                    dateOfBirthController,
                    icon: Icons.cake_outlined,
                    hint: "DD/MM/YYYY",
                  ),
                  _fieldGap(),
                  const Text(
                    "Gender",
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildGenderSelector(),
                ],
              ),

              // ── Contact Information ──────────────────────────────────────
              _buildSectionCard(
                title: "Contact Information",
                icon: Icons.contact_phone_outlined,
                children: [
                  _buildField(
                    "Phone Number",
                    phoneController,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  _fieldGap(),
                  _buildField(
                    "Email",
                    emailController,
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _fieldGap(),
                  _buildField(
                    "Address",
                    addressController,
                    icon: Icons.location_on_outlined,
                  ),
                ],
              ),

              // ── Professional Information ─────────────────────────────────
              _buildSectionCard(
                title: "Professional Information",
                icon: Icons.medical_services_outlined,
                children: [
                  if (isTablet)
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            "Speciality",
                            specialtyController,
                            icon: Icons.local_hospital_outlined,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildField(
                            "Years of Experience",
                            experienceController,
                            icon: Icons.workspace_premium_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _buildField(
                      "Speciality",
                      specialtyController,
                      icon: Icons.local_hospital_outlined,
                    ),
                    _fieldGap(),
                    _buildField(
                      "Years of Experience",
                      experienceController,
                      icon: Icons.workspace_premium_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  _fieldGap(),
                  _buildField(
                    "Clinic Name",
                    clinicController,
                    icon: Icons.business_outlined,
                  ),
                  _fieldGap(),
                  if (isTablet)
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            "License Number",
                            licenseController,
                            icon: Icons.verified_outlined,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildField(
                            "Consultation Fee",
                            feeController,
                            icon: Icons.payments_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _buildField(
                      "License Number",
                      licenseController,
                      icon: Icons.verified_outlined,
                    ),
                    _fieldGap(),
                    _buildField(
                      "Consultation Fee",
                      feeController,
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  _fieldGap(),
                  _buildField(
                    "Diplome Level",
                    diplomeLevelController,
                    icon: Icons.school_outlined,
                  ),
                  _fieldGap(),
                  _buildField(
                    "Languages",
                    languagesController,
                    icon: Icons.language_outlined,
                    hint: "e.g. English, French",
                  ),
                  _fieldGap(),
                  _buildField(
                    "Rating",
                    ratingController,
                    icon: Icons.star_outline_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  _fieldGap(),
                  _buildField(
                    "Bio",
                    bioController,
                    icon: Icons.notes_rounded,
                    maxLines: 4,
                    hint: "Write a short bio about yourself…",
                  ),
                ],
              ),

              // ── Save Button (bottom) ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: SizedBox(
                  width: isTablet ? 320 : double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      disabledBackgroundColor: _primary.withOpacity(0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: _primary.withOpacity(0.4),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Save Changes",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
