// import 'package:flutter/material.dart';

// // NONNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNMMMMMMMMMMMMMMMMMMMM
// class Prescription {
//   final String doctorName;
//   final String doctorSpecialty;
//   final String medicineName;
//   final String dosage;
//   final String duree;
//   final String temps;
//   final DateTime date;

//   final String notes;

//   Prescription({
//     required this.doctorName,
//     required this.doctorSpecialty,
//     required this.medicineName,
//     required this.dosage,
//     required this.date,
//     required this.duree,
//     required this.temps,
//     required this.notes,
//   });
// }

// class Ordonnances extends StatelessWidget {
//   const Ordonnances({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Ordonnance',
//       debugShowCheckedModeBanner: false,
//       home: const PrescriptionPage(),
//     );
//   }
// }

// class PrescriptionPage extends StatelessWidget {
//   const PrescriptionPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final Prescription prescription = Prescription(
//       doctorName: 'Dr. Alice Dupont',
//       doctorSpecialty: 'Cardiologue',
//       medicineName: 'Aspirine',
//       dosage: '100mg / jour',
//       date: DateTime(2026, 3, 15),
//       duree: "4jours",
//       temps: "11:20 AM , 19:00 PM",
//       notes: 'À prendre après le repas',
//     );
//     return Scaffold(
//       appBar: AppBar(title: const Text('Ordonnance')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Médecin
//                 Row(
//                   children: [
//                     Icon(Icons.medical_services, color: Colors.blue, size: 30),
//                     SizedBox(width: 10),
//                     Expanded(
//                       child: Text(
//                         '${prescription.doctorName} (${prescription.doctorSpecialty})',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Divider(height: 30, thickness: 1),

//                 // Médicament et dosage
//                 Text(
//                   'Médicament : ${prescription.medicineName}',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'Dosage : ${prescription.dosage}',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 SizedBox(height: 8),

//                 // Date
//                 Text(
//                   'Date : ${prescription.date.day}/${prescription.date.month}/${prescription.date.year}',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 SizedBox(height: 8),

//                 Text(
//                   'Duree : ${prescription.duree}',
//                   style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'Temps : ${prescription.temps}',
//                   style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
//                 ),
//                 // Notes
//                 Text(
//                   'Notes : ${prescription.notes}',
//                   style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Widget pour chaque médicament
