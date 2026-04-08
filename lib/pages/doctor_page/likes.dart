// import 'package:flutter/material.dart';
// import 'package:medilink_flutter/pages/doctor_page/profil_patient_for_d.dart';

// class Patient {
//   final String name;
//   final int age;
//   final String blood;

//   Patient({required this.name, required this.age, required this.blood});
// }

// class Likes extends StatefulWidget {
//   const Likes({super.key});

//   @override
//   State<Likes> createState() => _Likes();
// }

// class _Likes extends State<Likes> {

//   final List<Patient> patients = [
//     Patient(name: "James Wilson", age: 25, blood: "O+"),
//     Patient(name: "Maria Garcia", age: 32, blood: "A+"),
//     Patient(name: "David Lee", age: 45, blood: "B-"),
//     Patient(name: "Emma Smith", age: 29, blood: "AB+"),
//   ];

//   String query = "";

//   @override
//   Widget build(BuildContext context) {
//     // Filtrer la liste selon la recherche
//     List<Patient> filteredPatients = patients
//         .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
//         .toList();

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text("Patients"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [

//             /// SEARCH BAR
//             TextField(
//               decoration: InputDecoration(
//                 hintText: "Search patient...",
//                 prefixIcon: const Icon(Icons.search),
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   query = value;
//                 });
//               },
//             ),

//             const SizedBox(height: 20),

//             /// PATIENT LIST
//             Expanded(
//               child: ListView.builder(
//                 itemCount: filteredPatients.length,
//                 itemBuilder: (context, index) {
//                   final patient = filteredPatients[index];
//                   return Card(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15)),
//                     margin: const EdgeInsets.only(bottom: 12),
//                     child: ListTile(
//                       leading: const CircleAvatar(
//                         backgroundImage:
//                             NetworkImage("https://i.pravatar.cc/150"),
//                       ),
//                       title: Text(patient.name,
//                           style: const TextStyle(fontWeight: FontWeight.bold)),
//                       subtitle: Text(
//                           "Age : ${patient.age}\nBlood : ${patient.blood}"),
//                       isThreeLine: true,
//                       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                       onTap: () {
//                         Navigator.push(
//                           context, 
//                           MaterialPageRoute(builder: (context)=> PatientProfilePage())
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: const Color(0xFFF4F6FB),
      
//     );
//   }
// }