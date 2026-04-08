//import 'package:medilink_flutter/pageDoc/dashboard.dart';
import 'package:flutter/material.dart';

class Appointment {
  final String name;
  final String time;
  final String type;

  Appointment({
    required this.name,
    required this.time,
    required this.type,
  });
}

class TodaysAppointmentsScreen extends StatelessWidget {
  TodaysAppointmentsScreen({super.key});

  final List<Appointment> appointments = [
    Appointment(name: "Emma Smith", time: "09:00 AM", type: "Visit Clinic"),
    Appointment(name: "Mark Wilson", time: "10:30 AM", type: "HomePatient"),
    Appointment(name: "Anna Brown", time: "01:00 PM", type: "Visit Clinic"),
    Appointment(name: "James Lee", time: "03:00 PM", type: "HomeDoctor"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Today's Appointments"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundImage:
                            NetworkImage("https://i.pravatar.cc/150"),
                      ),
                      title: Text(appointment.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      subtitle: Text("${appointment.time} • ${appointment.type}"),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A7BFF),
                        ),
                        onPressed: () {
                          // Action de démarrer ou visualiser
                        },
                        child: Text(
                            "Annuler" , style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

