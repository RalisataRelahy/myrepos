import 'package:flutter/material.dart';

class Appointment {
  final String patient;
  final String date;
  final String time;
  String status;

  Appointment({
    required this.patient,
    required this.date,
    required this.time,
    required this.status,
  });
}

class AllAppointmentPage extends StatefulWidget {
  const AllAppointmentPage({super.key});

  @override
  State<AllAppointmentPage> createState() => _AllAppointmentPageState();
}

class _AllAppointmentPageState extends State<AllAppointmentPage> {
  String selectedTab = "upcoming";

  List<Appointment> appointments = [
    Appointment(
      patient: "Jean Paul",
      date: "22 March 2026",
      time: "16:00",
      status: "upcoming",
    ),

    Appointment(
      patient: "David",
      date: "24 March 2026",
      time: "09:00",
      status: "upcomming",
    ),
    Appointment(
      patient: "Marie Claire",
      date: "23 March 2026",
      time: "10:00",
      status: "completed",
    ),
  ];

  List<Appointment> getFiltered() {
    return appointments.where((a) => a.status == selectedTab).toList();
  }

  Widget animatedTab(String label, String value) {
    bool active = selectedTab == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = value;
        });
      },

      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(30),
        ),

        child: AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 300),
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget appointmentCard(Appointment a) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),

      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/150?img=5",
                ),
              ),

              SizedBox(width: 15),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.patient,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 4),

                  Text("Patient", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),

          SizedBox(height: 15),

          Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.blue),

              SizedBox(width: 6),

              Text(a.date),

              SizedBox(width: 20),

              Icon(Icons.access_time, color: Colors.blue),

              SizedBox(width: 6),

              Text(a.time),
            ],
          ),

          SizedBox(height: 20),

          if (a.status == "upcoming")
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),

                onPressed: () {
                  /*setState(() {
                    a.status = "canceled";
                  });*/
                },

                child: Text("Annuler", style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Appointment> list = getFiltered();

    return Column(
      children: [
        SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            animatedTab("Upcoming", "upcoming"),
            animatedTab("Completed", "completed"),

            //animatedTab("Canceled", "canceled"),
          ],
        ),

        SizedBox(height: 20),

        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 400),

            child: ListView.builder(
              key: ValueKey(selectedTab),

              itemCount: list.length,

              itemBuilder: (context, index) {
                return appointmentCard(list[index]);
              },
            ),
          ),
        ),
      ],
    );
  }
}
