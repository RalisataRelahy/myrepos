// import 'package:medilink_flutter/pages/event_page.dart';
// import 'package:flutter/material.dart';

// // NONNNNNNNNNNNNNNNNNNNNNNN
// class Prescription {
//   final String doctorName;
//   final String doctorSpecialty;
//   final String medicineName;
//   final String dosage;
//   final DateTime date;
//   final String duree;
//   final String temps;
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
//   final List<Prescription> prescriptions = [
//     Prescription(
//       doctorName: 'Dr. Alice Dupont',
//       doctorSpecialty: 'Cardiologue',
//       medicineName: 'Aspirine',
//       dosage: '100mg / jour',
//       date: DateTime(2026, 3, 10),
//       duree: "4jours",
//       temps: "11:20 AM , 19:00 PM",
//       notes: 'À prendre après le repas',
//     ),
//     Prescription(
//       doctorName: 'Dr. Jean Martin',
//       doctorSpecialty: 'Dermatologue',
//       medicineName: 'Crème Cicatrisante',
//       dosage: '2 fois par jour',
//       date: DateTime(2026, 3, 12),
//       duree: "4jours",
//       temps: "11:20 AM , 19:00 PM",
//       notes: 'Appliquer sur la zone affectée',
//     ),
//     Prescription(
//       doctorName: 'Dr. Sophie Bernard',
//       doctorSpecialty: 'Pédiatre',
//       medicineName: 'Paracétamol',
//       dosage: '500mg / 8h',
//       date: DateTime(2026, 3, 14),
//       duree: "4jours",
//       temps: "11:20 AM , 19:00 PM",
//       notes: 'Pour fièvre légère',
//     ),
//   ];

//   Ordonnances({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text("Prescriptions"),
//       ),
//       body: ListView.builder(
//         itemCount: prescriptions.length,
//         itemBuilder: (context, index) {
//           final prescription = prescriptions[index];
//           return Card(
//             margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: ListTile(
//               leading: Icon(Icons.medical_services, color: Colors.blue),
//               title: Text(
//                 '${prescription.medicineName} - ${prescription.dosage}',
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Prescrit par: ${prescription.doctorName} (${prescription.doctorSpecialty})',
//                   ),
//                   Text(
//                     'Date: ${prescription.date.day}/${prescription.date.month}/${prescription.date.year}',
//                   ),
//                   Text('Duree: ${prescription.duree}'),
//                   Text('Temps: ${prescription.temps}'),
//                   Text('Notes: ${prescription.notes}'),
//                 ],
//               ),
//               isThreeLine: true,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
