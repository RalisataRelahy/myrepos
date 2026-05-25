import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// NONNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
class Sended extends StatelessWidget {
  const Sended({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: isMobile ? 200 : 300,
              child: Lottie.asset(
                'assets/lotties/success_send.json',
                repeat: false,
              ),
            ),
            Text("Demande envoyée", style: TextStyle(fontSize: 30)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EventPage(uid: FirebaseAuth.instance.currentUser!.uid),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: Colors.blue,
              ),

              child: const Text(
                "Acceuil",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
