// import 'package:flutter/material.dart';

// class SendPrescriptionPage extends StatefulWidget {
//   const SendPrescriptionPage({super.key});

//   @override
//   State<SendPrescriptionPage> createState() => _SendPrescriptionPageState();
// }

// class _SendPrescriptionPageState extends State<SendPrescriptionPage> {

//   final TextEditingController medicineController = TextEditingController();
//   final TextEditingController dosageController = TextEditingController();
//   final TextEditingController daysController = TextEditingController();
//   final TextEditingController notesController = TextEditingController();

//   List<TimeOfDay> times = [];

//   Future<void> pickTime() async {
//     TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );

//     if (picked != null) {
//       setState(() {
//         times.add(picked);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text("Send Prescription"),
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),

//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             /// PATIENT PROFILE
//             Container(
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//                 borderRadius: BorderRadius.circular(20),
//               ),

//               child: Row(
//                 children: const [

//                   CircleAvatar(
//                     radius: 35,
//                     backgroundImage:
//                         AssetImage("assets/images/1772970557260.jpg"),
//                   ),

//                   SizedBox(width: 15),

//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [

//                       Text(
//                         "Maya Suzan",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       SizedBox(height: 5),

//                       Text(
//                         "Age: 29",
//                         style: TextStyle(color: Colors.white70),
//                       ),

//                       Text(
//                         "Blood Group: O+",
//                         style: TextStyle(color: Colors.white70),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),

//             const SizedBox(height: 30),

//             const Text(
//               "Prescription Details",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 20),

//             /// MEDICINE
//             TextField(
//               controller: medicineController,
//               decoration: InputDecoration(
//                 labelText: "Medicine Name",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.blue)
//                 ),
//                 prefixIcon: const Icon(Icons.calendar_today , color: Colors.blue,),
//               ),
//             ),

//             const SizedBox(height: 15),

//             /// DOSAGE
//             TextField(
//               controller: dosageController,
//               decoration: InputDecoration(
//                 labelText: "Dosage",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.blue)
//                 ),
//                 prefixIcon: const Icon(Icons.calendar_today , color: Colors.blue,),
//               ),
//             ),

//             const SizedBox(height: 15),

//             /// DAYS
//             TextField(
//               controller: daysController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: "Duration (days)",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.blue)
//                 ),
//                 prefixIcon: const Icon(Icons.calendar_today , color: Colors.blue,),
//               ),
//             ),

//             const SizedBox(height: 20),

//             /// TIMES
//             const Text(
//               "Medicine Times",
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 10),

//             Column(
//               children: times.map((time) {
//                 return ListTile(
//                   leading: const Icon(Icons.access_time),
//                   title: Text(time.format(context)),
//                 );
//               }).toList(),
//             ),

//             const SizedBox(height: 10),

//             /// ADD TIME BUTTON
//             ElevatedButton.icon(
//               onPressed: pickTime,
//               icon: const Icon(Icons.add),
//               label: const Text("Add Time" , style: TextStyle(color: Colors.blue),),
//             ),

//             const SizedBox(height: 20),

//             /// NOTES
//             TextField(
//               controller: notesController,
//               maxLines: 3,
//               decoration: InputDecoration(
//                 labelText: "Doctor Notes",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 prefixIcon: const Icon(Icons.notes),
//               ),
//             ),

//             const SizedBox(height: 25),

//             /// SEND BUTTON
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {

//                   String medicine = medicineController.text;
//                   String dosage = dosageController.text;
//                   String days = daysController.text;
//                   String notes = notesController.text;
    
//                   if (medicine.isNotEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("Prescription Sent Successfully"),
//                       ),
//                     );
//                   }
//                 },

//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: const EdgeInsets.all(15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),

//                 child: const Text(
//                   "Send Prescription",
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             )

//           ],
//         ),
//       ),
//     );
//   }
// }