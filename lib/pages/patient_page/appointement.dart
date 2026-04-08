// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class MyAppointmentPage extends StatefulWidget {
  const MyAppointmentPage({super.key});

  @override
  State<MyAppointmentPage> createState() => _MyAppointmentPageState();
}

class _MyAppointmentPageState extends State<MyAppointmentPage> {
  Widget upCommingList() {
    return ListView(
      key: const ValueKey(1),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: const [
        AppointmentCard(
          name: "Dr. Anne Myller",
          speciality: "Dental Speciality",
          date: "22 March 2026",
          time: "16:00 pm",
          type: "Hospital",
          image: "assets/images/1772983374731.jpg",
          showButtons: true,
        ),
        SizedBox(height: 10),
        AppointmentCard(
          name: "Dr. Anne Myller",
          speciality: "Dental Speciality",
          date: "22 March 2026",
          time: "16:00 pm",
          type: "Hospital",
          image: "assets/images/1772983374731.jpg",
          showButtons: true,
        ),
        SizedBox(height: 10),
        AppointmentCard(
          name: "Dr. Anne Myller",
          speciality: "Dental Speciality",
          date: "22 March 2026",
          time: "16:00 pm",
          type: "Hospital",
          image: "assets/images/1772983374731.jpg",
          showButtons: true,
        ),
      ],
    );
  }

  Widget completedList() {
    return ListView(
      key: const ValueKey(2),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: const [
        AppointmentCard(
          name: "Dr. Anne Myller",
          speciality: "Dental Speciality",
          date: "22 March 2026",
          time: "16:00 pm",
          type: "Hospital",
          image: "assets/images/1772983374731.jpg",
        ),
        SizedBox(height: 10),
        AppointmentCard(
          name: "Dr. Anne Myller",
          speciality: "Dental Speciality",
          date: "22 March 2026",
          time: "16:00 pm",
          type: "Hospital",
          image: "assets/images/1772983374731.jpg",
        ),
      ],
    );
  }

  Widget RappelList() {
    return ListView(
      key: const ValueKey(3),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: const [
        AppointmentCard(
          name: "Dr. Anne Myller",
          speciality: "Dental Speciality",
          date: "22 March 2026",
          time: "16:00 pm",
          type: "Hospital",
          image: "assets/images/1772983374731.jpg",
        ),
        SizedBox(height: 10),
      ],
    );
  }

  String selectedTab = "Upcomming";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// FILTER BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilterButton(
                      text: "Upcoming",
                      active: selectedTab == "Upcomming",
                      onTap: () {
                        setState(() {
                          selectedTab = "Upcomming";
                        });
                      },
                    ),
                    FilterButton(
                      text: "Completed",
                      active: selectedTab == "Completed",
                      onTap: () {
                        setState(() {
                          selectedTab = "Completed";
                        });
                      },
                    ),
                    FilterButton(
                      text: "Rappel",
                      active: selectedTab == "Rappel",
                      onTap: () {
                        setState(() {
                          selectedTab = "Canceled";
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// LIST APPOINTMENTS
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: selectedTab == "Upcomming"
                  ? upCommingList()
                  : selectedTab == "Completed"
                  ? completedList()
                  : RappelList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// FILTER BUTTON
class FilterButton extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const FilterButton({
    super.key,
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// APPOINTMENT CARD
class AppointmentCard extends StatelessWidget {
  final String name;
  final String speciality;
  final String date;
  final String time;
  final String type;
  final String image;
  final bool showButtons;

  const AppointmentCard({
    super.key,
    required this.name,
    required this.speciality,
    required this.date,
    required this.time,
    required this.type,
    required this.image,
    this.showButtons = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(
        children: [
          /// DOCTOR INFO
          Row(
            children: [
              CircleAvatar(radius: 30, backgroundImage: AssetImage(image)),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    Text(
                      speciality,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          /// DATE TIME TYPE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 5),
                  Text(date),
                ],
              ),

              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.blue),
                  const SizedBox(width: 5),
                  Text(time),
                ],
              ),

              Row(
                children: [
                  const Icon(
                    Icons.local_hospital,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 5),
                  Text(type),
                ],
              ),
            ],
          ),

          if (showButtons) ...[
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 5),
                        Text(
                          "Delete",
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Expanded(
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => const UpdateBooking(),
                //         ),
                //       );
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.blue,
                //     ),
                //     child: const Text(
                //       "Update",
                //       style: TextStyle(color: Colors.white),
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
