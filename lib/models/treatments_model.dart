class Treatment {
  final String medicationName;
  final String dosage; // ex: "500mg"
  final String frequency; // ex: "2 times per day"
  final int durationInDays;
  final String? instructions; // ex: "After meals"

  Treatment({
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.durationInDays,
    this.instructions,
  });

  // Conversion depuis Firestore / Map
  factory Treatment.fromMap(Map<String, dynamic> data) {
    return Treatment(
      medicationName: data['medicationName'],
      dosage: data['dosage'],
      frequency: data['frequency'],
      durationInDays: data['durationInDays'],
      instructions: data['instructions'],
    );
  }

  // Conversion vers Firestore / Map
  Map<String, dynamic> toMap() {
    return {
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'durationInDays': durationInDays,
      'instructions': instructions,
    };
  }
}
