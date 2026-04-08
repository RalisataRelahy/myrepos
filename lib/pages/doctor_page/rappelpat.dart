// import 'package:medilink_flutter/pages/doctor_page/dashboard.dart';
// import 'package:medilink_flutter/pages/doctor_page/patient.dart';
// import 'package:flutter/material.dart';

// class AppointmentReminderPage extends StatefulWidget {
//   const AppointmentReminderPage({super.key});

//   @override
//   State<AppointmentReminderPage> createState() => _AppointmentReminderPageState();
// }

// class _AppointmentReminderPageState extends State<AppointmentReminderPage> {

//   List<Map<String, dynamic>> appointments = [
//     {
//       "patient": "Emma Smith",
//       "time": "09:00 AM",
//       "date": "Today",
//     },
//     {
//       "patient": "Mark Wilson",
//       "time": "10:30 AM",
//       "date": "Today",
//       "status": "pending"
//     },
//     {
//       "patient": "Anna Brown",
//       "time": "01:00 PM",
//       "date": "Tomorrow",
//       "status": "pending"
//     },
//   ];

//   void addAppointment(String patient, String date, String time) {
//     setState(() {
//       appointments.add({
//         "patient": patient,
//         "date": date,
//         "time": time,
//         "status": "pending"
//       });
//     });
//   }

//   void completeAppointment(int index) {
//     setState(() {
//       appointments[index]["status"] = "done";
//     });
//   }

  

//   @override
//   Widget build(BuildContext context) {

//     List pendingAppointments = appointments
//         .where((a) => a["status"] == "pending")
//         .toList();

//     return Scaffold(
//       bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text("Rappels de rendez-vous"),
//       ),

//       floatingActionButton: FloatingActionButton(
//         onPressed: (){
//           Navigator.push(context, MaterialPageRoute(builder: (context)=> PatientListScreen()));
//         },
//         child: const Icon(Icons.add),
//       ),

//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: pendingAppointments.length,
//         itemBuilder: (context, index) {

//           final appointment = pendingAppointments[index];

//           return Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),

//             child: ListTile(

//               leading: const CircleAvatar(
//                 backgroundImage:
//                     NetworkImage("https://i.pravatar.cc/150"),
//               ),

//               title: Text(
//                 appointment["patient"],
//                 style: const TextStyle(
//                     fontWeight: FontWeight.bold),
//               ),

//               subtitle: Text(
//                   "${appointment["date"]} • ${appointment["time"]}"),

//               trailing: ElevatedButton(
//                 onPressed: () {
//                   completeAppointment(index);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                 ),
//                 child: const Text(
//                   "Terminé",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }