class Diagnostic {
  final String id; // identifiant unique
  final String name; // nom du diagnostic
  final String? description; // détails optionnels
  final String? severity; // "léger", "modéré", "grave"
  final bool confirmed; // vrai si confirmé

  Diagnostic({
    required this.id,
    required this.name,
    this.description,
    this.severity,
    required this.confirmed,
  });

  // Conversion depuis Firestore / Map
  factory Diagnostic.fromMap(Map<String, dynamic> data) {
    return Diagnostic(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      severity: data['severity'],
      confirmed: data['confirmed'],
    );
  }

  // Conversion vers Firestore / Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'severity': severity,
      'confirmed': confirmed,
    };
  }
}
