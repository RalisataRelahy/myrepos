// import 'package:medilink_flutter/pages/event_page.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// // NONNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
// class Sended extends StatelessWidget {
//   const Sended({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.green,
//                 borderRadius: BorderRadius.circular(50),
//               ),
//               child: const Icon(Icons.check, size: 50, color: Colors.white),
//             ),
//             Text("Demande envoyée", style: TextStyle(fontSize: 30)),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         EventPage(uid: FirebaseAuth.instance.currentUser!.uid),
//                   ),
//                 );
//               },

//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.all(15),
//                 backgroundColor: Colors.blue,
//               ),

//               child: const Text(
//                 "Acceuil",
//                 style: TextStyle(fontSize: 16, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
