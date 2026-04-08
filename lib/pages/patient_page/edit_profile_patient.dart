// ignore_for_file: deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Supprimer l'import de intl
// import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _chronicCtrl = TextEditingController();

  String? _gender;
  String? _bloodType;
  DateTime? _birthDate;

  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _bloodGroups = [
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-",
  ];

  // Méthode pour formater la date en français sans intl
  String _formatFrenchDate(DateTime date) {
    const frenchMonths = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${frenchMonths[date.month - 1]} ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(uid)
          .get();
      if (!doc.exists || !mounted) return;

      final data = doc.data()!;

      // Gestion sécurisée des données
      String getStringValue(dynamic value) {
        if (value == null) return "";
        if (value is String) return value.trim();
        if (value is List && value.isNotEmpty) {
          return value.first.toString().trim();
        }
        return value.toString();
      }

      setState(() {
        _firstNameCtrl.text = getStringValue(data['firstName']);
        _lastNameCtrl.text = getStringValue(data['lastName']);
        _phoneCtrl.text = getStringValue(data['phone']);
        _emailCtrl.text = getStringValue(data['email']);
        _addressCtrl.text = getStringValue(data['address']);

        if (data['weight'] != null) {
          _weightCtrl.text = data['weight'].toString();
        }
        if (data['height'] != null) {
          _heightCtrl.text = data['height'].toString();
        }

        _allergiesCtrl.text = _listToCommaString(data['allergies']);
        _chronicCtrl.text = _listToCommaString(data['chronicDiseases']);

        _gender = getStringValue(data['gender']);
        _bloodType = getStringValue(data['bloodType']);

        if (data['dateOfBirth'] is Timestamp) {
          _birthDate = (data['dateOfBirth'] as Timestamp).toDate();
        }

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur chargement profil : $e")),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  String _listToCommaString(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      return value.map((e) => e.toString()).join(', ');
    }
    if (value is String && value.isNotEmpty) return value;
    return '';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final updateData = {
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'address': _addressCtrl.text.trim().isEmpty
            ? null
            : _addressCtrl.text.trim(),
        'gender': _gender,
        'bloodType': _bloodType,
        'weight': double.tryParse(_weightCtrl.text.trim()),
        'height': double.tryParse(_heightCtrl.text.trim()),
        'allergies': _allergiesCtrl.text.trim().isEmpty
            ? null
            : _allergiesCtrl.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
        'chronicDiseases': _chronicCtrl.text.trim().isEmpty
            ? null
            : _chronicCtrl.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_birthDate != null) {
        updateData['dateOfBirth'] = Timestamp.fromDate(_birthDate!);
      }

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(uid)
          .update(updateData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil mis à jour avec succès"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur sauvegarde : $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1995),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() => _birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le profil"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              // Photo + bouton edit
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.4),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 68,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(Icons.person, size: 64),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 20),
                          color: Colors.white,
                          onPressed: () {
                            // Implémenter la sélection de photo
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Fonctionnalité à venir"),
                              ),
                            );
                          },
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Section identité
              _sectionTitle(context, "Identité"),
              _textField("Prénom", _firstNameCtrl, required: true),
              _textField("Nom", _lastNameCtrl, required: true),

              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.cake_outlined),
                title: Text(
                  _birthDate == null
                      ? "Date de naissance"
                      : "Né(e) le ${_formatFrenchDate(_birthDate!)}",
                ),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: _pickBirthDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.grey.shade50,
              ),

              const SizedBox(height: 16),

              // Genre
              _sectionTitle(context, "Genre"),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Homme"),
                      value: "Male",
                      groupValue: _gender,
                      onChanged: (v) => setState(() => _gender = v),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Femme"),
                      value: "Female",
                      groupValue: _gender,
                      onChanged: (v) => setState(() => _gender = v),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Coordonnées
              _sectionTitle(context, "Coordonnées"),
              _textField(
                "Téléphone",
                _phoneCtrl,
                keyboardType: TextInputType.phone,
              ),
              _textField(
                "Email",
                _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              _textField(
                "Adresse",
                _addressCtrl,
                keyboardType: TextInputType.streetAddress,
              ),

              const SizedBox(height: 24),

              // Infos médicales
              _sectionTitle(context, "Informations médicales"),
              DropdownButtonFormField<String>(
                value: _bloodType?.isEmpty ?? true ? null : _bloodType,
                decoration: InputDecoration(
                  labelText: "Groupe sanguin",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.bloodtype),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _bloodGroups
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _bloodType = v),
              ),
              const SizedBox(height: 16),
              _textField(
                "Poids (kg)",
                _weightCtrl,
                keyboardType: TextInputType.number,
              ),
              _textField(
                "Taille (cm)",
                _heightCtrl,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),
              _multiLineField(
                "Allergies (séparées par virgule)",
                _allergiesCtrl,
                hintText: "Ex: pénicilline, arachides, pollen",
              ),
              _multiLineField(
                "Maladies chroniques",
                _chronicCtrl,
                hintText: "Ex: diabète, hypertension, asthme",
              ),

              const SizedBox(height: 40),

              // Bouton sauvegarde
              FilledButton.icon(
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _isSaving
                      ? "Enregistrement..."
                      : "Enregistrer les modifications",
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isSaving ? null : _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        validator: required
            ? (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null
            : null,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _multiLineField(
    String label,
    TextEditingController ctrl, {
    String hintText = "Séparez plusieurs éléments par une virgule",
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: 3,
        minLines: 2,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          alignLabelWithHint: true,
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _allergiesCtrl.dispose();
    _chronicCtrl.dispose();
    super.dispose();
  }
}
