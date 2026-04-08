import 'package:flutter/material.dart';

class AddAppointmentReminderPage extends StatefulWidget {
  const AddAppointmentReminderPage({super.key});

  @override
  State<AddAppointmentReminderPage> createState() =>
      _AddAppointmentReminderPageState();
}

class _AddAppointmentReminderPageState
    extends State<AddAppointmentReminderPage> {

  TextEditingController reasonController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  Future pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        dateController.text =
            "${date.day}/${date.month}/${date.year}";
      });
    }
  }

  Future pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        timeController.text = time.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Ajouter un rappel"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// PROFILE PATIENT
            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                  )
                ],
              ),

              child: Row(
                children: [

                  const CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        NetworkImage("https://i.pravatar.cc/150"),
                  ),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: const [

                      Text(
                        "Emma Smith",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "Female • 28 yrs",
                        style:
                            TextStyle(color: Colors.grey),
                      ),

                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// RAISON DU RENDEZ VOUS
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: "Motif du rendez-vous",
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// DATE
            TextField(
              controller: dateController,
              readOnly: true,
              onTap: pickDate,
              decoration: InputDecoration(
                labelText: "Date",
                prefixIcon:
                    const Icon(Icons.calendar_month),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// TIME
            TextField(
              controller: timeController,
              readOnly: true,
              onTap: pickTime,
              decoration: InputDecoration(
                labelText: "Heure",
                prefixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// BOUTON AJOUTER
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {

                  String reason = reasonController.text;
                  String date = dateController.text;
                  String time = timeController.text;

                  if (reason.isNotEmpty &&
                      date.isNotEmpty &&
                      time.isNotEmpty) {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Rappel ajouté avec succès"),
                      ),
                    );

                    Navigator.pop(context);
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(
                          vertical: 15),
                ),

                child: const Text(
                  "Ajouter rappel",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}