// import 'package:medilink_flutter/pages/about2.dart';
// import 'package:medilink_flutter/pages/event_page.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class FavoritePage extends StatefulWidget {
//   const FavoritePage({super.key});

//   @override
//   State<FavoritePage> createState() => _FavoritePageState();
// }

// class _FavoritePageState extends State<FavoritePage> {
//   final String currentUid = FirebaseAuth.instance.currentUser!.uid;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text("Favorites"),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('doctors')
//             .where('likedBy', arrayContains: currentUid)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No favorite doctors yet"));
//           }

//           final doctors = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: doctors.length,
//             itemBuilder: (context, index) {
//               final doc = doctors[index];
//               final data = doctors[index].data() as Map<String, dynamic>;
//               final name =
//                   (data['firstName'] != null && data['lastName'] != null)
//                   ? "${data['firstName']} ${data['lastName']}"
//                   : data['fullname'] ?? "No name";

//               final speciality = data['speciality'] ?? "";
//               final image = data['image'] ?? 'assets/images/john.png';
//               final experience = "${data['yearsOfExperience'] ?? 0}years";
//               final hospital = data['clinicName'] ?? '';

//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundImage: AssetImage(image),
//                     radius: 25,
//                   ),
//                   title: Text(name),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(speciality),
//                       Text(experience),
//                       Text(hospital),
//                     ],
//                   ),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.cancel, color: Colors.red),
//                     onPressed: () async {
//                       await FirebaseFirestore.instance
//                           .collection('doctors')
//                           .doc(doc.id)
//                           .update({
//                             'likedBy': FieldValue.arrayRemove([currentUid]),
//                           });
//                     },
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => DoctorProfile(doctorId: doc.id),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
